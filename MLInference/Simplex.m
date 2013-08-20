classdef Simplex < Optimisation
    properties
        step=10;
        reflect=1.0;
        extend=2.0;
        contract=0.5;
        shrink=0.5;
        res=10.0;
        per=0.001; %relative error xopts for convergence
        error=0.001; %relative error for convergence
        max_evaluation=100000; %maximum number of function evaluations to make
    end
    properties (Constant)
        MAX_ITERATIONS=2000;
        JITTER_SIGMA=0.1;
        RESTARTS=3;
    end
    
    methods(Access=public)
        
        function [debug,times] = debug_simplex(obj,funct,init_params,opts)
            debug=struct();
            times=struct();
            %just a way of testing the basic simplex operations
            param_keys=keys(init_params);
            
            x=tic;
            [debug.setup.simplex_points,debug.setup.function_values] = Simplex.setup_simplex(init_params,obj.step,funct,opts);
            times.setup=toc(x);
            
            x=tic;
            [debug.converge.hasConverged,debug.converge.simp_diff,debug.converge.lik_diff] = Simplex.converge_simplex(debug.setup.simplex_points,debug.setup.function_values,param_keys,obj.error,obj.error);
            times.converge=toc(x);

            x=tic;
            [debug.sorted.simplex_points,debug.sorted.function_values] = Simplex.sort_simplex(debug.setup.simplex_points,debug.setup.function_values);
            times.sort=toc(x);
            
            x=tic;
            debug.centre.point=Simplex.centre_simplex(debug.sorted.simplex_points,param_keys);
            debug.centre.lik=funct.evaluate_function(debug.centre.point,opts);
            times.centre=toc(x);          
            
            x=tic;
            debug.reflect.point = Simplex.transform_point(debug.centre.point,debug.sorted.simplex_points{end},param_keys,obj.reflect,true);
            debug.reflect.lik=funct.evaluate_function(debug.reflect.point,opts);
            times.reflect=toc(x);            
            
            x=tic;
            debug.extend.point = Simplex.transform_point(debug.centre.point,debug.reflect.point,param_keys,obj.extend,false);
            debug.extend.lik=funct.evaluate_function(debug.extend.point,opts);
            times.extend=toc(x);             
            
            x=tic;
            debug.contract.point = Simplex.transform_point(debug.centre.point,debug.sorted.simplex_points{end},param_keys,obj.contract,false);
            debug.contract.lik=funct.evaluate_function(debug.contract.point,opts);
            times.contract=toc(x);            
            
            x=tic;
            [debug.shrink.point,debug.shrink.liks]=Simplex.shrink_simplex(debug.sorted.simplex_points,param_keys,obj.shrink,funct,opts);
            times.shrink=toc(x);
            
            
            %return the test structures as matrices

            x=tic;
            debug.setup.simplex_points=Simplex.matricise_simplex(debug.setup.simplex_points,param_keys);
            times.matricise=toc(x);
            
            debug.sorted.simplex_points=Simplex.matricise_simplex(debug.sorted.simplex_points,param_keys);
            debug.centre.point=Simplex.vectorise_point(debug.centre.point,param_keys);
            debug.reflect.point = Simplex.vectorise_point(debug.reflect.point,param_keys);
            debug.extend.point=Simplex.vectorise_point(debug.extend.point,param_keys);
            debug.contract.point=Simplex.vectorise_point(debug.contract.point,param_keys);
            debug.shrink.point=Simplex.matricise_simplex(debug.shrink.point,param_keys); 
            
        end
        
        function [min_function_value,min_parameters,iter,rejigs,errors,debug_simplex] = run_simplex(obj,funct,init_params,opts)
            
            %funct - a handle to the object with a function to be
            %optimised. This object must implement an interface functions
            %'evaluate_function,setParameters'
            
            %init_params - initial Map of parameters of the function
            
            iterations = 0;
            errors = 0;
            debug_simplex=struct;
            param_keys = init_params.keys;
            
            [simplex_points,function_values] = Simplex.setup_simplex(init_params,obj.step,funct,opts);
            
            %keep the record of the best params
            
            best_params.params = simplex_points(1);
            best_params.lik = function_values(1);
            
            if opts.parameters.debug_on
                debug_simplex.start.simplex = simplex_points;
                debug_simplex.start.likelihoods = function_values;
            end
            
            restart=true;
            rejig = false;
            rejig_count=0;
            while restart && iterations < obj.MAX_ITERATIONS && rejig_count <= Simplex.RESTARTS

                if function_values(1) < best_params.lik
                    best_params.params = simplex_points(1);
                    best_params.lik = function_values(1);                    
                end    
                
                if rejig && rejig_count <= Simplex.RESTARTS
                    fprintf('Rejig called - Shuffling the best params...\n')
                    params = best_params.params{1};
                    for i=1:length(param_keys)
                        orig = params(param_keys{i});
                        params(param_keys{i}) = log(lognrnd(orig,Simplex.JITTER_SIGMA));
                    end
                    [simplex_points,function_values] = Simplex.setup_simplex(params,obj.step,funct,opts);
                    rejig_count=rejig_count+1;
                    rejig=false; 
                    
                    %if debugging we want to record this
                    if opts.debugOn
                        debug_simplex.rejig(rejig_count).prevbest.params = best_params.params{1};
                        debug_simplex.rejig(rejig_count).prevbest.lik = best_params.lik;
                        debug_simplex.rejig(rejig_count).newbest.params = params;
                        debug_simplex.rejig(rejig_count).newbest.lik = funct.evaluate_function(params,opts);
                    end
                    
                end
                
                %A - sort the simplex structure by function value
                [simplex_points,function_values] = Simplex.sort_simplex(simplex_points,function_values);

                if (mod (iterations,100) == 0)
                    fprintf('Iteration %d best likelihood %f params %s\n',iterations,function_values(1),mat2str(cellfun(@exp,simplex_points{1}.values)))
                end
                
                %B - check for algorithm convergence
                [hasConverged,~,~] = Simplex.converge_simplex(simplex_points,function_values,param_keys,obj.error,obj.error);
                
                if hasConverged
                    %perform local search- this involves calculating
                    %likelihood +/- tolerance level
                    [lower,higher]=Simplex.embed_point(simplex_points{1},param_keys,obj.error);
                    lower_lik = funct.evaluate_function(lower,opts);
                    higher_lik = funct.evaluate_function(higher,opts);
                    
                    %if the move within tolerance produces a lower
                    %likelihood then restart with a restricted step
                    if higher_lik < function_values(1) 
                        init_params = higher;
                        restart=true;
                        obj.step = obj.res * obj.error;
                    elseif  lower_lik < function_values(1)
                        init_params = lower;
                        restart=true;
                        obj.step = obj.res * obj.error;
                    else                      
                        restart=false;
                    end                    
                    break
  
                else
                    
                    %C - calculate the centre of the simplex. We ignore the
                    %worst point in the simplex in this calculation.
                    centre = Simplex.centre_simplex(simplex_points,param_keys);
                   

                    %D - reflect the simplex. If the new point is better than the
                    %second worst point but not better than the best, replace
                    %the worst n+1 point with the reflected point and go back
                    %to A
                    
                    reflected = Simplex.transform_point(centre,simplex_points{end},param_keys,obj.reflect,true);
                    try 
                        reflect_lik = funct.evaluate_function(reflected,opts);
                    catch err
                        disp(err)
                        disp(err.cause{1}.message)
                        errors=errors+1;
                        if opts.debugOn
                            %we want to catch the parameters
                            %which caused this error        
                            debug_simplex.errors(errors).params=err.params;                        
                        end
                        rejig=true;
                    end
                    
                    if reflect_lik < function_values(1)
                         %E - if reflected point is best so far try extending it
                         extended = Simplex.transform_point(centre,reflected,param_keys,obj.extend,false);
                         
                         try 
                             extended_lik = funct.evaluate_function(extended,opts);
                         catch err
                             disp(err) 
                             rejig=true;
                         end
                         if extended_lik < reflect_lik
                            %fprintf('iteration %d EXTENDED lik=%f\n',iterations,extended_lik)
                            % E1 - if expanded point is better then reflected point
                            % replace the worst point with the EXPANDED point and
                            % goto A
                             simplex_points{end} = extended;
                             function_values(end) = extended_lik;
                         else
                             %fprintf('iteration %d REFLECTED lik=%f\n',iterations,reflect_lik)
                             %E2 - else replace the worst point with REFLECTED point
                             % and goto A
                             simplex_points{end} = reflected;
                             function_values(end) = reflect_lik;
                         end
                             
                    else
                        %the reflected point is not better than the best.
                        %Is it better than the second worst?
                        if reflect_lik < function_values(end-1)
                            simplex_points{end} = reflected;
                            function_values(end) = reflect_lik;
                            %fprintf('iteration %d REFLECTED  BETTER THAN SECOND WORST lik=%f\n',iterations,reflect_lik)
                        else
                            %update as necessary if better than worst point
                            if reflect_lik < function_values(end)
                                simplex_points{end} = reflected;
                                function_values(end) = reflect_lik;
                            end
                            %its not better than the second worst - perform
                            %a contaction
                            contracted = Simplex.transform_point(centre,simplex_points{end},param_keys,obj.contract,false);
                            
                            try
                                contracted_lik = funct.evaluate_function(contracted,opts);
                            catch err
                                disp(err)
                                disp(err.cause{1}.message)
                                rejig=true;
                                errors=errors+1;
                                if opts.debugOn
                                    %we want to catch the parameters
                                    %which caused this error        
                                    debug_simplex.errors(errors).params=err.params;                        
                                end
                            end
                            
                            if contracted_lik <= function_values(end)
                                %F - by this stage we know that the reflected point is NOT
                                %better than the second worst point. So we try a CONTRACTED
                                %point between the best and worst points. If this point is
                                %better than the current worst point, replace and go to A
                                simplex_points{end} = contracted;
                                function_values(end) = contracted_lik;
                                %fprintf('iteration %d CONTRACTED  lik=%f\n',iterations,contracted_lik)

                                
                            else
                                %G -  so the contracted point isn't better than the worst
                                %point, so for all but the best point we SHRINK the other
                                %vertices and then goto A
                                %shrink the simplex
                                try
                                    [simplex_points,function_values]=Simplex.shrink_simplex(simplex_points,param_keys,obj.shrink,funct,opts);
                                catch err
                                    disp(err.message)
                                    disp(err.cause{1}.message)
                                    rejig=true;
                                    errors=errors+1;
                                    if opts.debugOn
                                        %we want to catch the parameters
                                        %which caused this error        
                                        debug_simplex.errors(errors).params=err.params;                        
                                    end
                                end
                                %fprintf('iteration %d SHRUNK  lik=%f\n',iterations,function_values(1))
                            end
                            
                        end
                        
                        
                    end
                    iterations=iterations+1;
                    if opts.parameters.debug_on
                        [simplex_points,function_values]=Simplex.sort_simplex(simplex_points,function_values);
                        debug_simplex.iter_simplex(iterations) = {simplex_points};
                        debug_simplex.iter_liks(iterations) = {function_values};
                    end
                end

                %restart=false;

            end
            
            min_function_value=function_values(1);
            min_parameters=simplex_points{1};
			iter=iterations;
            rejigs=rejig_count;
            
            fprintf('Fitting finished. Max likelihood %f\n',min_function_value)
            fprintf('\tIterations: %i\n',iter)
            fprintf('\tErrors: %i\n',errors)
            fprintf('\tRestarts: %i\n\n',rejig_count)
            
			if iterations==Simplex.MAX_ITERATIONS
				fprintf('WARNING, MAX ITERATIONS (%i) HIT\n',Simplex.MAX_ITERATIONS)
            elseif  rejig_count==Simplex.RESTARTS
                fprintf('WARNING, MAX JITTERS (%i) HIT\n',Simplex.MAX_ITERATIONS)
			end
            
        end
    end
    
    methods(Static,Access=private)
        function [simplex_points,function_values] = setup_simplex(init_params,step,funct,function_opts)
            %simplexes - a n+1 vector, each element containing a Map with n
            %params
            
            param_length = init_params.length();
            
            %TODO unwrap the map structure into a matrix as it is easier to work
            %with a matrix in the simplex algorithm and it is what matlab
            %is good at
            
            simplex_points=cell(param_length+1,1); %can't allocate an array of maps
            simplex_points{1}=init_params;
           
            %function_values - n+1 vector of function values pertaining to
            %the n+1 points
            simplex_points{1}=init_params;
            
            log_step = log(step);
            fact = (sqrt(param_length+1) - 1) / (param_length * sqrt(2));
            keySet = keys(init_params);
            start_params=containers.Map(init_params.keys,init_params.values);
            for i=1:length(keySet)
                start_params(keySet{i}) = start_params(keySet{i}) + log_step * fact;       
            end
            
            
            for simp_no=1:param_length
                %set up the remaining points in the simplex
                %need a new copy of the map here
                new_params = containers.Map(start_params.keys,start_params.values);
                new_params(keySet{simp_no}) = init_params(keySet{simp_no}) + log_step * (fact + 1 / sqrt(2));
                simplex_points{simp_no+1}=new_params;
            end
            
            function_values = Simplex.evaluate_simplex(simplex_points,funct,function_opts);
            
        end
        
        function [sorted_simplex,sorted_likelihood] = sort_simplex(simplex_points,function_values)
            [sorted_likelihood,idx]=sort(function_values,'ascend');
            sorted_simplex=simplex_points(idx);
        end
        
        function [shrunk_simplex,shrunk_liks]=shrink_simplex(simplex_points,param_keys,shrink_factor,funct,opts)
            
            shrunk_simplex=cell(length(simplex_points),1);
            shrunk_simplex{1} = simplex_points{1};
            for i=2:length(simplex_points)
                shrunk_simplex{i} = Simplex.transform_point(simplex_points{1},simplex_points{i},param_keys,shrink_factor,false);
            end
            shrunk_liks=Simplex.evaluate_simplex(shrunk_simplex,funct,opts);
        end
        
        function new_point = transform_point(a,b,param_keys,transform_factor,reflect)
            a = Simplex.vectorise_point(a,param_keys);
            b = Simplex.vectorise_point(b,param_keys);
            if reflect
                new_point = a +  transform_factor * (a - b);
            else
                new_point = a +  transform_factor * (b - a); 
            end
            new_point = containers.Map(param_keys,new_point);
        end
        
        function [lower,higher] = embed_point(point,param_keys,plusminus)
            %calculates the best set of params +/- an additive factor
            simp_vec=Simplex.vectorise_point(point,param_keys);
            lower=simp_vec-plusminus;
            higher=simp_vec+plusminus;
            
            lower=containers.Map(param_keys,lower);
            higher=containers.Map(param_keys,higher);
            
         end
        
        function point_likelihoods = evaluate_simplex(simplex_points,funct,args)
            points = length(simplex_points);
            point_likelihoods = zeros(points,1);
            
            for point_no=1:points
                point_likelihoods(point_no) = funct.evaluate_function(simplex_points{point_no},args);
            end
            
        end
        
        function centre = centre_simplex(simplex_points,param_keys)

            test_matrix=Simplex.matricise_simplex(simplex_points,param_keys);
            
            %take all points except the worst and calculate the average
            %parameter values
            
            test_matrix=test_matrix(1:end-1,:);
            param_sums=sum(test_matrix);
            centre=param_sums/size(test_matrix,2);
            
            centre = containers.Map(param_keys,centre);
            
            
        end
        
        function simp_mat=matricise_simplex(simplex_points,param_keys)
        
            point_count=size(simplex_points,1);
            params_count=length(param_keys);
            simp_mat=zeros(point_count,params_count);
            for point_no=1:size(simplex_points,1)              
               simp_mat(point_no,:) = cell2mat(values(simplex_points{point_no},param_keys));
            end           
        end
        
        function simp_vec=vectorise_point(point_map,param_keys)
            %turns a map into a vector of map values
            simp_vec=cell2mat(values(point_map,param_keys));
            
        end
        
        function [hasConverged,converged_params,converged_likelihood] = converge_simplex(simplex_points,function_values,param_keys,conv_param,conv_lik)
            %simplex is judged to have converged if the maximum
            %difference between parameter values at the best point and
            %the same parameter values at the other points is less than
            %some tolerance level AND the max difference in likelihood
            %is less than some tolerance level.
            
            test_matrix=Simplex.matricise_simplex(simplex_points,param_keys);
            
            for point_no=1:size(simplex_points,1)              
                test_matrix(point_no,:) = cell2mat(values(simplex_points{point_no},param_keys));
            end
            
            diff_param = abs(test_matrix(2:end,:)-repmat(test_matrix(1,:),size(test_matrix,2),1));
            converged_params = max(diff_param(:));
            
            converged_likelihood = max(abs(function_values(2:end)-function_values(1)));
            
            if conv_param > converged_params && conv_lik > converged_likelihood
                hasConverged=true;
                
            else
                hasConverged=false;
            end
           
        end
            
        
    end
    
    
end

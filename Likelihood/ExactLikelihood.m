classdef ExactLikelihood < Likelihood
 
    properties
        isSetup = 0;
        isDebug = 0;
        
        Q_rep;      %Likeihood's Q_representation of mechanism k by k
        mechanism;  %mechanism for the likelihood
        tres;
        tcrit;
        
        eig_valsQ;  %eigenvalues of the Q-matrix
        specA;      %spectral expansion of the A state matrices
        eig_vectsF; %eigenvectors of the F states of the Q matrix
        eig_vectsA; %eigenvectors of the A states of the Q matrix
        eig_valsF;  %eigenvaluess of the F states of the Q matrix
        eig_valsA;  %eigenvaluess of the A states of the Q matrix
        
        expFF;      %Matrix exponentation of FF partition with t=tres
        expAA;      %Matrix exponentation of AA partition with t=tres
        G_AF;       %Transition matrix from A -> F states regardless of when transition occurs
        G_FA;       %Transition matrix from F -> A states regardless of when transition occurs
        eG_AF;      %Transition matrix from A -> F states regardless of when transition occurs given time interval omission
        eG_FA;      %Transition matrix from F -> A states regardless of when transition occurs given time interval omission
        phiA;       %opening equilibrium vector for starting states
        phiF;       %closing vector for shut states
        endBurst;   %closing vector for a burst
        beginCHS;   %CHS open vector
        endCHS;     %CHS close vector
        
                    %Z constant matricies for exact pdf calculations
        AZ00;       %A states 
        AZ10;
        AZ11;
        FZ00;       %F states
        FZ10;
        FZ11;
        
        open_roots; % roots of %det(W_AA(s))=0. where W(s)-sI-H(s) (Col & Hawkes 1992 eq 52)
        closed_roots; % roots of %det(W_FF(s))=0. where W(s)-sI-H(s) (Col & Hawkes 1992 eq 52)
        a_AR;       %survivor function for A states
        f_AR;       %survivor function for F states

    end
    
    methods (Access=public)
        
        function obj = ExactLikelihood(debug)
           % class constructor
           obj.isSetup=0;

        end
        
        
          
        function vector=calc_initial_HJC_vector(obj,eX,eY,kX)
            
            
            %Calculates for openings or shuttings by solving
            %phi*(I-eX*eY)=0 where eX=eG_AF, eY=eG_FA and kX is the number
            %of states in eG_AF.
            vector=ones(kX);
            
            if kX>1
                mat=eye(kX)-(eX*eY);
                mat=[mat ones(kX,1)];
                vector=(ones(1,kX)*(mat*mat')^-1)';
            end
   
        end
        
        function [obj,timings]=setup_likelihood(obj, mech, conc, tres,tcrit, isCHS)
            %calculates the setup matricies

            timings.time=zeros(9,1);
            timings.names=cell(9,1);
            % setup the effector
            obj.Q_rep = mech.setupQ(conc);
            obj.mechanism = mech;
            obj.tres=tres;
            obj.tcrit=tcrit;
            
            % TO TEST numbers:
            
            a=tic;
            % we need the asymptotic G_AF,G_FA matricies
            obj.eig_valsQ=sort(eig(obj.Q_rep.Q),'descend')';
            [specF,obj.eig_valsF,obj.eig_vectsF]=obj.spectral_expansion(obj.Q_rep.Q_FF);
            [obj.specA,obj.eig_valsA,obj.eig_vectsA]=obj.spectral_expansion(obj.Q_rep.Q_AA);
            timings.time(1)=toc(a);
            timings.names{1}='Eigenvales of -Q and spectral expansion';
            
            % we need exp^{Q_{FF}*t_res}, exp^{Q_{AA}*t_res}
            a=tic;
            obj.expFF = obj.mat_exponentiation(obj.eig_valsF,specF,tres);
            obj.expAA = obj.mat_exponentiation(obj.eig_valsA,obj.specA,tres);
            timings.time(2)=toc(a);
            timings.names{2}='matrix exponentiation';
            
            % G_AF = (sI-Q_AA)^{-1}*Q_FF where s=0 => -Q_AA^{-1}Q_AF
            a=tic;
            obj.G_AF = -obj.Q_rep.Q_AA^(-1)*obj.Q_rep.Q_AF;
            obj.G_FA = -obj.Q_rep.Q_FF^(-1)*obj.Q_rep.Q_FA;
            timings.time(3)=toc(a);
            timings.names{3}='G_AF and G_FA';           
            
            % we need the  eG_AF,eG_FA matricies, adjusted matrices
            % whenever the transitions occur these require expFF and G_FA
            % etc
            %eGAF*(s=0) = (I - GAF * (I - expQFF) * GFA)^-1 * GAF * expQFF
            a=tic;
            obj.eG_AF=(eye(mech.kA)-(obj.G_AF*(eye(mech.kE)-obj.expFF)*obj.G_FA))^(-1);
            obj.eG_AF=obj.eG_AF*obj.G_AF*obj.expFF;
            
            obj.eG_FA=(eye(mech.kE)-(obj.G_FA*(eye(mech.kA)-obj.expAA)*obj.G_AF))^(-1);
            obj.eG_FA=obj.eG_FA*obj.G_FA*obj.expAA;
            timings.time(4)=toc(a);
            timings.names{4}='eG_AF and eG_FA matrices';             
            
            % we need the equilibrium states of the closed states in
            % the burst for CHS vector calculation
            
            % we need the equilibrium states of the openings in the burst
            
            % summation vector for closed states in the burst to sum up the
            % likeihoods - changes with CHS vectors
            
            a=tic;
            obj.phiA=obj.calc_initial_HJC_vector(obj.eG_AF,obj.eG_FA,mech.kA); %equilibrium opening for bursts
            obj.phiF=obj.calc_initial_HJC_vector(obj.eG_FA,obj.eG_AF,mech.kE); %used in CHS vector calc
            obj.endBurst=ones(mech.kE,1); %sum up the likelihood over ending closed states of the burst
            timings.time(5)=toc(a);
            timings.names{5}='Opening vectors and closing vectors';            
            
                      
            % OPEN STATES
            
            % we need the Z matrix constants for the exact open/shut time
            % pdfs
            a=tic;
            [obj.AZ00,obj.AZ10,obj.AZ11,~] = obj.calc_Z_constants(obj.Q_rep,obj.expFF,mech.k,mech.kA,mech.kE,1,0);
            timings.time(6)=toc(a);
            timings.names{6}='open Z constants';  
            % we need to find the asymptotic roots for the given Q matrix
            
            a=tic;
            [obj.open_roots,~]=asymptotic_roots(tres,obj.Q_rep.Q_AA,obj.Q_rep.Q_FF,obj.Q_rep.Q_AF,obj.Q_rep.Q_FA,mech.kA,mech.kE,0); 
            [obj.closed_roots,~]=asymptotic_roots(tres,obj.Q_rep.Q_FF,obj.Q_rep.Q_AA,obj.Q_rep.Q_FA,obj.Q_rep.Q_AF,mech.kE,mech.kA,0);
            timings.time(7)=toc(a);
            timings.names{7}='open asymptotic roots'; 
            
            % we need the AR survivor matrices
            a=tic;
            ARa=AR(obj.open_roots,tres,obj.Q_rep.Q_AA,obj.Q_rep.Q_FF,obj.Q_rep.Q_AF,obj.Q_rep.Q_FA,mech.kA,mech.kE);      
            obj.a_AR.mat=reshape(ARa,size(ARa,1)*size(ARa,2),size(ARa,3));
            obj.a_AR.size=size(ARa);
            clear ARa;
            
            
            ARf=AR(obj.closed_roots,tres,obj.Q_rep.Q_FF,obj.Q_rep.Q_AA,obj.Q_rep.Q_FA,obj.Q_rep.Q_AF,mech.kE,mech.kA);
            obj.f_AR.mat=reshape(ARf,size(ARf,1)*size(ARf,2),size(ARf,3));
            obj.f_AR.size=size(ARf);
            clear ARf;
            timings.time(8)=toc(a);
            timings.names{8}='open survivor function';           
            
            % we need the Z matrix constants for the exact open/shut time
            % pdfs
            a=tic;
            [obj.FZ00,obj.FZ10,obj.FZ11,~] = obj.calc_Z_constants(obj.Q_rep,obj.expAA,mech.k,mech.kA,mech.kE,0,0);
            timings.time(9)=toc(a);
            timings.names{9}='close Z constants';  

            if isCHS
                %we need the adjusted CHS vectors for the burst            
                [obj.beginCHS,obj.endCHS] = calcCHS(obj.closed_roots,obj.tres,obj.tcrit,obj.Q_rep.Q_FA,obj.mechanism.kA,obj.expAA,obj.phiF',obj.f_AR);
            end
            
            %the likelihood is setup for likelihood calculation
            obj.isSetup = 1; 

            
        end
        
        function debug = likelihood_debug(obj)
            %we are saving info about this calculation in a struct
            debug.likstatus = obj.isSetup;
            
            if obj.isSetup
                
                debug.expFF = obj.expFF;
                debug.expAA = obj.expAA;
                debug.G_AF = obj.G_AF;
                debug.G_FA = obj.G_FA;
                debug.eG_AF = obj.eG_AF;
                debug.eG_FA = obj.eG_FA;
                debug.Q=obj.Q_rep.Q;
                debug.Q_FF=obj.Q_rep.Q_FF;
                debug.Q_AA=obj.Q_rep.Q_AA;
                debug.phiF=obj.phiF;
                debug.phiA=obj.phiA;
                debug.specA=obj.specA;
                debug.eig_vectsF=obj.eig_vectsF;
                debug.eig_vectsA=obj.eig_vectsA;
                debug.AZ00=obj.AZ00;
                debug.AZ10=obj.AZ10;
                debug.AZ11=obj.AZ11;
                debug.FZ00=obj.FZ00;
                debug.FZ10=obj.FZ10;
                debug.FZ11=obj.FZ11;
                debug.open_roots=obj.open_roots;
                debug.closed_roots=obj.closed_roots;
                debug.a_AR=obj.a_AR;
                debug.f_AR=obj.f_AR;
                debug.beginCHS=obj.beginCHS;
                debug.endCHS=obj.endCHS;
                
                %in order to get in depth information we need to run some
                %calculations again
                [~,~,~,debug.open_Z_constants]=obj.calc_Z_constants(obj.Q_rep,obj.expFF,obj.mechanism.k,obj.mechanism.kA,obj.mechanism.kE,1,1);          
                [~,~,~,debug.close_Z_constants] = obj.calc_Z_constants(obj.Q_rep,obj.expAA,obj.mechanism.k,obj.mechanism.kA,obj.mechanism.kE,0,1);
                
                [~,debug.openroots]=asymptotic_roots(obj.tres,obj.Q_rep.Q_AA,obj.Q_rep.Q_FF,obj.Q_rep.Q_AF,obj.Q_rep.Q_FA,obj.mechanism.kA,obj.mechanism.kE,1); 
                [~,debug.closedroots]=asymptotic_roots(obj.tres,obj.Q_rep.Q_FF,obj.Q_rep.Q_AA,obj.Q_rep.Q_FA,obj.Q_rep.Q_AF,obj.mechanism.kE,obj.mechanism.kA,1);

                
            end
            
        end
        
        function [Z00,Z10,Z11,debug] = calc_Z_constants(obj,Q_rep,expMat,k,kA,kF,open,debugOn)
           %these are the Z constants needed for the calculation of the exact solutions
           %i.e. first and second dwell times whose probabilities are
           %calculated exactly
           debug=struct('');
           
           %Z-constants are 3-D matrices of k*kX*kY dimensionality
           Q=Q_rep.Q;
           Q_FF=Q_rep.Q_FF;
           Q_AF=Q_rep.Q_AF;
           Q_FA=Q_rep.Q_FA;
           
           [spec, evals,~]=obj.spectral_expansion(-Q);
           
           %D = zeros(k);
           
           if open
               %we need the k*1:kA x 1:kA slice of the spectral expansion
               C00 = spec(:,1:kA,1:kA);
               %we need the k*1:kA x kA+1:kF slice of the spectral expansion
               A1 = spec(:, 1:kA, kA+1:end);
               
               % we want D = (A1*expQFF)* QFA;
               %the squeeze operation is necessary as singleton dimensions
               %are not automatically removed in MATLAB. There is probably a
               %'one-line' way of doing this but for clarity persist with a
               %loop for now
               
               D_dim=size(C00);
               D=zeros(D_dim);
               for i=1:k
                   D(i,:,:) = (squeeze(A1(i,:,:))*expMat)*Q_FA;
               end
               Y=Q_AF*expMat;
               C11 = zeros(k, kA, kA);
               C10 = zeros(k, kA, kA);
               sub=zeros(kA,kA);
           else
               C00 = spec(:,kA+1:end,kA+1:end);
               A1 = spec(:, kA+1:end, 1:kA);
               D_dim=size(C00);
               D=zeros(D_dim);
               for i=1:k
                   D(i,:,:) = (squeeze(A1(i,:,:))*expMat)*Q_AF;
               end               
               Y=Q_FA*expMat;
               C11 = zeros(k, kF, kF);
               C10 = zeros(k, kF, kF);
               sub=zeros(kF,kF);
           end
                      
           dimC00 = size(C00);
           
           for i=1:k
               C11(i,:,:) = squeeze(D(i,:,:))*squeeze(C00(i,:,:));
           end
           
           %these are temp variables purely to make the C10 calculations
           %more efficient by removing the need to "squeeze" the first
           %dimension out of the subscription.
           D_temp=permute(D,[2 3 1]);
           C00_temp=permute(C00,[2 3 1]);
           for i=1:k
               
               for j=1:k
                   if(i ~= j)
                       sub = sub +((D_temp(:,:,i)* C00_temp(:,:,j) + (D_temp(:,:,j)* C00_temp(:,:,i))) /(evals(j,j) - evals(i,i)));
                   end     
               end
               C10(i,:,:) = sub;
               sub(:)=0;
           end
                   
           
           sizeY=size(Y);
           Z00=zeros(k,dimC00(2),sizeY(2));
           Z10=zeros(k,dimC00(2),sizeY(2));
           Z11=zeros(k,dimC00(2),sizeY(2));
           
           for i=1:k
               Z00(i,:,:)=squeeze(C00(i,:,:))*Y;
               Z10(i,:,:)=squeeze(C10(i,:,:))*Y;
               Z11(i,:,:)=squeeze(C11(i,:,:))*Y;
           end
           if debugOn ==1
              
              if open
                  debug=struct('AZ00',Z00,'AZ10',Z10,'AZ11',Z11,'AC00',C00,'AC10',C10,'AC11',C11);
              else
                  debug=struct('FZ00',Z00,'FZ10',Z10,'FZ11',Z11,'FC00',C00,'FC10',C10,'FC11',C11);
              end
               
           end
           
        end
        

        
        function log_likelihood = evaluate_function(obj,params,function_opts)
            %to be overridden 
            
            %transform the parameters from log space if necessary
            func_params=containers.Map(params.keys,params.values);            
            keySet = params.keys; 
            for i=1:length(keySet)
                if function_opts.islogspace
                    func_params(keySet{i}) = exp(params(keySet{i}));
                else
                    func_params(keySet{i}) = params(keySet{i});
                end
            end
            
            function_opts.mechanism.setParameters(func_params);
            try
                obj=setup_likelihood(obj, function_opts.mechanism, function_opts.conc, function_opts.tres,function_opts.tcrit, function_opts.isCHS);
            catch err
                loc=MException('ExactLikelihood:setup_likelihood','error in likelihood setup');
                err.addCause(loc);
                rethrow(err);
            end
            log_likelihood=calculate_likelihood_vectorised(obj,function_opts.bursts,function_opts.open_times,function_opts.closed_times,function_opts.withinburst_count,function_opts.l_openings);  
        end
        
        function log_likelihood = calculate_likelihood(obj,bursts)
            %inputs: 
            %        bursts - a vector of burst objects over which to
            %        calculate the likeihood
            %
            %        outputs - -log_likelihood
            
            tresol=obj.tres;
            
            log_likelihood=0;
            %qml.eGAF(t, tres, Aeigvals, AZ00, AZ10, AZ11, Aroots,AR, mec.QAF, expQFF)
            for i=1:length(bursts)
                burst = bursts(i);
                burstlik=obj.beginCHS;
                for j=1:length(burst.withinburst.intervals)
                    if burst.withinburst.amps(j)>0 %opening
                        individual_lik = ExactLikelihood.exact_pdf(obj.eig_valsQ,obj.a_AR,obj.open_roots,obj.AZ00,obj.AZ10,obj.AZ11,burst.withinburst.intervals(j),tresol,obj.Q_rep.Q_AF,obj.expFF);
                    else
                        individual_lik = ExactLikelihood.exact_pdf(obj.eig_valsQ,obj.f_AR,obj.closed_roots,obj.FZ00,obj.FZ10,obj.FZ11,burst.withinburst.intervals(j),tresol,obj.Q_rep.Q_FA,obj.expAA);
                        %individual_lik = obj.exact_close_pdf(obj,burst.withinburst.intervals(j));
                    end
                    
                    burstlik=burstlik*individual_lik;
                end
                burstlik=burstlik*obj.endCHS;
                %disp(burstlik)
                log_likelihood=log_likelihood-log(burstlik);
                %fprintf('%i: %f - %f\n',i,burstlik,log_likelihood)
            end         
        end       
        
        function [open_times,closed_times,withinburst_count,l_openings] = calculate_burst_parameters(obj,bursts)
            %calculate array of open and shut times here on the basis that
            %we only need to do this once per dataset
            withinbursts=[bursts.withinburst];
            withinburst_count=[bursts.no_of_openings]+[bursts.no_of_openings]-1; %n+(n-1) intervals within a burst
            time_intervals=[withinbursts.intervals];
            
            l_openings=[withinbursts.amps]>0;
            l_closings=logical(ones(1,length(l_openings))-l_openings);
            
            open_times=time_intervals(l_openings);
            closed_times=time_intervals(l_closings);                       
        end

        function log_likelihood = calculate_likelihood_vectorised(obj,bursts,open_times,closed_times,withinburst_count,l_openings)
            tresol=obj.tres;
            log_likelihood=0;
               
            %calculate pdfs of open and shut times
            
            open_pdfs = permute(ExactLikelihood.exact_pdf_vectorised(obj.eig_valsQ,obj.a_AR,obj.open_roots,obj.AZ00,obj.AZ10,obj.AZ11,open_times,tresol,obj.Q_rep.Q_AF,obj.expFF),[2 3 1]);
            closed_pdfs = permute(ExactLikelihood.exact_pdf_vectorised(obj.eig_valsQ,obj.f_AR,obj.closed_roots,obj.FZ00,obj.FZ10,obj.FZ11,closed_times,tresol,obj.Q_rep.Q_FA,obj.expAA),[2 3 1]);
            
            beginVec=obj.beginCHS;
            endVec=obj.endCHS;
            
            %iterate over bursts for the likelihood
            
            
            open_count=1;
            closed_count=1;
            total_count=1;
            for i=1:length(bursts)
                %burst = bursts(i);
                burstlik=beginVec;
                
                for j=1:withinburst_count(i)
                    if l_openings(total_count)
                        individual_lik = open_pdfs(:,:,open_count);
                        open_count=open_count+1;                       
                    else
                        individual_lik = closed_pdfs(:,:,closed_count);
                        closed_count=closed_count+1;                       
                    end
                    total_count=total_count+1;
                    %burstlik=lm(burstlik,individual_lik);
                    burstlik=burstlik*individual_lik;
                end
                
                %burstlik=lm(burstlik,log(obj.endCHS));
                burstlik=burstlik*endVec;
                log_likelihood=log_likelihood-log(burstlik);
            end
            
        end
    end
    
    methods (Static = true)
        function pdf=f0(excess_time,eigvals,Z00)
           %first component of the piecewise pdf 
           
            if length(size(Z00)) > 1
                pdf = reshape(exp(eigvals * excess_time)*reshape(Z00,size(Z00,1),size(Z00,2)*size(Z00,3)),size(Z00,2),size(Z00,3));
            else
                pdf = Z00 *  exp(eigvals * excess_time);           
            end
        end
        
        function pdfs = f0_vectorised(excess_times,eigvals,Z00)
            if length(excess_times) == 1
                %call the standard function
                pdfs=ExactLikelihood.f0(excess_times,eigvals,Z00);               
            else
                if length(size(Z00)) > 1
                    pdfs = reshape(exp(excess_times'*eigvals)*reshape(Z00,size(Z00,1),size(Z00,2)*size(Z00,3)),length(excess_times),size(Z00,2),size(Z00,3));
                else
                    pdfs = exp(eigvals * excess_times)*Z00;           
                end               
            end
        end
        
        function pdf=f1(excess_time,eigvals,Z10,Z11)
           %second component of the piecewise pdf 
           %Inputs - excess time over tres
           %       - eigenvalues of -Q matrix
           %       - Z10 constant matrix
           %       - Z11 constant matrix
           
           if length(size(Z10)) > 1
               temp = (Z10+Z11*excess_time);
               temp = reshape(temp,size(temp,1),size(temp,2)*size(temp,3));
               pdf = reshape(exp(eigvals * excess_time)*temp,size(Z10,2),size(Z10,3));
           else
               pdf = (Z10+Z11*excess_time) *  exp(eigvals * excess_time);
           end   
        end
        
        function pdfs=f1_vectorised(excess_times,eigvals,Z10,Z11)
            if length(excess_times) == 1
                %call the standard function
                pdfs=ExactLikelihood.f1(excess_times,eigvals,Z10,Z11); 
            else
                pdfs=zeros(size(excess_times,2),size(Z10,2),size(Z10,3));
                if length(size(Z10)) > 1
                    zeds=repmat(Z10(:),1,size(excess_times,2))+(Z11(:)*excess_times);
                    eigs_excess=exp(excess_times'*eigvals);
                    %cant think of a better (faster) way than a loop. Basically
                    %multiply ith row of eigs_excess by ith column of zeds,
                    %reshaped to take the ppropriate multiplication
                    
                    for i=1:size(excess_times,2)
                        pdfs(i,:,:)=reshape(eigs_excess(i,:)*reshape(zeds(:,i),size(Z10,1),size(Z10,2)*size(Z10,3)),size(Z10,2),size(Z10,3)) ;
                    end
                    
                    
                else
                    pdfs = (Z10+Z11*excess_times) *  exp(eigvals * excess_time);
                end                                   
            end
        end
        
        function pdf = asymptotic(excess_time,AR,roots,QXY ,expYY)
            density=reshape(AR.mat*exp(roots *excess_time),AR.size(2),AR.size(3));
            %density=reshape(reshape(AR,size(AR,1)*size(AR,2),size(AR,3))*exp(roots *excess_time),size(AR,2),size(AR,3));
            pdf=density*QXY*expYY;        
        end
        
        function pdfs = asymptotic_vectorised(excess_times,AR,roots,QXY ,expYY)
            if (length(excess_times)==1)
                pdfs= ExactLikelihood.asymptotic(excess_times,AR,roots,QXY ,expYY);
            else 
                pdfs=reshape(reshape((AR.mat*exp(roots *excess_times))',size(excess_times,2)*AR.size(2),AR.size(3))*QXY*expYY,size(excess_times,2),size(QXY,1),size(expYY,1));
            end
            
        end
        
        function density = exact_pdf(eig_valsQ,AR,roots,Z00,Z10,Z11,t,tres,Qxy,exp_xx)
            if t < (2 * tres)
                %1st piecewise solution
                density=ExactLikelihood.f0(t-tres,eig_valsQ,Z00);
            elseif t < (3 * tres)
                %2nd piecewise solution
                density=ExactLikelihood.f0(t-tres,eig_valsQ,Z00)-ExactLikelihood.f1(t-(2*tres),eig_valsQ, Z10, Z11);
            else
                %asymptotic solution
                density = ExactLikelihood.asymptotic((t - tres),AR,roots,Qxy,exp_xx);

            end
                        
        end
        
        function density = exact_pdf_vectorised(eig_valsQ,AR,roots,Z00,Z10,Z11,t,tres,Qxy,exp_xx)
            first_times =  t < (2 * tres);  
            second_times = t >=(2*tres) & t < (3 * tres);
            asymptotic_times = t >= (3 * tres);
            
            
            first_densities = ExactLikelihood.f0_vectorised(t(first_times)-tres,eig_valsQ,Z00);           
            second_densities=ExactLikelihood.f0_vectorised(t(second_times)-tres,eig_valsQ,Z00)-ExactLikelihood.f1_vectorised(t(second_times)-(2*tres),eig_valsQ,Z10,Z11);
            asymptotic_densities=ExactLikelihood.asymptotic_vectorised(t(asymptotic_times)-tres,AR,roots,Qxy ,exp_xx);
                     
            density=zeros(length(t),size(first_densities,2),size(first_densities,3));
            density(first_times,:,:)=first_densities;
            density(second_times,:,:)=second_densities;
            density(asymptotic_times,:,:)=asymptotic_densities;
            
            
        end
        
        function density = exact_close_pdf(obj,t)
            if t < (2 * obj.tres)
                %1st piecewise solution
                density=obj.f0(t-obj.tres,obj.eig_valsQ,obj.FZ00);
            elseif t < (3 * obj.tres)
                %2nd piecewise solution
                density=obj.f0(t-obj.tres,obj.eig_valsQ,obj.FZ00)-obj.f1(t-(2*obj.tres),obj.eig_valsQ, obj.FZ10, obj.FZ11);
            else
                %asymptotic solution0
                density = obj.asymptotic((t - obj.tres),obj.f_AR,obj.closed_roots,obj.Q_rep.Q_FA,obj.expAA);

            end
                        
        end
        
        function density = exact_open_pdf(obj,t)
            if t < (2 * obj.tres)
                %1st piecewise solution
                density=obj.f0(t-obj.tres,obj.eig_valsQ,obj.AZ00);
            elseif t < (3 * obj.tres)
                %2nd piecewise solution
                density=obj.f0(t-obj.tres,obj.eig_valsQ,obj.AZ00)-obj.f1(t-(2*obj.tres),obj.eig_valsQ, obj.AZ10, obj.AZ11);
            else
                %asymptotic solution

                density = obj.asymptotic((t - obj.tres),obj.a_AR,obj.open_roots,obj.Q_rep.Q_AF,obj.expFF);

            end
                        
        end
        

        
        
    end

end
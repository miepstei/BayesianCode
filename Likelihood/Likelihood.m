classdef Likelihood
    %this is a base class implementing features of a likelihood given a mechanism 
    %such as calculate_likelihood() etc
    %TODO: consider making this a figure object i.e. singleton
    
    properties
        
        
    end
    
    methods (Access=public)
        
        function obj = Likelihood()
           % class constructor

        end
        
        %a function to calculate the basic (CH 1982) likelihood of a recording with a given
        %set of rates
        
        %We ignore missed events, CHS vectors etc, just a basic likelihood.
        
        function test=test_log_mult(obj,A,B)
            test=obj.mat_log_multiplication(A,B);           
        end
        
        function calculate_likelihood(time)
            %be be overridden by sub-classes 
        end
        
        function evaluate_function(params,function_opts)
            %to be overridden by subclasses
            
        end
        
        function lik = threaded_hjc_lik(obj, mech , recording)
            
            %likelihood is \phi_O*G_{OC}(t_1)*G_{CO}(t_2)....*U_{C}
            
            mech=mech.partitionQ;
            
            %equilibrium states
            S=mech.Q;
            S(:,length(S)+1)=1;
            equil_states=sum(inv(S*S'),2);
          
            %need G_{OC} and G_{CO} - P( transitioning from
            %an open to a shut state | transition occurs)
            %G_AB=obj.mat_lap_exponential(mech.Q_AA,mech.Q_AB,0);
            %G_BA=obj.mat_lap_exponential(mech.Q_BB,mech.Q_BA,0);
            
            %exponentiate them for calculating the equilibrium state
            %open and shut distibutions
            
            %TEST MATRIX - ignore
            %testQ=mech.Q*0.001;
            
            
            %[spec,eig_vals,eig_vects]=obj.spectral_expansion(-mech.Q_FF);
            %exp = obj.mat_exponentiation(-eig_vals,spec);
            %[spec,eig_vals,eig_vects]=obj.spectral_expansion(-mech.Q_AA); 
            %exp = obj.mat_exponentiation(-eig_vals,spec);
            
            
            % we should probably discard the first and last sojourns as
            % they are of indeterminant length
            

            
            [specF,eig_valsF,eig_vectsF]=obj.spectral_expansion(-mech.Q_FF);
            [specA,eig_valsA,eig_vectsA]=obj.spectral_expansion(-mech.Q_AA);
            close=0;
            open=0;            
            %loop over the recording and calculate the pdf
            
            
            closed_sojourns=recording.intervals(recording.amplitudes == 0);
            open_sojourns=recording.intervals(recording.amplitudes ~= 0);
            
            close_to_open_sojourn_pdf=zeros(max(size(mech.Q_FA)),length(closed_sojourns));
            parfor i=1:length(closed_sojourns)
                close_to_open_sojourn_pdf(:,i)= log(obj.mat_exponentiation(-eig_valsF,specF,closed_sojourns(i))*mech.Q_FA)';
                
            end
            
            open_to_close_sojourn_pdf=zeros(length(open_sojourns),max(size(mech.Q_AF)));
            
            parfor i=1:length(open_sojourns)
                open_to_close_sojourn_pdf(i,:)=log(obj.mat_exponentiation(-eig_valsA,specA,open_sojourns(i))*mech.Q_AF);
            end
            
            %lik=log(start_vec')*
            
            if recording.amplitudes(1) == 0
                start_vec=equil_states(mech.kA+1:end);
                lik=log(start_vec)';
                for i=1:recording.points/2
                   lik=obj.mat_log_multiplication(lik,close_to_open_sojourn_pdf(:,i));
                   lik=obj.mat_log_multiplication(lik,open_to_close_sojourn_pdf(i,:));
                end
            else
                start_vec=equil_states(1:mech.kA);
                lik=log(start_vec);
                for i=1:recording.points/2                    
                   lik=obj.mat_log_multiplication(lik,open_to_close_sojourn_pdf(i,:));
                   lik=obj.mat_log_multiplication(lik,close_to_open_sojourn_pdf(:,i));
                end
            end
            
            if recording.amplitudes(end) == 0
                end_vec=ones(mech.kA,1);
            else
                end_vec=ones(mech.kB,1);
            end
            
            %lik=log(start_vec');
            end_vec=log(end_vec);
            

            if ~isscalar(end_vec)
                %need matrix multiplication in log space to sum up
                lik=obj.mat_log_multiplication(lik,end_vec);
            else
                lik=lik+end_vec;
            end
            if(lik==-Inf)
               disp(lik); 
            end
            
        end
        
        function [lik,time] = basic_hjc_lik(obj, mech ,conc , recording)
            
            %likelihood is \phi_O*G_{OC}(t_1)*G_{CO}(t_2)....*U_{C}
            
            %mech=mech.partitionQ;
            Q_rep = mech.setupQ(conc);
            
            
            %equilibrium states
            S=Q_rep.Q;
            S(:,length(S)+1)=1;
            equil_states=sum(inv(S*S'),2);
          
            %need G_{OC} and G_{CO} - P( transitioning from
            %an open to a shut state | transition occurs)
            %G_AB=obj.mat_lap_exponential(mech.Q_AA,mech.Q_AB,0);
            %G_BA=obj.mat_lap_exponential(mech.Q_BB,mech.Q_BA,0);
            
            %exponentiate them for calculating the equilibrium state
            %open and shut distibutions
            
            %TEST MATRIX - ignore
            %testQ=mech.Q*0.001;
            
            
            %[spec,eig_vals,eig_vects]=obj.spectral_expansion(-mech.Q_FF);
            %exp = obj.mat_exponentiation(-eig_vals,spec);
            %[spec,eig_vals,eig_vects]=obj.spectral_expansion(-mech.Q_AA); 
            %exp = obj.mat_exponentiation(-eig_vals,spec);
            
            
            % we should probably discard the first and last sojourns as
            % they are of indeterminant length
            
            if recording.amplitudes(1) == 0
                start_vec=equil_states(mech.kA+1:end);                         
            else
                start_vec=equil_states(1:mech.kA);  
            end
            
            if recording.amplitudes(end) == 0
                end_vec=ones(mech.kA,1);
            else
                end_vec=ones(mech.kE,1);
            end
            
            lik=log(start_vec');
            end_vec=log(end_vec);
            
            [specF,eig_valsF,eig_vectsF]=obj.spectral_expansion(-Q_rep.Q_FF);
            [specA,eig_valsA,eig_vectsA]=obj.spectral_expansion(-Q_rep.Q_AA);
            tradElapsed=0;

            %loop over the recording and calculate the pdf
            for (i=1:recording.points)
                sojourn_time = recording.intervals(i);
                if recording.amplitudes(i) == 0
                    try 
                        
                        sojourn_pdf = obj.mat_exponentiation(-eig_valsF,specF,sojourn_time)*Q_rep.Q_FA;     
                    catch err
                        disp(err)
                    end
                else
                    try                        
                        sojourn_pdf = obj.mat_exponentiation(-eig_valsA,specA,sojourn_time)*Q_rep.Q_AF;
                    catch err
                        disp(err) 
                    end
                end
                
                
                traditional=tic;
                lik=obj.mat_log_multiplication(lik,log(sojourn_pdf));
                tradElapsed = tradElapsed+toc(traditional);
            end
            if ~isscalar(end_vec)
                traditional=tic;
                %need matrix multiplication in log space to sum up
                lik=obj.mat_log_multiplication(lik,end_vec);
                tradElapsed = tradElapsed+toc(traditional);
            else
                lik=lik+end_vec;
            end

            time=tradElapsed;

            if(lik==-Inf)
               disp(lik); 
            end
            
        end
               
        function [lik,time,matExpElapsed] = basic_hjc_lik_cpp(obj, mech ,conc, recording)
            
            %likelihood is \phi_O*G_{OC}(t_1)*G_{CO}(t_2)....*U_{C}
            
            %Q=Q.partitionQ;
            Q_rep = mech.setupQ(conc);
            
            %equilibrium states
            S=Q_rep.Q;
            S(:,length(S)+1)=1;
            equil_states=sum(inv(S*S'),2);
          
            %need G_{OC} and G_{CO} - P( transitioning from
            %an open to a shut state | transition occurs)
            %G_AB=obj.mat_lap_exponential(mech.Q_AA,mech.Q_AB,0);
            %G_BA=obj.mat_lap_exponential(mech.Q_BB,mech.Q_BA,0);
            
            %exponentiate them for calculating the equilibrium state
            %open and shut distibutions
            
            %TEST MATRIX - ignore
            %testQ=mech.Q*0.001;
            
            
            %[spec,eig_vals,eig_vects]=obj.spectral_expansion(-mech.Q_FF);
            %exp = obj.mat_exponentiation(-eig_vals,spec);
            %[spec,eig_vals,eig_vects]=obj.spectral_expansion(-mech.Q_AA); 
            %exp = obj.mat_exponentiation(-eig_vals,spec);
            
            
            % we should probably discard the first and last sojourns as
            % they are of indeterminant length
            
            if recording.amplitudes(1) == 0
                start_vec=equil_states(mech.kA+1:end);                         
            else
                start_vec=equil_states(1:mech.kA);  
            end
            
            if recording.amplitudes(end) == 0
                end_vec=ones(mech.kA,1);
            else
                end_vec=ones(mech.kE,1);
            end
            
            lik=log(start_vec');
            end_vec=log(end_vec);
            
            [specF,eig_valsF,eig_vectsF]=obj.spectral_expansion(-Q_rep.Q_FF);
            [specA,eig_valsA,eig_vectsA]=obj.spectral_expansion(-Q_rep.Q_AA);
            tradElapsed=0;
            matExpElapsed=0;
            
            %we need to calculate the pdfs of the open and shut sojourns
            %openpdfs=zeros(length)
            closed_exp = obj.vectorised_mat_exp(-eig_valsF,specF,recording.intervals((recording.amplitudes == 0))');
            %closed_pdfs = log(reshape(reshape(closed_exp,[size(closed_exp,1) size(closed_exp,2)*size(closed_exp,3)])'*Q_rep.Q_FA,[ size(Q_rep.Q_FA,1) size(closed_exp,3)]));           
            closed_pdfs = log(permute(reshape((reshape(reshape(permute(closed_exp, [2 1 3]), [size(closed_exp,1) size(closed_exp,2)*size(closed_exp,3)]), [size(closed_exp,2) size(closed_exp,1)*size(closed_exp,3)])'*Q_rep.Q_FA)',[size(Q_rep.Q_FA,2) size(closed_exp,1) size(closed_exp,3) ]),[2 1 3]));
            open_exp = obj.vectorised_mat_exp(-eig_valsA,specA,recording.intervals((recording.amplitudes ~= 0))');
            open_pdfs = log(permute(reshape((reshape(reshape(permute(open_exp, [2 1 3]), [size(open_exp,1) size(open_exp,2)*size(open_exp,3)]), [size(open_exp,2) size(open_exp,1)*size(open_exp,3)])'*Q_rep.Q_AF)',[size(Q_rep.Q_AF,2) size(open_exp,1) size(open_exp,3) ]),[2 1 3]));

            %loop over the recording and calculate the pdf
            for (i=1:recording.points)
                sojourn_time = recording.intervals(i);
                if recording.amplitudes(i) == 0
                    try 
                        f=tic;
                        sojourn_pdf = closed_pdfs(:,:,ceil(i/2));
                        %disp(obj.mat_exponentiation(-eig_valsF,specF,sojourn_time)*mech.Q_FA-sojourn_pdf);     
                        matExpElapsed=matExpElapsed+toc(f);
                    catch err
                        disp(err)
                    end
                else
                    try  
                        f=tic;
                        sojourn_pdf = open_pdfs(:,:,ceil(i/2));
                        %disp(obj.mat_exponentiation(-eig_valsA,specA,sojourn_time)*mech.Q_AF-sojourn_pdf);
                        matExpElapsed=matExpElapsed+toc(f);
                    catch err
                        disp(err) 
                    end
                end
                
                
                traditional=tic;
                %lik=obj.mat_log_multiplication(lik,sojourn_pdf);
                lik=lm(lik,sojourn_pdf);
                tradElapsed = tradElapsed+toc(traditional);
                
            end
            if ~isscalar(end_vec)
                traditional=tic;
                %need matrix multiplication in log space to sum up
                lik=lm(lik,end_vec);
                %lik=obj.mat_log_multiplication(lik,end_vec);
                tradElapsed = tradElapsed+toc(traditional);
            else
                lik=lik+end_vec;
            end

            time=tradElapsed;

            if(lik==-Inf)
               disp(lik); 
            end
            
        end
        
        function openPdf = calcOpenPdf(obj,mech)
            sojourn_times=0.001:0.001:0.01;           
            [specF,eig_valsF,eig_vectsF]=obj.spectral_expansion(-mech.Q_FF);
            openPdf=obj.vectorised_mat_exp(-eig_valsF,specF,sojourn_times).*mech.Q_FA;
            
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
                
        function [spect_mat,vals,vecs] = spectral_expansion(obj,m)
            [vecs vals]=eig(m);
            
            [eig_vec,order]=sort(diag(vals),'ascend');
            vecs=vecs(:,order);
            
            %TODO: refactor this and have a think if we really want the
            %eigenvalues in a two-dimensional matrix
            vals=diag(sort(diag(vals),'ascend'));
            inv_vecs=vecs^-1;
            inv_vecs=vecs\speye(size(vecs));
            spect_mat=zeros(size(m,1),size(m,1),size(m,1));

            for i=1:size(m,1)
                spect_mat(i,:,:) = vecs(:,i)*inv_vecs(i,:);
            end       
        end
        
        function mat_exp = vectorised_mat_exp(obj,eigs,spec,times)
           
           mat_exp=zeros(size(eigs,1),size(eigs,2),length(times));
           for i=1:size(eigs,1)
                mat_exp=mat_exp+reshape(reshape(spec(:,:,i),size(spec,1)*size(spec,2),1)*exp(times*eigs(i,i)'),[size(spec,1) size(spec,2) length(times)]);    
           end
        end
         
        function mat_exp = mat_exponentiation(obj, eigs,spec,time)
            
            mat_exp=zeros(size(eigs));
            
            
            for i=1:size(eigs,1)
                 mat_exp=mat_exp+(reshape(spec(i,:,:),size(spec,2),size(spec,3))*exp(time*eigs(i,i)));   
            end
            %mat_exp2=d3(spec,diag(eigs),time);
            %if mat_exp-mat_exp2 > 10^-15
            %    disp(mat_exp-mat_exp2)
            %end
            
        end
        
    end
    
    
    
    methods(Access=private)
        function lp_tf=mat_lap_exponential(obj,within,between,s)
            %lp transform is given by (sI-Q_{OO})^-1*Q_{OC}
            %within is a square matrix e.g. Q_{OO}
            %between is a O by C matrix e.g. Q_{OC}
            %s is the lp parameter
            
            lp_tf=(s.*(ones(size(within)))-within)^(-1)*between;
                 
        end
        
        function log_matrix = mat_log_multiplication(obj,lA,lB)
            %performs matrix multiplication in log space, ie log(A*B). lA
            %and lB are matrices in log-space already
            
            if(size(lA,2) ~=size(lB,1))
               disp('[Error] Inner dimensions do not agree!!') 
               return
            end
                
                
            
            log_matrix = zeros(size(lA,1),size(lB,2));
            for i=1:size(lA,1)
                for j=1:size(lB,2)
                    a=lA(i,:);
                    b=lB(:,j);
                    %product=zeros(size(a,2),1);
                    product=a'+b;
                    %for k=1:size(a,2)
                    %    product(k)=a(k)+b(k);
                    %end
                    
                    if all(isinf(product))
                        %we have all -Inf in the logs for the multiplication
                        elem_log=-Inf;
                    else
                        product=sort(product,'descend');
                        %t_sum=0;
                        %for m=2:length(product)
                        t_sum=sum(exp(product(2:end)-product(1)));
                        %end
                        elem_log=product(1)+log(1+t_sum);
                    end
                    
                    log_matrix(i,j) = elem_log;
                end
            end

        end  
    end
    
end
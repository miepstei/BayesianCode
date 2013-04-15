classdef MetropolisHastingsSampler
    properties
        
        
    end
    
    
    methods (Access=public)
        function obj = MetropolisHastingsSampler()
            %constructor
        end
        
        function [samples,cTime,eTime] = sample(obj,mech,steps,sigma,lik,rec)
            
            new_mech=mech;
            
            free_rates=length(new_mech.getUnconstrainedRates);
            sample_rates=zeros(steps,free_rates);
            likelihoods=zeros(steps,free_rates);
            
            %[17,14000,2500,450,9,40,0.5]
            sample_rates(1,:)=[mech.getUnconstrainedRates().rate_constant];%;
            %sample_rates(1,:)=[10,10,10,10,10,10,10];
            sample_sigmas=repmat(sigma,free_rates,1);
            burnin_lag=25;
            burnin_lock=zeros(free_rates,1);         
            acceptance=zeros(steps,free_rates);
            proposals=zeros(steps,free_rates);
            acceptance(1,:)=1;
            likelihoods(1,:)=lik.basic_hjc_lik_cpp(new_mech,rec);
            %loop_rates = sample_rates(1,:);
            eTime=0;cTime=0;
            for step=2:steps

                %generate rate proposals
                sample_rates(step,:)=sample_rates(step-1,:);
                for r=1:length(sample_rates(step-1,:))
                    
                    curr_mech=new_mech.setEstimatedRates(sample_rates(step,:));
                    curr_mech=curr_mech.refreshRates();    

                    [curr_lik t e]=lik.basic_hjc_lik_cpp(curr_mech,rec);
                    cTime=cTime+t;
                    eTime=eTime+e;
                   
                    
                    prop_rate=normrnd(log(sample_rates(step,r)),sample_sigmas(r));

                    proposals(step,r)=exp(prop_rate);
                    sample_rates(step,r)=exp(prop_rate);
                    proposal_mech=new_mech.setEstimatedRates(sample_rates(step,:));
                    proposal_mech=proposal_mech.refreshRates();
                   
                    prop_lik=lik.basic_hjc_lik_cpp(proposal_mech,rec);

                    %not strictly necessary as we are using a symmetric
                    %(Normal) proposal density
                    %ratio = normrnd(prop_a,a(i-1)*shape,1/shape)./normrnd(a(i-1),prop_a*shape,1/shape);

                    %accept/reject
                    alpha = min(0,(prop_lik-curr_lik));%+(log(prob_a)-log(prob_b)));
                    acc=log(rand);     

                    if alpha > acc                      
                        acceptance(step,r)=1;
                        likelihoods(step,r)=prop_lik;                       
                    else                        
                        sample_rates(step,r)=sample_rates(step-1,r);                       
                        likelihoods(step,r)=likelihoods(step-1,r);
                        acceptance(step,r)=0;
                        %disp(sprintf('%d steps performed. Log-lik = %d alpha = %d',step,likelihoods(step),alpha))
                    end
                    
                    if(step <= 500 && step>burnin_lag )
                        
                        if burnin_lock(r)==0 && mod(step,burnin_lag) == 0
                            acceptance_ratio = sum(acceptance([step-burnin_lag+1:step],r))/burnin_lag;
                            if step == 500
                                burnin_lock(r)=step;
                            else
                                if acceptance_ratio < 0.2
                                    sample_sigmas(r)=sample_sigmas(r)*0.9;
                                    disp(sprintf('Acceptance: %d Sigma decreased to %d for parameter %d at %d iterations',acceptance_ratio,sample_sigmas(r),r,step))
                                elseif acceptance_ratio > 0.4
                                    sample_sigmas(r)=sample_sigmas(r)*1.1;
                                    disp(sprintf('Acceptance: %d Sigma increased to %d for parameter %d at %d iterations',acceptance_ratio,sample_sigmas(r),r,step))
                                else
                                    burnin_lock(r)=step;
                                    disp(sprintf('Burnin for parameter %d locked at %d at %d iterations',r,sample_sigmas(r),step))
                                end
                            end
                        end
                    end
                                        
                end
                %new_mech=new_mech.setEstimatedRates(sample_rates(step,:));
                if mod(step, 100) ==0
                    disp(sprintf('%d steps performed. Log-lik = %d',step,likelihoods(step)))
                    disp(sample_rates(step,:))
                end                
            end

            
            
            samples=struct('params',sample_rates,'N', steps,'likelihoods',likelihoods,'finalQ',curr_mech,'proposals',proposals);
        end
        
        
    end
    
    
    
    
end

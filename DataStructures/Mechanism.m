classdef Mechanism
    %this is an internal representation of a mechanism from a 'mec' file
    
    properties
        rates; %Map of rate objects (int unique_id,Rate rate)
        q_coordinates; %Map of rate cordinates in the Q-matrix (int unique_id,vec[row,col])
        states; %ordered vector of states
        names; %ordered vector of state names
        effectors; %map of ligands which can be bound to rates
        constraints; %map of which rates are constrained to which others, int rate_id,struct Constraint
        parameterMap; %a map of unconstrained rates
        
        fastblk=0; %to be implemented
        KBlock=NaN; %to be implemented
        name='some_name';
        
        %struct of cycles in mechanisms
        cycles;
        
        %substates of the Q matrix
        kA=0;
        kB=0;
        kC=0;
        kD=0;
        
        kE=0; % shut states (kA+kB)
        kF=0; %open and short shut states
        
        k=0; % total number of states
        

    end
    
    
    methods
        function obj=Mechanism(rates,cycles,constraints,name)
            obj.rates=containers.Map('KeyType', 'int32','ValueType','any');
            obj.parameterMap=containers.Map('KeyType', 'int32','ValueType','any');
            obj.q_coordinates=containers.Map('KeyType', 'int32','ValueType','any');
            obj.cycles=cycles;
            obj.effectors=containers.Map();
            obj.constraints=constraints;
            obj.name = name;
            names={};
            %build up a map of the states from the rate array
            rates_found=1;
            for i=1:length(rates)
                obj.rates(rates(i).rate_id)=rates(i);
                if ~ismember(rates(i).state_from.name,names)               
                    types(rates_found,1)=rates(i).state_from;
                    names{rates_found,1}=rates(i).state_from.name;
                    rates_found=rates_found+1;          
                end
                
                rate_effectors=rates(i).eff;
                for j=1:length(rate_effectors)
                    effector=rate_effectors(j);
                    if ~obj.effectors.isKey(effector) && ~isempty(effector)
                        obj.effectors(effector)=1;    
                    end
                end
                
                if ~(rates(i).mr || isKey(constraints,rates(i).rate_id))
                    %add to the parameter space if it is unknown
                    if ~obj.parameterMap.isKey(rates(i).rate_id)
                        obj.parameterMap(rates(i).rate_id) = rates(i);
                    end                   
                end
                
            end
            

            
            %Lets sort out the cycles in the mechanism
            states_from=[rates(:).state_from];
            states_to=[rates(:).state_to];
            
            
            for cycle=1:length(obj.cycles)
                obj.cycles(cycle).shiftStates=circshift(obj.cycles(cycle).states,[0 1]);
                obj.cycles(cycle).forwardRateIds=zeros(length(obj.cycles(cycle).shiftStates),1);
                obj.cycles(cycle).backwardRateIds=zeros(length(obj.cycles(cycle).shiftStates),1);     
                
                for rate=1:length(obj.cycles(cycle).shiftStates)                    
                    %get some logical arrays where a given rate connects
                    %two states. The backarray captures the rate going in
                    %the opposite direcion between the two states
                    fwdrate = rates((ismember({states_from.name},obj.cycles(cycle).states(rate)) + ismember({states_to.name},obj.cycles(cycle).shiftStates(rate)))==2);
                    bckrate = rates((ismember({states_to.name},obj.cycles(cycle).states(rate)) + ismember({states_from.name},obj.cycles(cycle).shiftStates(rate)))==2);
                    obj.cycles(cycle).forwardRateIds(rate,1) = fwdrate.rate_id;
                    obj.cycles(cycle).backwardRateIds(rate,1) = bckrate.rate_id;                   
                end
            end
            
            
            
            %now lets classify the states according to their type
            
            %sort the states by their substates in the Q matrix
            [~,idx]=sort([types.ord]);          
            obj.states=types(idx);
            obj.names=names(idx);
            
            %Build up the index positions each rate has in the Q-matrix
            
            for i=1:length(rates)
               [~,row]=ismember(rates(i).state_from.name,obj.names);
               [~,col]=ismember(rates(i).state_to.name,obj.names);
               obj.q_coordinates(rates(i).rate_id)=[row,col];
            end
            
            obj.kA=sum([types.type]=='A');
            obj.kB=sum([types.type]=='B');
            obj.kC=sum([types.type]=='C');
            obj.kD=sum([types.type]=='D');
            
            obj.kE=obj.kB+obj.kC;
            obj.kF=obj.kA+obj.kB;
            
            obj.k=length(obj.states);
            
        end
        
        function mechStr = toString(obj)
            %prints a human readable representation of the mechanism
            mechStr=sprintf('Mechanism name %s',obj.name);
            
            
            mechStr=strcat(mechStr,sprintf('\n\n%i Rates\n\n',obj.rates.length()));
            keys = obj.rates.keys();
            for i=1:length(keys)
                rate = obj.rates(keys{i});       
                mechStr=strcat(mechStr,sprintf('\n\tRate name %s - value %f\n',rate.name,rate.rate_constant));              
            end
            
            mechStr=strcat(mechStr,sprintf('\n\n%i Parameters\n\n',obj.parameterMap.length()));
            keys = obj.parameterMap.keys();
            for i=1:length(keys)
                rate = obj.parameterMap(keys{i});       
                mechStr=strcat(mechStr,sprintf('\n\tRate name %s - value %f\n',rate.name,rate.rate_constant));              
            end            
            
            
            mechStr=strcat(mechStr,sprintf('\n\n%i Constraints\n\n',obj.constraints.length()));
            keys = obj.constraints.keys();
            for i=1:length(keys)
                constraint = obj.constraints(keys{i});
                rate = obj.rates(keys{i});
                if strcmp(constraint.type,'dependent')
                    rateTo = obj.rates(constraint.rate_id);
                    mechStr=strcat(mechStr,sprintf('\n\tConstraint name %s - type %s  on rate %s factor %i\n',rate.name,constraint.type,rateTo.name,constraint.args));             
                elseif strcmp(constraint.type,'mr')
                    mechStr=strcat(mechStr,sprintf('\n\tConstraint name %s - type %s  cycle number %i\n',rate.name,constraint.type,constraint.cycle_no));                                 
                end         
            end             
        end
        
        function [fwd bwd] = calcMR(obj,cycle_no)
            
            fwd=1;
            bwd=1;
            for rate=1:length(obj.cycles(cycle_no).shiftStates)
                fwd=fwd*obj.rates(obj.cycles(cycle_no).forwardRateIds(rate,1)).rate_constant;
                bwd=bwd*obj.rates(obj.cycles(cycle_no).backwardRateIds(rate,1)).rate_constant;
            end
        end
        
                
        function Qmat=setupQ(obj,conc)
            %this is a public function for returning a Q-matrix with the
            %relevent effector applied %TODO: this assumes a
            %multiplicative impact of the effector on %the rate...
            Qmat=Qmatrix(obj.rates,obj.q_coordinates,conc,obj.names,obj.k,obj.kA,obj.kB,obj.kC,obj.kD,obj.kE,obj.kF);

            
        end
        
        function obj=setConstraint(obj,rate_id,constraint)
            %public function to allow the importation of mec files whilst
            %post-hoc setting constraints akin to parsing ini files.
            %constraints are of the form - containers.Map('KeyType', 'int32','ValueType','any');
            %value = struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',5,'args',2);
            obj.constraints(rate_id) = constraint;
            
            %if it is a constraint it cannot be a parameter...
            if obj.parameterMap.isKey(rate_id)
                obj.parameterMap.remove(rate_id);
            end            
            
            
        end
        
        
        function obj=removeConstraint(obj,rate_id)
            %public function to allow the importation of mec files whilst
            %post-hoc setting constraints akin to parsing ini files.
            %constraints are of the form - containers.Map('KeyType', 'int32','ValueType','any');
            %value = struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',5,'args',2);
            obj.constraints.remove(rate_id);
            if ~obj.parameterMap.isKey(rate_id)
                obj.parameterMap(rate_id) = obj.rates(rate_id);
            end
            
        end
        
        function obj=setRate(obj,rate_id,rate_value,update_constraints)
             %set rates regardless of whether they are fixed or not
            if obj.rates.isKey(rate_id)
                rate = obj.rates(rate_id);
                rate.rate_constant=rate_value;
                obj.rates(rate_id)=rate;
                if obj.parameterMap.isKey(rate_id)
                    param_rate=obj.parameterMap(rate_id);
                    param_rate.rate_constant=rate_value;
                    obj.parameterMap(rate_id)=param_rate;
                end
                if update_constraints
                     obj=updateConstrainedRates(obj);
                    for cyc=1:length(obj.cycles)
                        obj=updateMicroscopicReversibility(obj,cyc); 
                    end                     
                end
                
            else    
                fprintf('[WARN]: Rate %s not part of rate map\n',rate_id) 
            end
        end
        
        function obj=setRates(obj,rates,update_constraints)
            %set rates regardless of whether they are fixed or not
            
            
            if length(obj.rates) == length(rates)
                for i=1:length(obj.rates)
                    rate = obj.rates(i);
                    rate.rate_constant=rates(i);
                    obj.rates(i)=rate;
                    %update parameter map
                    if obj.parameterMap.isKey(i)
                        rate=obj.parameterMap(i);
                        rate.rate_constant=rates(i);
                        obj.parameterMap(i)=rate;
                    end
                end 
                if update_constraints
                    obj=updateConstrainedRates(obj);
                    %for cyc=1:length(obj.cycles)
                    %    obj=updateMicroscopicReversibility(obj,cyc); 
                    %end
                end
            else
               fprintf('Rates objects of different lengths!\n')             
            end
            
        end
        
        %functions to manipulate parameter spaces
        
        function obj=setParameters(obj,params)
            %params is a container.Map of key=rate_id,value=rate_constant
            %(int, double)
            keySet = keys(params);
            for rate_no=1:length(keySet)
                %set parameter
                validateParam(obj,keySet{rate_no},params(keySet{rate_no}));
                updateRate(obj,keySet{rate_no});            
            end
                 
            %update constraints
            obj=updateConstrainedRates(obj);
            %for cyc=1:length(obj.cycles)
            %    obj=updateMicroscopicReversibility(obj,cyc); 
            %end
            
        end
        
        function obj=setParameter(obj,rate_id,value)
            %key -> value to be inserted into Map
            validateParam(obj,rate_id,value);
            obj=updateRate(obj,rate_id);
            obj=updateConstrainedRates(obj);
            
            %for cyc=1:length(obj.cycles)
            %    obj=updateMicroscopicReversibility(obj,cyc); 
            %end
        end
        
        function rate=getRate(obj,rate_id)
            rate=obj.rates(rate_id).rate_constant;
        end
        
        function params=getParameters(obj,log_values)
            %returns a map of rate_id,rate_constant (int,double)
            
            params = containers.Map('KeyType', 'int32','ValueType','any');
            keySet = keys(obj.parameterMap);
            
            
            for rate_no=1:length(keySet)
                temp_rate = obj.parameterMap(keySet{rate_no});
                rate_constant=temp_rate.rate_constant;
                if log_values
                    rate_constant=log(rate_constant);                    
                end
                params(keySet{rate_no})=rate_constant;
            end
        end

        
        function rates=getRates(obj)
            
            keySet = keys(obj.rates); %keys come out in alphabetical order
            rates=zeros(length(keySet),2);
            
            for key=1:length(keySet)
               key = cell2mat(keySet(key));
               rates(key,1) = key;
               rates(key,2) = obj.rates(key).rate_constant;     
            end        
        end
    
        function obj=setEstimatedRates(obj,e_rates)
            %e_rates are rate constants not marked as FIXED
            %assumes that the order of e_rates is the same as all rates.           
            er_count=1;
            for i=1:length(obj.rates)
                if ~obj.rates(i).fixed && ~obj.rates(i).is_constrained
                    obj.rates(i).rate_constant=e_rates(er_count);
                    er_count=er_count+1;
                end
            end
        end
        
        function obj=setEffector(obj,e_type,e_value)
            obj.effectors(e_type)=e_value;
        end
        
        %function orates=getRates(obj)
        %    orates = obj.rates;   
        %end            
        
        function theta=getUnconstrainedRates(obj)
            
           freeRateCnt=0;
           for i=1:length(obj.rates)
              if ~ obj.rates(i).fixed && ~ obj.rates(i).is_constrained
                  freeRateCnt=freeRateCnt+1;
                  theta(freeRateCnt)=obj.rates(i);
              end
           end
        end

        function obj=updateConstrainedRates(obj)
            %applies the constraints to the constrained rates map
            keySet = keys(obj.constraints);
            for i=1:length(keySet)
                
                constraint = obj.constraints(keySet{i});
                
                if strcmp(constraint.type,'dependent')
                    %might need to test this against rate limits
                    constraining_rate = obj.rates(constraint.rate_id);
                    constrainted_rate_constant = constraint.function(constraining_rate.rate_constant,constraint.args);
                    constrained_rate = obj.rates(keySet{i});
                    constrained_rate.rate_constant=constrainted_rate_constant;
                    obj.rates(keySet{i}) = constrained_rate;
                elseif strcmp(constraint.type,'mr')
                    %TODO:this should always be done last
                    obj=updateMicroscopicReversibility(obj,constraint.cycle_no);
                end
            end
        end       
        
    end
    
    methods(Access=private)
        function obj=validateParam(obj,key,value)
            if ~obj.parameterMap.isKey(key)
                fprintf('[WARN] trying to update unknown param %s\n',key)
                
            else
                %the parameter is known - validate against limits
                rate = obj.parameterMap(key);
                update=1;
                if ~ isempty(rate.limits)
                    if (value <= rate.limits(1) && value >= rate.limits(2))
                        fprintf('[WARN] param %s out of range %f value\n',key,value)
                        update=0;
                    end
                elseif (value <= 1e-15 || value >= 1e+10)
                        fprintf('[WARN] param %s out of  DEFAULT range %f value\n',key,value)
                        update=0;                                               
                end
                if update
                    rate.rate_constant=value;
                    obj.parameterMap(key)=rate;
                end
            end
            
        end
        
        function obj=updateRate(obj,key)
            %takes the key from the parameter map and updates the rate
            %object in the rates array
            rateKeys=keys(obj.rates);
            updateKeys=cell2mat(rateKeys(cell2mat(rateKeys)==key));
            for i=1:length(updateKeys)
                obj.rates(updateKeys(i))=obj.parameterMap(key);
            end
        end
        
        
        function obj=updateMicroscopicReversibility(obj,cycle_no)
            
            %do we have a mr_constraint?
            cycle =obj.cycles(cycle_no);
            if isfield(cycle,'mr_constrainted_rate')
                %which forward or backward array contains the constrained rate?

                fwds=cycle.forwardRateIds == cycle.mr_constrainted_rate;
                bwds=cycle.backwardRateIds == cycle.mr_constrainted_rate;

                unconstFwdRates = cycle.forwardRateIds(~fwds);
                unconstBwdRates = cycle.backwardRateIds(~bwds);
                fwdRate=1;
                bwdRate=1;

                for i=1:length(unconstFwdRates)
                    fwdRate=fwdRate*obj.rates(unconstFwdRates(i)).rate_constant;
                end

                for i=1:length(unconstBwdRates)
                    bwdRate=bwdRate*obj.rates(unconstBwdRates(i)).rate_constant;
                end            


                if sum(fwds)
                    %the forward rates array contains the fixed_mr rate  
                    mr_rate=bwdRate/fwdRate;               
                else
                    %the backwards rates array contains the fixed_mr rate
                    mr_rate=fwdRate/bwdRate;             
                end

                %might need to test this against limits
                constrained_rate = obj.rates(cycle.mr_constrainted_rate);
                constrained_rate.rate_constant=mr_rate;
                obj.rates(cycle.mr_constrainted_rate) = constrained_rate;            

                %NOTE mr rate no longer a parameter - it is a constraint.
                %obj.validateParam(cycle.mr_constrainted_rate,mr_rate)
                %obj.updateRate(cycle.mr_constrainted_rate);
            end
        end
            
    end
       
end
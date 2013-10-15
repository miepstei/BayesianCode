classdef MechanismUpdate < handle
    properties
        mechanism_name='UNKNOWN'
        
        rates; %Array of Rate objects        
        num_rates %scalar of the number of rates
        constraints % array of rate_ids which are constraints
        parameters %array of rate_ids which are parameters
        
        states;%ordered array of states in the mechanism
        
        effector_names; %cell array of effector names
        
        %Q-generation
        linear_constraint_matrix; %a #rate by #rate matrix of linear constraints
        mr_constraint_matrix; %a #rate by #rate matrix of micro-rev constraints
        effector_matrix; %a #rate by #rate by #effector matrix of rates affected by concentrations
        q_coordinates; %a structure containing rate_ids and co-ordinates in q-matrix
        
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
        function obj=MechanismUpdate(rates,cycles,constraints,name)
            %INPUTS
            %rates - array of Rate objects
            %cycles - structure (states, mr_constrained_rate) 
            %constraints - map of constraints (rate_id,struct())
            %name - the mechanism name
            
            obj.mechanism_name=name;
            obj.rates=rates;
            obj.num_rates=length(rates);
            obj.constraints = cell2mat(constraints.keys);
            obj.parameters = setdiff([rates.rate_id],obj.constraints);
            
            %build linear constraints
            obj.linear_constraint_matrix=eye(obj.num_rates);
            constraint_ids = constraints.keys;
            for i=1:constraints.Count
                con_rate = constraint_ids{i};
                constraint = constraints(con_rate);
                if strcmp('dependent',constraint.type)
                    obj.linear_constraint_matrix(con_rate,con_rate)=0; %needs to be first as can be constrained on itself!
                    obj.linear_constraint_matrix(con_rate,constraint.rate_id)=constraint.args;  
                elseif strcmp('mr',constraint.type)
                    cycles(constraint.cycle_no).mr_constrainted_rate=constraint.rate_id;
                end
            end
            
            %now work out the matrices for the concentration dependent rates
            %first work out the number of effectors
            obj.effector_names = setdiff(unique({rates.eff}),''); %remove '' as an effector
            obj.effector_matrix=zeros(obj.num_rates,obj.num_rates,length(obj.effector_names));
            for i=1:length(obj.effector_names)
                dependent_rates=strcmp({rates.eff},obj.effector_names{i});
                obj.effector_matrix(:,:,i)= diag(dependent_rates);
            end            
            
            %now work out the matrices for the mr dependent rates from the
            %cycles
            obj.mr_constraint_matrix=zeros(obj.num_rates);
            states_from=[rates(:).state_from];
            states_to=[rates(:).state_to];
            
            for cycle=1:length(cycles)
                cycles(cycle).shiftStates=circshift(cycles(cycle).states,[0 1]);
                cycles(cycle).forwardRateIds=zeros(length(cycles(cycle).shiftStates),1);
                cycles(cycle).backwardRateIds=zeros(length(cycles(cycle).shiftStates),1);     

                for rate=1:length(cycles(cycle).shiftStates)                    
                    %get some logical arrays where a given rate connects
                    %two states. The backarray captures the rate going in
                    %the opposite direcion between the two states
                    fwdrate = rates((ismember({states_from.name},cycles(cycle).states(rate)) + ismember({states_to.name},cycles(cycle).shiftStates(rate)))==2);
                    bckrate = rates((ismember({states_to.name},cycles(cycle).states(rate)) + ismember({states_from.name},cycles(cycle).shiftStates(rate)))==2);
                    cycles(cycle).forwardRateIds(rate,1) = fwdrate.rate_id;
                    cycles(cycle).backwardRateIds(rate,1) = bckrate.rate_id;                   
                end
                if isfield(cycles(cycle),'mr_constrainted_rate')
                    fwd=sum(cycles(cycle).forwardRateIds == cycles(cycle).mr_constrainted_rate);
                    if fwd
                        %fwd rates contain the constrained rate and therefore are neg in
                        %the matrix
                        obj.mr_constraint_matrix(cycles(cycle).mr_constrainted_rate,cycles(cycle).forwardRateIds(cycles(cycle).forwardRateIds~=cycles(cycle).mr_constrainted_rate))=-1;
                        obj.mr_constraint_matrix(cycles(cycle).mr_constrainted_rate,cycles(cycle).backwardRateIds)=1;
                    else
                        obj.mr_constraint_matrix(cycles(cycle).mr_constrainted_rate,cycles(cycle).forwardRateIds)=1;
                        obj.mr_constraint_matrix(cycles(cycle).mr_constrainted_rate,cycles(cycle).backwardRateIds(cycles(cycle).backwardRateIds~=cycles(cycle).mr_constrainted_rate))=-1;
                    end
                end
            end
            
            %build up a map of the states from the rate array
            state_names={};
            rates_found=1;
            for i=1:length(rates)
                if ~ismember(rates(i).state_from.name,state_names)               
                    types(rates_found,1)=rates(i).state_from;
                    state_names{rates_found,1}=rates(i).state_from.name;
                    rates_found=rates_found+1;          
                end
            end

            %sort the states by their substates in the Q matrix
            [~,idx]=sort([types.ord]);          
            obj.states=types(idx);
            ordered_names=state_names(idx);
            state_number=length(obj.states);
            
            %Build up the index positions each rate has in the Q-matrix
            obj.q_coordinates=struct();
            for i=1:length(rates)
               [~,row]=ismember(rates(i).state_from.name,ordered_names);
               [~,col]=ismember(rates(i).state_to.name,ordered_names);
               obj.q_coordinates(i).rate_id=rates(i).rate_id;
               obj.q_coordinates(i).q_co=sub2ind([state_number,state_number],row,col);
            end
        
            obj.kA=sum([types.type]=='A');
            obj.kB=sum([types.type]=='B');
            obj.kC=sum([types.type]=='C');
            obj.kD=sum([types.type]=='D');
            
            obj.kE=obj.kB+obj.kC;
            obj.kF=obj.kA+obj.kB;
            
            obj.k=length(obj.states);
            
        end
        
        function setConstraint(obj,rate_id,constrained_to_id,factor)
            %INPUTS - rate_id of the rate to be constrained
            %       - constrained_to_id: id of the rate to be constrained to
            %       - factor - linear constraint factor
            obj.linear_constraint_matrix(rate_id,rate_id)=0;
            obj.linear_constraint_matrix(rate_id,constrained_to_id)=factor;
            obj.constraints(end+1)=rate_id;
            obj.constraints=sort(obj.constraints);
            obj.parameters(obj.parameters==rate_id)=[];
        end
        
        function removeConstraint(obj,rate_id)
            %INPUTS - rate_id of the rate to be constrained
            obj.linear_constraint_matrix(rate_id,:)=0;
            obj.linear_constraint_matrix(rate_id,rate_id)=1;
            obj.constraints(obj.constraints==rate_id)=[];
            obj.parameters(end+1)=rate_id;
            obj.parameters=sort(obj.parameters);            
            
        end
        
        function updateRates(obj)
            %INPUTS 
            % obj - this
            %apply linear constraints
            initial_rates = [obj.rates.rate_constant]';
            constrained_rates=obj.linear_constraint_matrix*initial_rates;
            
            %apply mr

            mr_rates = obj.mr_constraint_matrix*log(constrained_rates);
            mr_idx = find(mr_rates);
            
            %need the result to be really accurate, e.g
            %consider exp(log(100000000))...
            if ~isempty(mr_idx)
                %if we have an mr constraint
                constrained_rates(mr_idx)=double(vpa(exp(mr_rates(mr_idx))));

                for i=1:length(constrained_rates)
                    obj.rates(i).rate_constant=constrained_rates(i);
                end
            end
            
        end
        
        function q=setupQ(obj,conc)
            %INPUTS
            %obj - this
            %conc - scalar concentration to apply to conc-dependent rates 
            
            initial_rates = [obj.rates.rate_constant]';
            
            %apply effectors
            for i=1:length(obj.effector_names)
                conc_constants = diag(obj.effector_matrix(:,:,i));
                conc_constants = conc_constants * conc;
                conc_constants(conc_constants==0)=1;
                constrained_rates=initial_rates.*conc_constants;
            end
               
            %now generate Q

            q=zeros(obj.k,obj.k);
            ids_rates=[[obj.rates.rate_id]' constrained_rates];
            q([obj.q_coordinates.q_co])=ids_rates(ids_rates([obj.q_coordinates.rate_id],1),2);

            for rows=1:size(q,1)
                q(rows,rows) = -sum(q(rows,:));
            end
            
        end
        
        function obj=setRates(obj,func_rates)
            %use with care. Used to set initial rates on the mechanism
            keys = func_rates.keys;
            for i=1:func_rates.Count
                rate = obj.rates(keys{i});
                rate_value = func_rates(keys{i});
                if ~ isempty(rate.limits)
                    lower_limit = rate.limits(1);
                    upper_limit = rate.limits(2);
                else
                    lower_limit = 1e-15;
                    upper_limit = 1e+10;                       
                end
                if (rate_value < lower_limit)
                    rate_value = lower_limit;
                    fprintf('[WARN] param %i out of range - set to LOWER (%f) value\n\n',keys{i},lower_limit)
                elseif rate_value > upper_limit
                    rate_value = upper_limit;
                    fprintf('[WARN] param %i out of range - set to UPPER (%f) value\n\n',keys{i},upper_limit)
                end                  
                obj.rates(keys{i}).rate_constant=rate_value;                   
            end
            obj.updateRates();            
            
        end
        
        function setParameters(obj,func_params)
            keys = func_params.keys;
            for i=1:func_params.Count
                if sum(obj.parameters==keys{i})
                    rate = obj.rates(keys{i});
                    rate_value = func_params(keys{i});
                    if ~ isempty(rate.limits)
                        lower_limit = rate.limits(1);
                        upper_limit = rate.limits(2);
                    else
                        lower_limit = 1e-15;
                        upper_limit = 1e+10;                       
                    end
                    if (rate_value < lower_limit)
                        rate_value = lower_limit;
                        fprintf('[WARN] param %i out of range - set to LOWER (%f) value\n\n',keys{i},lower_limit)
                    elseif rate_value > upper_limit
                        rate_value = upper_limit;
                        fprintf('[WARN] param %i out of range - set to UPPER (%f) value\n\n',keys{i},upper_limit)
                    end                  
                    obj.rates(keys{i}).rate_constant=rate_value;                   
                else 
                    fprintf('[WARN] param %i not found in mechanism parameters - ignoring\n',keys{i})
                end
            end
            obj.updateRates();
        end
        
        function mechStr=toString(obj)
            %prints a human readable representation of the mechanism
            mechStr=sprintf('Mechanism name %s',obj.mechanism_name);                 
            mechStr=strcat(mechStr,sprintf('\n\n%i Rates\n\n',length(obj.rates)));

            for i=1:length(obj.rates)
                rate = obj.rates(i);       
                mechStr=strcat(mechStr,sprintf('\n\tRate name %s - value %.16f\n',rate.name,rate.rate_constant));              
            end
            
            mechStr=strcat(mechStr,sprintf('\n\n%i Parameters\n\n',length(obj.parameters)));

            for i=1:length(obj.parameters)
                rate = obj.rates(obj.parameters(i));       
                mechStr=strcat(mechStr,sprintf('\n\tRate name %s - value %.16f\n',rate.name,rate.rate_constant));              
            end            
            
            
            mechStr=strcat(mechStr,sprintf('\n\n%i Constraints\n\n',length(obj.constraints)));
            for i=1:length(obj.constraints)
                constraint = obj.constraints(i);
                rate = obj.rates(constraint);
                mechStr=strcat(mechStr,sprintf('\n\tRate name %s - value %.16f\n',rate.name,rate.rate_constant));                  
            end               
            
        end
        
        function params = getParameters(obj,logspace)
            %
            if logspace
                params = containers.Map(obj.parameters, log([obj.rates(obj.parameters).rate_constant]), 'uniformValues',true);   
            else 
                params = containers.Map(obj.parameters, [obj.rates(obj.parameters).rate_constant], 'uniformValues',true);   
                
            end
        end
    end
    
end


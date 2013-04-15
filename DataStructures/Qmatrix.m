classdef Qmatrix
    %this is a k by k data structure which represents the mechanism in
    %computation, as well as its subpartioning. 
    
    properties
        
        Q;
        
        %submaticies of Q-matrix
        Q_AA;
        Q_AF;
        Q_FA;
        Q_FF;
            
        Q_EE;
        Q_BB;
        Q_AB;
        Q_BA;
            
        Q_BC;
        Q_AC;
        Q_CB;
        Q_CA;      
        
    end
        
    methods
        function obj=Qmatrix(rates,coordinates,conc,names,k,kA,kB,kC,kD,kE,kF)
            obj.Q=zeros(k,k);
            for i=1:rates.Count
               %[~,row]=ismember(rates(i).state_from.name,names);
               %[~,col]=ismember(rates(i).state_to.name,names);
               %apply such to rates functions here
               q_coordinate=coordinates(rates(i).rate_id);
               if rates(i).eff == 'c'
                   obj.Q(q_coordinate(1),q_coordinate(2)) = rates(i).rate_constant*conc;  
               else
                   obj.Q(q_coordinate(1),q_coordinate(2)) = rates(i).rate_constant;
               end                
                
            end
            
            for i=1:length(names)
              obj.Q(i,i)=-sum(obj.Q(i,:));             
            end
        
            obj.Q_AA=obj.Q(1:kA,1:kA);
            obj.Q_FA=obj.Q(kA+1:end,1:kA);             
            obj.Q_AF=obj.Q(1:kA,kA+1:end);                      
            obj.Q_FF=obj.Q(kA+1:end,kA+1:end);
            
            obj.Q_EE=obj.Q(kA+1:kA+kE,kA+1:kA+kE); 
            obj.Q_BB=obj.Q(kA+1:kA+kB,kA+1:kA+kB);
            obj.Q_AB=obj.Q(1:kA,kA+1:kA+kB);
            obj.Q_BA=obj.Q(kA+1:kA+kB,1:kA);
            
            obj.Q_BC=obj.Q(kA+1:kA+kB,kF+1:end);
            obj.Q_AC=obj.Q(1:kA,kF+1:end);
            obj.Q_CB=obj.Q(kF+1:end,kA+1:kA+kB);
            obj.Q_CA=obj.Q(kF+1:end,1:kA);
        end
    end
     
end
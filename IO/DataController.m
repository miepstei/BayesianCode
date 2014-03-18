classdef DataController
   %responsible for the I/O of mechanisms and recordings
   
    methods(Static=true)
        function [header,data]=read_scn_file(scn_file)
           %open an scn formatted file
           scn_handle=fopen(scn_file,'rb');

           %first read the header
           header=DataController.read_scn_header(scn_handle);

           %now read the data
           data=DataController.read_scn_data(header,scn_handle);

           fclose(scn_handle);

        end
        
        function write_scn_file(scn_handle,recording)
          %write out an scn formatted file
          
          fwrite(scn_handle,-103,'int32'); %version
          fwrite(scn_handle,154,'int32'); %offset = pre-determined from ftell+1
          fwrite(scn_handle,length(recording.intervals),'int32'); %number of intervals
          
          x=char(zeros(1,70));
          x(1:12)='ME test data';
          
          fwrite(scn_handle,x,'char'); %title made to be 70 chars
          fwrite(scn_handle,date(),'char');
          
          fwrite(scn_handle,'Data simulated in MATLAB','char'); %fits
          fwrite(scn_handle,5,'int32');
          
          
          %these are set to meaningless default values
          fwrite(scn_handle,-80,'float');
          fwrite(scn_handle,0,'int32');
          fwrite(scn_handle,5,'float');
          fwrite(scn_handle,0,'float');
          fwrite(scn_handle,-1,'float');
          fwrite(scn_handle,1,'float');
          fwrite(scn_handle,0.01,'float');
          fwrite(scn_handle,0.01,'float');
          
          %now we write the data
          
          ftell(scn_handle)

          fwrite(scn_handle,recording.intervals,'float');
          fwrite(scn_handle,recording.amplitudes,'int16');
          fwrite(scn_handle,recording.status,'int8');
          
          ftell(scn_handle)
          
          fclose(scn_handle);

        end

        function mechanisms=list_mechanisms(mecfile)
           %reads in a mec formatted file
           f = fopen(mecfile);
           
           version = fread(f,1,'int32');
           n_records = fread(f,1,'int32');
           next_rec= fread(f,1,'int32');
           last_rec = fread(f,1,'int32');
           
           %byte storage for each record
           start_rec=zeros(n_records,1);
           for i=1:n_records
               start_rec(i)=fread(f,1,'int32');    
           end
           
           for i=1:n_records
               fseek(f,start_rec(i)+3,-1);
               mec_num=fread(f,1,'int32');
               mec_title=fread(f,74,'char=>char');
               fread(f,5,'int32');
               rate_title=fread(f,74,'char=>char');
               set=struct('start',start_rec(i),'mec_num',mec_num,'mec_title',mec_title,'rate_title',rate_title);
               meclist(i)=set;
           end
           mechanisms=struct('version',version,'mec_struct',meclist,'max_mecnum',max([meclist.mec_num]));
        end
        
        function [rate_list, cycle_mechanism, ratetitle] = read_mechanism(mecfile,mec_header)
           f=fopen(mecfile);
           
           start=mec_header.start;
           fseek(f,start-1,-1);
           
           version=fread(f,1,'int32');
           mec_num=fread(f,1,'int32');
           mec_title=fread(f,74,'char=>char');
           
           %state numbers
           k = fread(f,1,'int32');
           kA = fread(f,1,'int32');
           kB = fread(f,1,'int32');
           kC = fread(f,1,'int32');
           kD = fread(f,1,'int32');
           
           if kB == 0 && version==103
              %ideosyncracy of version 103
              kB=kC-1;
              kC=1;
           end
           
           ratetitle=fread(f,74,'char=>char');
           iL=fread(f,1,'int32');
           jL=fread(f,1,'int32');
           rate_number=fread(f,1,'int32');
           connection_number=fread(f,1,'int32');
           conn_dep_number=fread(f,1,'int32');
           ligand_number=fread(f,1,'int32');
           char_def=fread(f,1,'int32');
           boundef=fread(f,1,'int32');
           cycle_number=fread(f,1,'int32');
           voltage=fread(f,1,'int32');
           volt_depend_number=fread(f,1,'int32');
           kmvast=fread(f,1,'int32');
           indmod=fread(f,1,'int32');
           parameter_number=fread(f,1,'int32');
           setq_number=fread(f,1,'int32');
           kstat=fread(f,1,'int32');
           
           jL_ch=cell(jL, iL);
           
           for j=1:jL
               iL_ch=cell(iL,1);
               for i=1:iL 
                   ch=fread(f,2,'char=>char');
                   iL_ch(i)={ch};
               end
               jL_ch(j,:)=iL_ch;          
           end
           
           %not sure we need this...just to print out states
           counter=1;
           concat_JL=cell(iL*jL,1);
           for i=1:iL
               
               for j=1:jL
                   concat_JL{counter}=jL_ch{j,i};
                   counter=counter+1;
               end            
           end
           
           %read rate constants
           
           i_rate(1:rate_number)=0;
           j_rate(1:rate_number)=0;
           
           for i=1:rate_number
               i_rate(i)=fread(f,1,'int32');             
           end
           
           for j=1:rate_number
               j_rate(j)=fread(f,1,'int32');
           end
           
           Q=zeros(k,k);
           
           for i=1:rate_number
               rate = fread(f,1,'double');
               Q(i_rate(i),j_rate(i))=rate;
           end
           
           ratename=cell(parameter_number,1);
           for i=1:parameter_number
               ratename{i}=fread(f,10,'char=>char');              
           end
           
           %read in ligand information
           
           for i=1:ligand_number
              ligname=fread(f,20,'char=>char');               
           end
           
           bound_number=zeros(ligand_number,k);
           
           for i=1:ligand_number
              for j=1:k
                  bound_number(i,j)=fread(f,1,'int32');           
              end
           end
           
           from=zeros(conn_dep_number,1);
           %conc dependent rates
           for i=1:conn_dep_number
               from(i)=fread(f,1,'int32');               
           end
           
           to=zeros(conn_dep_number,1);
           for i=1:conn_dep_number
               to(i)=fread(f,1,'int32'); 
           end
           
           %ligand bound in that transition
           lig_bound=zeros(conn_dep_number,1);
           for i=1:conn_dep_number
                lig_bound(i)=fread(f,1,'int32');               
           end
           
           %open state conductance
           conductance=zeros(kA,1);
           for i=1:kA
               conductance(i)=fread(f,1,'double'); 
           end
           
           states_cycles_conn=zeros(50,1);
           for i=1:cycle_number
               states_cycles_conn(i)=fread(f,1,'int32');
           end
           
           im=zeros(50,100);
           
           for i=1:cycle_number
               for j=1:states_cycles_conn(i)
                   im(i,j)=fread(f,1,'int32');                
               end
           end
           
           jm=zeros(50,100);
           
           for i=1:cycle_number
               for j=1:states_cycles_conn(i)
                   jm(i,j)=fread(f,1,'int32');                
               end
           end
           
           %read voltage dependent rates
           
           iv=zeros(volt_depend_number,1);
           jv=zeros(volt_depend_number,1);
           h_par=zeros(volt_depend_number,1);
           for i=1:volt_depend_number
               iv(i)= fread(f,1,'int32');
           end
           
           for j=1:volt_depend_number
               jv(i) = fread(f,1,'int32');
           end
           
           for i=1:volt_depend_number
               h_par(i)= fread(f,1,'float');
           end
           
           pstar=zeros(4,1);
           
           for i=1:4
               pstar(i)=fread(f,1,'float');
           end
           
           kmcon=zeros(9,1);
           for i=1:9
               kmcon(i) = fread(f,1,'int32');
           end
           
           
           ieq=zeros(setq_number,1);
           for i=1:setq_number
               ieq(i)= fread(f,1,'int32');
           end
           
           jeq=zeros(setq_number,1);
           for j=1:setq_number
               jeq(j)= fread(f,1,'int32');
           end
           
           ifq=zeros(setq_number,1);
           for i=1:setq_number
               ifq(i)= fread(f,1,'int32');
           end
           
           jfq=zeros(setq_number,1);
           for j=1:setq_number
               jfq(j)= fread(f,1,'int32');
           end
           
           efacq=zeros(setq_number,1);
           for i=1:setq_number
               efacq(i)= fread(f,1,'float');
           end
           
           %statenames=cell(kstat,1);
           for i=1:kstat
               statenames(i,:)=fread(f,10,'char=>char')';
           end
           
           nsub=fread(f,1,'int32');
           kstat0=fread(f,1,'int32');
           npar0=fread(f,1,'int32');
           kcon=fread(f,1,'int32');
           npar1=fread(f,1,'int32');
           ncyc0=fread(f,1,'int32');
           
           fclose(f);
           
           %finally,the onions
           %state_list=[];
           states=0;
           for i=1:kA
               states=states+1;
               state_list(i)=State('A',deblank(statenames(states,:)),conductance(states),states);             
           end
           
           for i=states+1:states+kB
               states=states+1;
               state_list(i)=State('B',deblank(statenames(states,:)),0,states);
                            
           end          
           
           for i=states+1:states+kC
               states=states+1;
               state_list(i)=State('C',deblank(statenames(states,:)),0,states);                             
           end       
           
           for i=states+1:states+kD
               states=states+1;
               state_list(i)=State('D',deblank(statenames(states,:)),0,states);                     
           end           
           
           
           %rate_list = [];
           for i=1:rate_number
                cdep = 0;
                bound = '';
                for j=1:conn_dep_number
                    if from(j) == i_rate(i) && to(j) == j_rate(i)
                        cdep = 1;
                        bound = 'c';
                    end
                end
                rate = Q(i_rate(i) , j_rate(i) );
                rate_list(i)=TransitionRate(rate, state_list(i_rate(i)),state_list(j_rate(i)), ratename{i}, bound,i);
           end
           
           %cycle states
           cycle_mechanism={};
           for i=1:cycle_number
               for j=1:states_cycles_conn(states_cycles_conn>0)
                   cycle_states{j} = deblank(state_list(im(i,j)).name);
               end
               cycle_mechanism(i).states = cycle_states;
           end
           
        end
        
        function mec=create_mechanism(mecfile,mec_header,constraints,refactor)
            %mec files don't come in with constraints so we need to add
            %these here                 
            [rate_list, cycle_mechanism, ratetitle] = DataController.read_mechanism(mecfile,mec_header);
            
            if refactor
                mec=MechanismUpdate(rate_list,cycle_mechanism,constraints,ratetitle);   
            else
                mec=Mechanism(rate_list,cycle_mechanism,constraints,ratetitle);  
            end
        end
           
        function mechanism=read_mechanism_demo(refactor)
            %this is effectively Colqhoun '82 
            ARS  = State('A', 'AR*', 60e-12,1);
            A2RS = State('A', 'A2R*', 60e-12,2);
            AR   = State('B', 'AR', 0.0,3);
            A2R  = State('B', 'A2R', 0.0,4);
            R    = State('C', 'R', 0.0,5);
           
          
           %conc=100*10^-9; %100nM
           conc=1; %concentration no longer part of mechanism 
           %only Q generation
           %define our ratelist
            
           
           a=TransitionRate(15, AR, ARS, 'beta1','',1);
           a.hasLimits=true;
           a.limits=[1e-15,1e+7];
           
           b=TransitionRate(15000, A2R, A2RS, 'beta2','',2);
           b0.hasLimits=true;
           b.limits=[1e-15,1e+7];
           
           c=TransitionRate(3000, ARS, AR, 'alpha1','',3);
           c.hasLimits=true;
           c.limits=[1e-15,1e+7];
           
           d=TransitionRate(500.0, A2RS, A2R, 'alpha2','',4);
           d.hasLimits=true;
           d.limits=[1e-15,1e+7];
           
           e=TransitionRate(2000.0, AR, R, 'k(-1)','',5);
           e.hasLimits=true;
           e.limits=[1e-15,1e+7];
           %e.is_constrained=true;
           
           f=TransitionRate(4000.0, A2R, AR, '2k(-2)','',6);
           f.hasLimits=true;
           f.limits=[1e-15,1e+7];
%           f.is_constrained=true;
%           f.con_func=@(rate,factor)rate*factor;
%           f.constrain_args=[4,2];
           
           
           %g=TransitionRate(2 * 5.0e07*conc, R, AR, '2k(+1)','');
           g=TransitionRate(1e+8*conc, R, AR, '2k(+1)','',7);
           j.hasLimits=true;
           g.limits=[1e-15,1e+10];
           g.eff='c';
           g.funct=@(rate,effector_value)rate*effector_value;
%           g.is_constrained=true;
%           g.con_func=@(rate,factor)rate*factor;
%           g.constrain_args=[8,2];
           
           %h=TransitionRate(5.0e08*conc, ARS, A2RS, 'k*(+2)','');
           h=TransitionRate(5e+8*conc, ARS, A2RS, 'k*(+2)','',8);
           j.hasLimits=true;
           h.limits=[1e-15,1e+10];
           h.eff = 'c';
           h.funct=@(rate,effector_value)rate*effector_value;
           
           %i=TransitionRate(5.0e08*conc, AR, A2R, 'k(+2)','');
           i=TransitionRate(5e+8*conc, AR, A2R, 'k(+2)','',9);
           j.hasLimits=true;
           i.limits=[1e-15,1e+10];
           i.eff='c';
           i.funct=@(rate,effector_value)rate*effector_value;
           %i.fixed=true;
           
           j=TransitionRate(0.6666666, A2RS, ARS, '2k*(-2)','',10);
           j.hasLimits=true;
           j.limits=[1e-15,1e+7];
           rate_list=[a,b,c,d,e,f,g,h,i,j];
           
           cycles=struct();
           cycles(1).states={'A2R*', 'AR*', 'AR', 'A2R'};
           cycles(1).mr_constrainted_rate=10; %rate_id of mr rate
           
           %constraints belong at the level of the mechanism - Rate has no
           %real concept of what the other rates are
           
           constraints=containers.Map('KeyType', 'int32','ValueType','any');
           constraints(6)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',5,'args',2);
           constraints(7)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',9,'args',2);
           constraints(8)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',8,'args',1); %FIXED!
           constraints(10)=struct('type','mr','function',@(rate,factor)rate,'rate_id',10,'cycle_no',1);
           
           if refactor
               mechanism=MechanismUpdate(rate_list,cycles,constraints,'FIVE STATE MODEL');
           else
               mechanism=Mechanism(rate_list,cycles,constraints,'FIVE STATE MODEL');
           end
            
        end
        
        function mechanism=read_mechanism_two_state(refactor)
            S  = State('A', 'AR*', 60e-12,1);
            R  = State('B', 'R', 0.0,2);
           
          
           %conc=100*10^-9; %100nM
           conc=1; %concentration no longer part of mechanism 
           %only Q generation
           %define our ratelist
            
           
           a=TransitionRate(15, R, S, 'beta2','',1);
           a.hasLimits=true;
           a.limits=[1e-15,1e+7];
           
           b=TransitionRate(15000, S, R, 'alpha2','',2);
           b0.hasLimits=true;
           b.limits=[1e-15,1e+7];
           
           rate_list=[a,b];
           
           cycles=struct([]);
           
           %constraints belong at the level of the mechanism - Rate has no
           %real concept of what the other rates are
           
           constraints=containers.Map('KeyType', 'int32','ValueType','any');
           
           if refactor
               mechanism=MechanismUpdate(rate_list,cycles,constraints,'FIVE STATE MODEL');
           else
               mechanism=Mechanism(rate_list,cycles,constraints,'FIVE STATE MODEL');
           end           
            
            
        end
        

        function write_mec_file(mechanism,outfile)
            %To be implemented


        end
        
    end

    methods(Access=private,Static=true)
          
        
        function header=read_scn_header(scn_handle)
            version = fread(scn_handle,1,'int32');
            offset=fread(scn_handle,1,'int32');
            n_int=fread(scn_handle,1,'int32');
            title=fread(scn_handle,70,'char=>char')';
            date=fread(scn_handle,11,'char=>char')';
            

            
            if version==-103
                %specific to this version

                tapeID=fread(scn_handle,24,'char=>char')';
                i_patch=fread(scn_handle,1,'int32');
                emem=fread(scn_handle,1,'float');
                unknown1=fread(scn_handle,1,'int32');
                avamp=fread(scn_handle,1,'float');
                rms=fread(scn_handle,1,'float');
                ffilt=fread(scn_handle,1,'float');
                calfac2=fread(scn_handle,1,'float');
                treso=fread(scn_handle,1,'float');
                tresg=fread(scn_handle,1,'float');
                header=SimulatedScnHeader(version,offset,n_int,title,date,tapeID,i_patch,emem,avamp,rms,ffilt,calfac2,treso,tresg);    
            else
               %lots more data to store from read recordings
                
            end
            
            
        end
        
        function data=read_scn_data(obj,scn_handle)
            %Read idealised data- intervals, amplitudes, flags from SCN file.
            fseek(scn_handle,obj.get_offset-1,-1);
            n_int = obj.get_nint;
            t_int = fread(scn_handle,n_int,'single');
            i_ampl = fread(scn_handle,n_int,'int16');
            i_props = fread(scn_handle,n_int,'int8');
            
            %need to check the last interval. If it is zero...
            if t_int(end) == 0 && i_props(end) ~= 8
                i_props(end)=8;
                
            else %if t_int(end) == 0
                t_int(end+1)=-1;
                i_ampl(end+1)=0;
                i_props(end+1)=8;
                n_int=n_int+1;
            end
            
        
            data=ScnRecording(t_int,i_ampl,i_props,n_int); 
        end

    end
   
end

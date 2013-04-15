function simulation=generate(mec,duration,conc)

%%Generates a simulated data file for a given mechanism
%mec - the mechanism used to generate the data
%outfile - the file name where the data is to be written
%duration - how long to simulate data for (in seconds)
%concnetration (effector)

sprintf('Generating ion-channel recording for %s mechanism in %s file',mec.name)

Q=mec.refreshRates(conc);
states=mec.states;
%derive the equilibrium occupanies to we can simulate a start position
%u_k+1(SST )^?1
S=Q;
S(:,length(S)+1)=1;
equil_states=sum(inv(S*S'),2);

current_time=0;
start_state=find(cumsum(equil_states)>=unifrnd(0,1));


state(1)=states(start_state(1));
currentIndex=start_state(1);
sojournTimes=[];
amplitudes=[];
jumps=0;
while (current_time<duration)
    jumps=jumps+1;
    %holding time is expon
    
    state(jumps)= states(currentIndex);
    periodtime=exprnd(-1/Q(currentIndex,currentIndex));
    sojournTimes(jumps)=periodtime;
    amplitudes(jumps)=state(jumps).conductance;
    current_time=current_time+periodtime;
    %calculate q(ij)/-q(ii) to get the next jump probabilities
    jumpProbabilities=Q(currentIndex,:)./-Q(currentIndex,currentIndex);
    jumpProbabilities(currentIndex)=0; %we have to jump states
    random=unifrnd(0,1);
    jumpTo=find(cumsum(jumpProbabilities)>random, 1, 'first');
    %disp(cumsum(jumpProbabilities))
    currentState=states(jumpTo);
    currentIndex=jumpTo;
           
    if mod(jumps,10) ==0
       disp (['time is now ' num2str(current_time)]); 
    end
end

status(1:jumps)=0;
% we also set all amplitudes to integers for dc-pyps
amplitudes(amplitudes~=0)=5;
sojournTimes=sojournTimes*1000; %in msec

simulation=ScnRecording(sojournTimes,amplitudes,status,jumps);
%simulation=struct('states', states, 'sojourns',sojournTimes);




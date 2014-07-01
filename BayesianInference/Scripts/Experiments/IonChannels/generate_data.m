function simulation=generate_data(params,model,conc,required_transitions)

%%Generates a simulated data file for a given mechanism
%model - the model used to generate the data
%simulation - the file name where the data is to be written
%intervals - how many open and closed transitions
%concnetration (effector)

sprintf('Generating ion-channel recording for %s mechanism ',class(model))
Q=model.generateQ(params,conc);

%derive the equilibrium occupanies to we can simulate a start position
%u_k+1(SS' )^-1
S=Q;
S(:,length(S)+1)=1;
equil_states=sum(inv(S*S'),2);
disp(equil_states)

current_time=0;
random=unifrnd(0,1);
currentState=find(cumsum(equil_states)>=random,1, 'first');

sojournTimes=[];
amplitudes=[];
intervals=0;

observedSojournTimes=zeros(1,required_transitions);
observedAmplitudes=zeros(1,required_transitions);

currentObservedSojourn = 0;
observed_transitions = 0;
while (required_transitions > observed_transitions )
    intervals=intervals+1;
   
    %amount of time the process stays in the current state
    interval_time=exprnd(-1/Q(currentState,currentState));
    sojournTimes(intervals)=interval_time;
    
    %open states at top left have positive conductance
    amplitudes(intervals)= (currentState <= model.kA);% state(jumps).conductance;
    
    %current 'time' of the generation process
    current_time=current_time+interval_time;
    
    %calculate q(ij)/-q(ii) to get the next jump probabilities
    jumpProbabilities=Q(currentState,:)./-Q(currentState,currentState);
    jumpProbabilities(currentState)=0; %we have to jump states
    random=unifrnd(0,1);
    
    %update the current state
    previousState=currentState;
    currentState=find(cumsum(jumpProbabilities)>random, 1, 'first');

    %if this is not the first transiton and if the state to which the process has jumped has a difference
    %conductance then close off the observed sojourn
    if (currentState <= model.kA) ~= (previousState <= model.kA)
          observed_transitions=observed_transitions+1;
          observedSojournTimes(observed_transitions)= currentObservedSojourn+interval_time;
          observedAmplitudes(observed_transitions)=(previousState <= model.kA);
          currentObservedSojourn = 0;
    else
        %extend the current duration of the observable process i.e. open or closed
        currentObservedSojourn = currentObservedSojourn + interval_time;
    end
    if mod(intervals,1000) == 0
       fprintf('Observed Transitions %i from %i jumps, current time %.2f seconds \n',observed_transitions,intervals,interval_time) 
    end

end

%we deem all our intervals as OK
status(1:required_transitions)=0;

% we also set all amplitudes to integers for dc-pyps
observedSojournTimes=observedSojournTimes*1000; %intervals in msec 
observedAmplitudes(observedAmplitudes~=0)=5;

simulation=ScnRecording(observedSojournTimes,observedAmplitudes,status,required_transitions);
fprintf('Generation finished - observed transitions %i from %i jumps, time taken %.2f seconds \n',observed_transitions,intervals,interval_time) 

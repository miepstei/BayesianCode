
clear;

model=NuclearPumpModel();
load(strcat(getenv('P_HOME'), '/BayesianInference/Data/nuclearPumpData.mat'));
startParams=[2,repmat(0.1,1,10)]';
df_step=sqrt(eps);
derv=zeros(11,2);
for i=1:11;
    keep=startParams(i);
    lu=startParams(i)+df_step;
    ld=startParams(i)-df_step;
    startParams(i)=ld;
    fd(1)=model.calcLogLikelihood(startParams,nuclearPumpData);
    startParams(i)=lu;
    fd(2)=model.calcLogLikelihood(startParams,nuclearPumpData);
    derv(i,1)=(fd(2)-fd(1))/(2*df_step);
    startParams(i)=keep;
    grads=model.calcGradLogLikelihood(startParams,nuclearPumpData);
    derv(i,2)=grads(i);
end

%prior

for i=1:11;
    keep=startParams(i);
    lu=startParams(i)+df_step;
    ld=startParams(i)-df_step;
    startParams(i)=ld;
    fd(1)=model.calcLogPrior(startParams);
    startParams(i)=lu;
    fd(2)=model.calcLogPrior(startParams);
    derv_prior(i,1)=(fd(2)-fd(1))/(2*df_step);
    startParams(i)=keep;
    grads=model.calcDerivLogPrior(startParams);
    derv_prior(i,2)=grads(i);
end

%posterior
for i=1:11;
    keep=startParams(i);
    lu=startParams(i)+df_step;
    ld=startParams(i)-df_step;
    startParams(i)=ld;
    fd(1)=model.calcLogPosterior(startParams,nuclearPumpData);
    startParams(i)=lu;
    fd(2)=model.calcLogPosterior(startParams,nuclearPumpData);
    derv_post(i,1)=(fd(2)-fd(1))/(2*df_step);
    startParams(i)=keep;
    grads=model.calcGradLogPosterior(startParams,nuclearPumpData);
    derv_post(i,2)=grads(i);
end
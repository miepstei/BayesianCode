
%alpha,beta,koff,kon
generativeParams=[1000;1000;1000;10^7]; %from Blue book
model = ThreeState_4param_QET();

%define our range of concentrations

concs=[1e-6 1e-5 1e-4 1e-3];
intervals=10000;

for i=1:length(concs)
    scnrec=generate_data(generativeParams,model,concs(i),intervals);
    fid = fopen(strcat(getenv('P_HOME'), '/BayesianInference/Data/dCK_', num2str(concs(i),'%.1e') , '.scn'),'w');
    DataController.write_scn_file(fid,scnrec);
end
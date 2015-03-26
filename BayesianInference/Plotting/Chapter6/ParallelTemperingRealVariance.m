%calculate real ml estimates 

%real_data_results = strcat(getenv('P_HOME'),{'/BayesianInference/Results/Thesis/ParallelTempering/ION_SevenState_Real_Posterior_25.h5','/BayesianInference/Results/Thesis/ParallelTempering/ION_FiveState_Real_Posterior_25.h5','/BayesianInference/Results/Thesis/ParallelTempering/ION_ThreeState_Posterior_25.h5'});
CHAINS=25;
NO_DEBUG=0;
PATH=strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/ParallelTempering/'); 

Real_data_results(1).name = strcat(PATH,'Redundant/ION_SevenState_Real_Posterior_25.h5');
Real_data_results(2).name = strcat(PATH,'ION_FiveState_Real_Posterior_25.h5');
Real_data_results(3).name = strcat(PATH,'Redundant/ION_ThreeState_Posterior_25.h5');

marginalEstimates(1) = MarginalLikelihoodEstimation(Real_data_results(1),NO_DEBUG,CHAINS);
marginalEstimates(2) = MarginalLikelihoodEstimation(Real_data_results(2),NO_DEBUG,CHAINS);
marginalEstimates(3) = MarginalLikelihoodEstimation(Real_data_results(3),NO_DEBUG,CHAINS);

FID = fopen(strcat(getenv('P_HOME'),'/../../Written/Thesis/Tables/Chapter6/MarginalLikelihoodVarianceReal.tex'), 'w');
fprintf(FID, '\\begin{tabular}{|c|c|c|}\\hline \n');
fprintf(FID, 'Model & $\\hat{log(p(y))}$ & Bayes Factor\\\\ \\hline \n');
fprintf(FID, 'Seven State & %8.2f & N/A \\\\ \\hline \n',marginalEstimates(1).mean);
fprintf(FID, 'Five State & %8.2f & %8.2f \\\\ \\hline \n',marginalEstimates(2).mean, marginalEstimates(1).mean-marginalEstimates(2).mean);
fprintf(FID, 'Three State & %8.2f & %8.2f \\\\ \\hline \n',marginalEstimates(3).mean, marginalEstimates(1).mean-marginalEstimates(3).mean);  
fprintf(FID, '\\end{tabular}\n');
fclose(FID);

%calculate the mean and variance, varying the number of chains

chain_nos = [10 25 50];

file_names{1}=dir(strcat(PATH,'ION_SevenState_Real_Posterior_10_*.h5'));
file_names{2}=dir(strcat(PATH,'ION_SevenState_Real_Posterior_25_*.h5'));
file_names{3}=dir(strcat(PATH,'ION_SevenState_Real_Posterior_50_*.h5'));

for i=1:length(file_names)
    for j=1:length(file_names{i})
        file_names{1,i}(j).name = strcat(PATH,file_names{1,i}(j).name);
    end
end

for chain_no = 1:length(chain_nos)
    SevenStateEstimates(chain_no).n = length(file_names{1,chain_no});
    SevenStateEstimates(chain_no).chains = chain_nos(chain_no);
    SevenStateEstimates(chain_no).tempering = MarginalLikelihoodEstimation(file_names{1,chain_no},NO_DEBUG,chain_nos(chain_no));
end

file_names{1}=dir(strcat(PATH,'ION_FiveState_Real_Posterior_10_*.h5'));
file_names{2}=dir(strcat(PATH,'ION_FiveState_Real_Posterior_25_*.h5'));
file_names{3}=dir(strcat(PATH,'ION_FiveState_Real_Posterior_50_*.h5'));

for i=1:length(file_names)
    for j=1:length(file_names{i})
        file_names{1,i}(j).name = strcat(PATH,file_names{1,i}(j).name);
    end
end

for chain_no = 1:length(chain_nos)
    FiveStateEstimates(chain_no).n = length(file_names{1,chain_no});
    FiveStateEstimates(chain_no).chains = chain_nos(chain_no);
    FiveStateEstimates(chain_no).tempering = MarginalLikelihoodEstimation(file_names{1,chain_no},NO_DEBUG,chain_nos(chain_no));
end

%naming convention change here :)
file_names{1}=dir(strcat(PATH,'ION_ThreeState_Posterior_10_*.h5'));
file_names{2}=dir(strcat(PATH,'ION_ThreeState_Posterior_25_*.h5'));
file_names{3}=dir(strcat(PATH,'ION_ThreeState_Posterior_50_*.h5'));

for i=1:length(file_names)
    for j=1:length(file_names{i})
        file_names{1,i}(j).name = strcat(PATH,file_names{1,i}(j).name);
    end
end

for chain_no = 1:length(chain_nos)
    ThreeStateEstimates(chain_no).n = length(file_names{1,chain_no});
    ThreeStateEstimates(chain_no).chains = chain_nos(chain_no);
    ThreeStateEstimates(chain_no).tempering = MarginalLikelihoodEstimation(file_names{1,chain_no},NO_DEBUG,chain_nos(chain_no));
end

%write out the results
FID = fopen(strcat(getenv('P_HOME'),'/../../Written/Thesis/Tables/Chapter6/MarginalLikelihoodVarianceRealChains.tex'), 'w');
fprintf(FID, '\\begin{tabular}{|c|c|c|c|}\\hline \n');
fprintf(FID, 'Model & 10 & 25 & 50\\\\ \\hline \n');
fprintf(FID, 'Seven State & %8.2f $\\pm$ %8.2f & %8.2f $\\pm$ %8.2f & %8.2f $\\pm$ %8.2f \\\\ \\hline \n',SevenStateEstimates(1).tempering.mean,SevenStateEstimates(1).tempering.std,SevenStateEstimates(2).tempering.mean,SevenStateEstimates(2).tempering.std,SevenStateEstimates(3).tempering.mean,SevenStateEstimates(3).tempering.std);
fprintf(FID, 'Five State & %8.2f $\\pm$ %8.2f & %8.2f $\\pm$ %8.2f & %8.2f $\\pm$ %8.2f \\\\ \\hline \n',FiveStateEstimates(1).tempering.mean,FiveStateEstimates(1).tempering.std,FiveStateEstimates(2).tempering.mean,FiveStateEstimates(2).tempering.std,FiveStateEstimates(3).tempering.mean,FiveStateEstimates(3).tempering.std);
fprintf(FID, 'Three State & %8.2f $\\pm$ %8.2f & %8.2f $\\pm$ %8.2f & %8.2f $\\pm$ %8.2f \\\\ \\hline \n',ThreeStateEstimates(1).tempering.mean,ThreeStateEstimates(1).tempering.std,ThreeStateEstimates(2).tempering.mean,ThreeStateEstimates(2).tempering.std,ThreeStateEstimates(3).tempering.mean,ThreeStateEstimates(3).tempering.std);  
fprintf(FID, '\\end{tabular}\n');
fclose(FID);
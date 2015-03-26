%samplers at mode

ESSmala = AverageESS('/BayesianInference/Results/Thesis/Replicates_10/At Mode','Experiment31',100);
ESSrwmh = AverageESS('/BayesianInference/Results/Thesis/Replicates_10/At Mode','Experiment32',100);
ESSmult = AverageESS('/BayesianInference/Results/Thesis/Replicates_10/At Mode','Experiment33',100);
ESSadaptive = AverageESS('/BayesianInference/Results/Thesis/Replicates_10/At Mode','Experiment34',100);

FID = fopen(strcat(getenv('P_HOME'),'/../../Written/Thesis/Tables/Chapter5/10paramESSPerSampleAtMode.tex'), 'w');
fprintf(FID, '\\begin{tabular}{|c|c|c|}\\hline \n');
fprintf(FID, '? & \\multicolumn{2}{c|}{ESS/sample}\\\\ \\hline \n');
fprintf(FID, 'Sampler & $\\alpha_2$ & $\\beta_2$\\\\ \\hline \n');
fprintf(FID, 'Precond MALA & %8.2f & %8.2f \\\\ \\hline \n',ESSmala.meanESSsample(1), ESSmala.meanESSsample(2));
fprintf(FID, 'Precond RWMH & %8.2f & %8.2f \\\\ \\hline \n',ESSrwmh.meanESSsample(1), ESSrwmh.meanESSsample(2));
fprintf(FID, 'Mult RWMH & %8.2f & %8.2f \\\\ \\hline \n',ESSmult.meanESSsample(1), ESSmult.meanESSsample(2));  
fprintf(FID, 'Adaptive & %8.2f & %8.2f \\\\ \\hline \n',ESSadaptive.meanESSsample(1), ESSadaptive.meanESSsample(2));  
fprintf(FID, '\\end{tabular}\n');
fclose(FID);

FID = fopen(strcat(getenv('P_HOME'),'/../../Written/Thesis/Tables/Chapter5/10paramESSPerMinuteAtMode.tex'), 'w');
fprintf(FID, '\\begin{tabular}{|c|c|c|}\\hline \n');
fprintf(FID, '? & \\multicolumn{2}{c|}{ESS/sample}\\\\ \\hline \n');
fprintf(FID, 'Sampler & $\\alpha_2$ & $\\beta_2$\\\\ \\hline \n');
fprintf(FID, 'Precond MALA & %8.2f & %8.2f \\\\ \\hline \n',ESSmala.meanESSminute(1), ESSmala.meanESSminute(2));
fprintf(FID, 'Precond RWMH & %8.2f & %8.2f \\\\ \\hline \n',ESSrwmh.meanESSminute(1), ESSrwmh.meanESSminute(2));
fprintf(FID, 'Mult RWMH & %8.2f & %8.2f \\\\ \\hline \n',ESSmult.meanESSminute(1), ESSmult.meanESSminute(2));
fprintf(FID, 'Adaptive & %8.2f & %8.2f \\\\ \\hline \n',ESSadaptive.meanESSminute(1), ESSadaptive.meanESSminute(2));  
fprintf(FID, '\\end{tabular}\n');
fclose(FID);

%samplers from Guess 2...

ESSmala = AverageESS('/BayesianInference/Results/Thesis/Replicates_10/Guess2','Experiment29',100);
ESSrwmh = AverageESS('/BayesianInference/Results/Thesis/Replicates_10/Guess2','Experiment30',100);
ESSmult = AverageESS('/BayesianInference/Results/Thesis/Replicates_10/Guess2','ExperimentB',100);

FID = fopen(strcat(getenv('P_HOME'),'/../../Written/Thesis/Tables/Chapter5/10paramESSPerSampleGuess2.tex'), 'w');
fprintf(FID, '\\begin{tabular}{|c|c|c|}\\hline \n');
fprintf(FID, '? & \\multicolumn{2}{c|}{ESS/sample}\\\\ \\hline \n');
fprintf(FID, 'Sampler & $\\alpha_2$ & $\\beta_2$\\\\ \\hline \n');
fprintf(FID, 'Precond MALA & %8.2f & %8.2f \\\\ \\hline \n',ESSmala.meanESSsample(1), ESSmala.meanESSsample(2));
fprintf(FID, 'Precond RWMH & %8.2f & %8.2f \\\\ \\hline \n',ESSrwmh.meanESSsample(1), ESSrwmh.meanESSsample(2));
fprintf(FID, 'Mult RWMH & %8.2f & %8.2f \\\\ \\hline \n',ESSmult.meanESSsample(1), ESSmult.meanESSsample(2));  
fprintf(FID, '\\end{tabular}\n');
fclose(FID);

FID = fopen(strcat(getenv('P_HOME'),'/../../Written/Thesis/Tables/Chapter5/10paramESSPerMinuteGuess2.tex'), 'w');
fprintf(FID, '\\begin{tabular}{|c|c|c|}\\hline \n');
fprintf(FID, '? & \\multicolumn{2}{c|}{ESS/sample}\\\\ \\hline \n');
fprintf(FID, 'Sampler & $\\alpha_2$ & $\\beta_2$\\\\ \\hline \n');
fprintf(FID, 'Precond MALA & %8.2f & %8.2f \\\\ \\hline \n',ESSmala.meanESSminute(1), ESSmala.meanESSminute(2));
fprintf(FID, 'Precond RWMH & %8.2f & %8.2f \\\\ \\hline \n',ESSrwmh.meanESSminute(1), ESSrwmh.meanESSminute(2));
fprintf(FID, 'Mult RWMH & %8.2f & %8.2f \\\\ \\hline \n',ESSmult.meanESSminute(1), ESSmult.meanESSminute(2));  
fprintf(FID, '\\end{tabular}\n');
fclose(FID);

clear all
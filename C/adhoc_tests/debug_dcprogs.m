rates = [1900.9, 50046, 3939.1, 82.36, 40099, 0.95, 10000, 0.443e+08, 80.45,0.281e+09, 10000, 0.443e+08, 80.45, 0.281e+09];
qm=[ -1.90090000e+03   0.00000000e+00   0.00000000e+00   1.90090000e+03 0.00000000e+00   0.00000000e+00   0.00000000e+00;
   0.00000000e+00  -3.93910000e+03   0.00000000e+00   0.00000000e+00 3.93910000e+03   0.00000000e+00   0.00000000e+00;
   0.00000000e+00   0.00000000e+00  -4.00990000e+04   0.00000000e+00 0.00000000e+00   4.00990000e+04   0.00000000e+00;
   5.00460000e+04   0.00000000e+00   0.00000000e+00  -6.01264500e+04 8.04500000e+01   1.00000000e+04   0.00000000e+00;
   0.00000000e+00   8.23600000e+01   0.00000000e+00   1.40500000e+01 -1.00964100e+04   0.00000000e+00   1.00000000e+04;
   0.00000000e+00   0.00000000e+00   9.50000000e-01   2.21500000e+00 0.00000000e+00  -8.36150000e+01   8.04500000e+01;
   0.00000000e+00   0.00000000e+00   0.00000000e+00   0.00000000e+00 2.21500000e+00   1.40500000e+01  -1.62650000e+01];
load('/Users/michaelepstein/Dropbox/Academic/PhD/Code/git-repo/BayesianInference/Results/Thesis/RealData/Adaptive/Experiment53_RwmhMixtureProposal_1563717991.mat')
load('SevenStateGuessesAndParams.mat')

i=1;
%model.generateQ(rates(ten_param_keys),data.concs(i));
gen_dcprogs_test_case(data.bursts(i),model.kA,qm,data.tres(i),data.tcrit(i),strcat(getenv('P_HOME'),'/C/','test'));

%hjcfit
open_roots = [-40097.363261492500 ,-3931.583569640230 ,-662.846395731140];
shut_roots = [-55150.086900180800 , -10089.817582953200 , -96.362087318928 , -0.333640365677];

gen_dcprogs_test_case_roots(data.bursts(i),model.kA,qm,data.tres(i),data.tcrit(i),open_roots,shut_roots,strcat(getenv('P_HOME'),'/C/','hjcfit_test'));

%dcprogs
open_roots = [-40097.363261497300 ,-3931.583472338460 ,-662.846395273775];
shut_roots = [-55150.087085451200 , -10089.817582564800 , -96.362090209888 , -0.333640350622];

gen_dcprogs_test_case_roots(data.bursts(i),model.kA,qm,data.tres(i),data.tcrit(i),open_roots,shut_roots,strcat(getenv('P_HOME'),'/C/','dcprogs_test'));

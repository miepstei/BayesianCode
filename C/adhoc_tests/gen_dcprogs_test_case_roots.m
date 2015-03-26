function gen_dcprogs_test_case_roots(bursts , nopen, qmatrix , tres , tcrit , open_roots,shut_roots, filename)
% Generate CUnit tests based on the outcome of a Matlab simulation.
% Parameters:
%  datafile           output from a Matlab simulation
%  filename           two files are output for inclusion in the CUnit test
%                       suite:
%                       filename.c contains the unit test functions and
%                       filename_main.c contains code which adds them to a
%                       test suite
%  name               the name of the suite to add the tests to


  % Open the output file to define the test functions
  testfile = fopen([filename '.cpp'], 'w');

  fprintf(testfile, '#include <stdio.h>\n');
  fprintf(testfile, '#include <vector>\n');
  fprintf(testfile, '#include "likelihood.h"\n');
  fprintf(testfile, '#include "DCProgsConfig.h"\n');
  fprintf(testfile, '#include "determinant_equation.h"\n');
  fprintf(testfile, '#include "missed_eventsG.h"\n');
  fprintf(testfile, '#include "occupancies.h"\n');
  fprintf(testfile, '#include <iostream>\n');
  fprintf(testfile, '#include <iomanip>\n');
  fprintf(testfile, '#include <cmath>\n');
  fprintf(testfile, '\n\n');
  
  fprintf(testfile, 'int main() {\n');
  
  %display bursts
  fprintf(testfile,'DCProgs::t_Bursts bursts {\n');
  numberOfBursts=length(bursts{1});
  for i=1:numberOfBursts
      fprintf(testfile,'{');
      burstStr=sprintf('%.16f,',bursts{1}{i});
      burstStr=burstStr(1:end-1);
      fprintf(testfile,'%s',burstStr);
      if (i == length(bursts{1}))
          fprintf(testfile,'}\n');
      else
          fprintf(testfile,'},\n');
      end
  end
  fprintf(testfile,'};\n\n');
  
  fprintf(testfile,'DCProgs::Log10Likelihood likelihood(bursts, %i, %.8f, %.8f, 2, 1e-12, 1e-12, 100, -1e6, 0);\n\n', nopen, tres, tcrit);
  qsize=size(qmatrix);
  
  fprintf(testfile,'DCProgs::t_rmatrix matrix(%i ,%i);\n\n', qsize(1),qsize(2));
  qstr = sprintf('%.16f,',qmatrix);
  qstr=qstr(1:end-1);
  
  fprintf(testfile,'matrix << %s;', qstr);
  fprintf(testfile,'\n\n');
  fprintf(testfile,'DCProgs::QMatrix qmatrix(matrix, /*nopen=*/%i);\n\n',nopen);
  fprintf(testfile,'DCProgs::t_real const result = likelihood(qmatrix);\n');
  fprintf(testfile,'std::cout << std::setprecision(16) << "Likelihood is "  << log(10) * result << std::endl;\n\n');
  
  fprintf(testfile,'DCProgs::DeterminantEq determinant_eq(qmatrix, %.8f);\n',tres);
  
  openstr='std::vector<DCProgs::Root> af_roots{';
  for i=1:length(open_roots)
      openstr = strcat(openstr,sprintf('{%.16f,1},',open_roots(i))); 
  end
  openstr=openstr(1:end-1);
  openstr = strcat(openstr,'\n};');
  fprintf(testfile,openstr);
  
  shutstr='std::vector<DCProgs::Root> fa_roots{';
  for i=1:length(shut_roots)
      shutstr = strcat(shutstr,sprintf('{%.16f,1},',shut_roots(i))); 
  end
  shutstr=shutstr(1:end-1);
  shutstr = strcat(shutstr,'\n};\n');
  fprintf(testfile,shutstr);  
  
  fprintf(testfile,'DCProgs::MissedEventsG eG_from_roots( determinant_eq, af_roots,determinant_eq.transpose(), fa_roots,%i );\n\n',2);  
  
  fprintf(testfile,'bool const eq_vector = (%.8f <= 0);\n\n',tcrit);

  fprintf(testfile,'DCProgs::t_rvector final;\n\n');

  fprintf(testfile,'if(eq_vector)\nfinal = DCProgs::t_rmatrix::Ones(%i,1);\nelse\nfinal = DCProgs::CHS_occupancies(eG_from_roots, %.8f, false).transpose();\n\n',qsize(1),tcrit);

  fprintf(testfile,'DCProgs::t_initvec const initial = eq_vector ? DCProgs::occupancies(eG_from_roots): DCProgs::CHS_occupancies(eG_from_roots, %.8f);\n\n',tcrit);
                                
  fprintf(testfile,'DCProgs::t_real result_from_roots(0);\n\n');
  fprintf(testfile,'for(DCProgs::t_Burst const &burst: bursts)\n');
  fprintf(testfile,'result_from_roots += DCProgs::chained_log10_likelihood(eG_from_roots, burst.begin(), burst.end(), initial, final);\n');
  fprintf(testfile,'std::cout << std::setprecision(16) << "Likelihood from supplied roots is "  << log(10) * result_from_roots << std::endl;\n\n');
  
  
  fprintf(testfile, 'exit(0);\n\n');
  fprintf(testfile, '}');

  % Close the output files
  fclose(testfile);
  
end
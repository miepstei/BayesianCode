function gen_dcprogs_test_case(bursts , nopen, qmatrix , tres , tcrit , filename)
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
  fprintf(testfile, '#include <iostream>\n');
  fprintf(testfile, '#include <iomanip>\n');
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
  
  fprintf(testfile,'DCProgs::Log10Likelihood likelihood(bursts, %i, %.8f, %.8f);\n\n', nopen, tres, tcrit);
  
  qsize=size(qmatrix);
  
  fprintf(testfile,'DCProgs::t_rmatrix matrix(%i ,%i);\n\n', qsize(1),qsize(2));
  qstr = sprintf('%.16f,',qmatrix);
  qstr=qstr(1:end-1);
  
  fprintf(testfile,'matrix << %s;', qstr);
  fprintf(testfile,'\n\n');
  
  fprintf(testfile,'DCProgs::t_real const result = likelihood(matrix);\n');
  fprintf(testfile,'std::cout << std::setprecision(16) << "Likelihood is "  << result << std::endl;\n');
  
  fprintf(testfile, 'exit(0);\n\n');
  fprintf(testfile, '}');

  % Close the output files
  fclose(testfile);
  
end
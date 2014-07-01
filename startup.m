[~,host]=system('hostname');
if strcmp(strtrim(host),'scapa.stats.ucl.ac.uk')
    setenv('P_HOME','/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo')
    
elseif strcmp(strtrim(host),'localhost.localdomain')
    setenv('P_HOME','/home/michaelepstein/Dropbox/Academic/PhD/Code/git-repo')
elseif strcmp(strtrim(host),'Maddy-PC')
    setenv('P_HOME','C:\Users\Michael\Dropbox\Academic\PhD\Code\git-repo')
elseif strcmp(strtrim(host),'pryor.local')
    setenv('P_HOME','/home/ucbpmep/bayesiancode')
else
    setenv('P_HOME','/Users/michaelepstein/Dropbox/Academic/PhD/Code/git-repo')
end

import matlab.unittest.TestSuite

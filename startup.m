if isunix
    [~,host]=system('hostname');
    if ismac 
        [~,username] = system('whoami');
        setenv('P_HOME',['/Users/', strtrim(username), '/Dropbox/Academic/PhD/Code/git-repo'])
        sprintf('Mac system detected - P_HOME set to %s',getenv('P_HOME'))
    elseif strcmp(strtrim(host),'pryor.local')
        setenv('P_HOME','/home/ucbpmep/bayesiancode')
        sprintf('Cluster system detected - P_HOME set to %s',getenv('P_HOME'))
    elseif strcmp(strtrim(host),'ubuntu')
        setenv('P_HOME','/mnt/hgfs/me1809/Dropbox/Academic/PhD/Code/git-repo')
        sprintf('Ubuntu linux vm detected - P_HOME set to %s',getenv('P_HOME'))
    else
        setenv('P_HOME','/home/michaelepstein/Dropbox/Academic/PhD/Code/git-repo')
        sprintf('Linux system detected - P_HOME set to %s',getenv('P_HOME'))
    end
    clear host
else
    disp('[WARN] non UNIX machine detected, P_HOME not set')
end

import matlab.unittest.TestSuite

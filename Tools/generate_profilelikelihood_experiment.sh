PROJECT_ROOT=$1
SCRIPTFILE="$1/Tools/ClusterScripts/$2"
EXPERIMENT_NAME=$3
RUNHOURS=$4
MEMORY=$5
DATA_FILES=$6
MODEL_FILE=$7
PROFILE_POINTS=$8
CONCS=$9
TRES=${10}
TCRITS=${11}
USE_CHS=${12}
MIN_RNG=${13}
MAX_RNG=${14}
MATLAB_PATH=${15}
PARAMETER_KEYS=${16}

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ] || [ -z "$6" ] || [ -z "$7" ] || [ -z "$8" ] || [ -z "$9" ] || [ -z "${10}" ] || [ -z "${11}" ] || [ -z "${12}" ] || [ -z "${13}" ] || [ -z "${14}" ] || [ -z "${15}" ] || [ -z "${16}" ]; then 
    echo "Not all parameters are set!"
    echo "PROJECT_ROOT=/path/to/code/root" 
    echo "SCRIPTFILE=cluster_XXX.sh"
    echo "EXPERIMENT_NAME=1ai"
    echo "RUNHOURS=8"
    echo "MEMORY=8G"
    echo "DATA_FILES={'Samples/Simulations/20000/test_1.scn'} (Note Matlab cell array parentheses}"
    echo "MODEL_FILE=Tools/Mechanisms/model_params_CS 1985_4.mat"
    echo "PROFILE_POINTS=100"
    echo "CONCS=[3e-08]"
    echo "TRES=[2.5e-05]"
    echo "TCRITS=[0.0035]"
    echo "USE_CHS=[1]"
    echo "MIN_RNG=[13000,120000,4000,10,20000,50,500,1000,150000000]"
    echo "MAX_RNG=[20000,200000,8000,200,100000,500,3000,2500,250000000]"
    echo "MATLAB_PATH=/Applications/MATLAB_R2013a.app/bin/matlab"
    echo "PARAMETER_KEYS=[1,2,3,4,5,6,11,13,14]"

    echo "eg generateProfileLikelihoodExperiment.sh git-repo cluster_1ai.sh 1ai 8 \"8G\" \"{\'Samples/Simulations/20000/test_1.scn\'}\" 'Tools/Mechanisms/model_params_CS 1985_4.mat' 3 \"[3e-08]\" \"[2.5e-05]\" \"[0.0035]\" \"[1]\" \"[13000,120000,4000,10,20000,50,500,1000,150000000]\" \"[20000,200000,8000,200,100000,500,3000,2500,250000000]\" /Applications/MATLAB_R2013a.app/bin/matlab \"[1,2,3,4,5,6,11,13,14]\""

    exit 1
fi

echo "Generating script with the following parameters:"
echo "project_root=${PROJECT_ROOT}"
echo "script file=${SCRIPTFILE}"
echo "experiment name=${EXPERIMENT_NAME}"
echo "runhours on cluster=${RUNHOURS}"
echo "memory on cluster=${MEMORY}"
echo "scn files=${DATA_FILES}"
echo "markov model=${MODEL_FILE}"
echo "profile likelihood points=${PROFILE_POINTS}"
echo "array of concentrations=${CONCS}"
echo "array of treses=${TRES}"
echo "array of tcrits=${TCRITS}"
echo "chs array=${USE_CHS}"
echo "minimum PL values=${MIN_RNG}"
echo "maximum PL values=${MAX_RNG}"
echo "path to matlab executable=${MATLAB_PATH}"
echo "parameter keys in the markov model=${PARAMETER_KEYS}"


RESULTS_DIR=$PROJECT_ROOT/Results/dcprogs/${EXPERIMENT_NAME}
#boilerplate for any script
touch ${SCRIPTFILE}
chmod u+x ${SCRIPTFILE}
cat > ${SCRIPTFILE} << EOF
#$ -l h_vmem=${MEMORY},tmem=${MEMORY} 
#$ -l h_rt=${RUNHOURS}:0:0 
#$ -S /bin/bash
#$ -N ${EXPERIMENT_NAME}
#$ -o $PROJECT_ROOT/ExperimentLogs/${EXPERIMENT_NAME}.out 
#$ -e $PROJECT_ROOT/ExperimentLogs/${EXPERIMENT_NAME}.err 
#$ -cwd

#pre matlab scripting
echo "script started at"
echo \$( date ) 
echo "" 
export LD_PRELOAD=/home/ucbpmep/gcc48/usr/local/lib64/libstdc++.so.6 
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/ucbpmep/anaconda/lib:gcc48/usr/local/lib64 
echo "" 
mkdir -p ${RESULTS_DIR}


#MATLAB code
MATLAB_FILE="$PROJECT_ROOT/Tools/ClusterMatlab/autocluster_${EXPERIMENT_NAME}_dcprogs_\${SGE_TASK_ID}.m"
echo "matlab file is \${MATLAB_FILE}"
echo "results directory is ${RESULTS_DIR}"

touch \${MATLAB_FILE}

cat > \${MATLAB_FILE} << BEOF
job_id=str2num(getenv('SGE_TASK_ID'));
rng(job_id);
min_rng=${MIN_RNG}; %[13000,120000,4000,10,20000,50,500,1000,150000000];
max_rng=${MAX_RNG}; %[20000,200000,8000,200,100000,500,3000,2500,250000000];
fprintf('Job id is %i\n',job_id)
parameter_keys=${PARAMETER_KEYS};%[1,2,3,4,5,6,11,13,14]; 
profile_param = parameter_keys(job_id);

outfile=['${RESULTS_DIR}/parameter_key_' num2str(job_id) '.mat'];
datafiles=strcat('$PROJECT_ROOT','/', ${DATA_FILES});
modelfile=['$PROJECT_ROOT' '/' '${MODEL_FILE}'];
points=${PROFILE_POINTS};
concs=${CONCS};
tres=${TRES};
tcrits=${TCRITS};
is_log=1;
use_chs =${USE_CHS};
debug_on=0;

experiment = setup_experiment(tres,tcrits,concs,use_chs,debug_on,is_log,datafiles,modelfile);

a=tic;
[profiles,profile_likelihoods,profile_errors,profile_iter,profile_rejigs,free_parameter_map]=profileLikelihood(experiment,points,profile_param,min_rng,max_rng);
b=toc(a);

fprintf('Time taken for profile analysis of key %i is %f\n',profile_param,b)
save(outfile, 'profile_errors','profile_iter','profile_rejigs','profiles','profile_likelihoods','points','parameter_keys','min_rng','max_rng','outfile','datafiles','modelfile','free_parameter_map');

BEOF

${MATLAB_PATH} -nodisplay -nodesktop -nosplash -r "try addpath(genpath(pwd));autocluster_${EXPERIMENT_NAME}_dcprogs_\${SGE_TASK_ID};catch err; disp(err.message); end; quit();"

echo "script finished at"
echo \$( date ) 
EOF

echo "${SCRIPTFILE} generated."
echo "Usage: qsub -t 1:x ${SCRIPTFILE}"

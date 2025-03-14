#!/bin/zsh

# NOTE: Before you run scaling make sure the dataset has been downloaded completely
#       Otherwise you might get errors due to a race condition when downloading the set

############################################################
### Parameters and settings
############################################################
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export RESULT_DIR="${SCRIPT_DIR}/results_$(date +"%Y-%m-%d_%H%M%S")"

mkdir -p ${RESULT_DIR}

# set option to make sure that array indexing starts at 0 in Zsh as well
if [ -n "$ZSH_VERSION" ]; then
   setopt KSH_ARRAYS
fi

# each of the following arrays needs to have the same size
N_NODES=(1 1 1 2)
N_TASKS_PER_NODE=(1 2 4 4)
N_EPOCHS=10

############################################################
### Experiments
############################################################
# move to directoy containing scripts
cd ../solutions

# iterate over arrays via index
for (( i = 0; i < ${#N_NODES[@]}; i++ )); do
    cur_nodes=${N_NODES[$i]}
    cur_tpn=${N_TASKS_PER_NODE[$i]}
    printf 'Creating Job with N_NODES=%d N_TASK_PER_NODE=%d N_GPUS_PER_NODE=%d\n' "${cur_nodes}" "${cur_tpn}" "${cur_tpn}"

    cur_dist=1
    if [[ "${cur_nodes}" == "1" ]] ; then
        if [[ "${cur_tpn}" == "1" ]] ; then
            cur_dist=0
        fi
    fi

    export JOB_NAME_SPEC="${cur_nodes}n_${cur_tpn}tpn"

    sbatch \
        --export=RESULT_DIR,JOB_NAME_SPEC,ENABLE_MONITORING=1,RUN_DISTRIBUTED=${cur_dist} \
        --nodes=${cur_nodes} \
        --ntasks-per-node=${cur_tpn} \
        --gres=gpu:${cur_tpn} \
        --job-name=pytorch_${JOB_NAME_SPEC} \
        --output="${RESULT_DIR}/output_%x_%j.log" \
        submit_job.sh --num_epochs ${N_EPOCHS}
done

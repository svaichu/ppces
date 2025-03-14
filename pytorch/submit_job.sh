#!/usr/bin/zsh
#SBATCH --time=01:00:00
#SBATCH --account=lect0138
#SBATCH --partition=c23g
#SBATCH --reservation=PPCES-g
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --gres=gpu:1

############################################################
### Load Modules
############################################################
module load PyTorch/nvcr-24.01-py3
module list

# print some information about current system
echo "Machine: $(hostname)"
nvidia-smi

############################################################
### Parameters and Settings
############################################################
RESULT_DIR=${RESULT_DIR:-"."}
JOB_NAME_SPEC=${JOB_NAME_SPEC:-""}

# redirect arguments to python file
export args="${@}"

# variables required for distributed runs with DDP
export MASTER_ADDR=$(hostname)
export MASTER_PORT=12340 # error --> change to different port
export NCCL_DEBUG=INFO

############################################################
### Execution (Model Training)
############################################################
if [ "${ENABLE_MONITORING:-0}" = "1" ]; then
    # start monitoring process in the background (every 2 sec)
    nvidia-smi --query-gpu=timestamp,index,compute_mode,pstate,utilization.gpu,utilization.memory,memory.used,temperature.gpu,power.draw \
        --format=csv --loop=2 &> ${RESULT_DIR}/gpu_monitoring_${JOB_NAME_SPEC}_${SLURM_JOBID}.txt &
    # remember ID of process that has just been started in background
    export proc_id_monitor=$!
fi

if [ "${SLURM_NTASKS}" -gt 1 ]; then
    # need to execute with MPI/srun (or torchrun)
    srun \
        zsh -c '\
        source set_vars.sh && \
        apptainer exec -e --nv ${PYTORCH_IMAGE} \
            bash -c "python train_model.py --distributed ${args}"'
else
    # just execute using a single GPU
    source set_vars.sh
    apptainer exec -e --nv ${PYTORCH_IMAGE} \
        bash -c "python train_model.py ${args}"
fi

if [ "${ENABLE_MONITORING:-0}" = "1" ]; then
    # end monitoring process again
    kill -2 ${proc_id_monitor}
    sleep 5
fi
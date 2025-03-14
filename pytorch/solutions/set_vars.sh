#!/usr/bin/zsh

export RANK=${SLURM_PROCID}
export LOCAL_RANK=${SLURM_LOCALID}
export WORLD_SIZE=${SLURM_NTASKS}

export APPTAINERENV_MASTER_ADDR=${MASTER_ADDR}
export APPTAINERENV_MASTER_PORT=${MASTER_PORT}
export APPTAINERENV_RANK=${RANK}
export APPTAINERENV_LOCAL_RANK=${LOCAL_RANK}
export APPTAINERENV_WORLD_SIZE=${WORLD_SIZE}
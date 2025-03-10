#!/usr/local_rwth/bin/zsh

## Resource Configuration
#SBATCH --nodes=%NODES
#SBATCH --ntasks-per-node=%NPROCS
#SBATCH --mem-per-cpu=3900
#SBATCH --time=00:03:00

## Accounting Configuration
#SBATCH --account=supp0006
#SBATCH --partition=c23test
#SBATCH --reservation=PPCES24MPI

## Information Configuration
#SBATCH --job-name=PPCES_%PROG
#SBATCH --output=%PROG.%J.stdout

#unset this variable to mute a warning when using intel toolchain on CLAIX
unset I_MPI_TCP_BUFFER_SIZE

#execute the program
$MPIEXEC -n %NPROCS %PROG.exe %ARGS

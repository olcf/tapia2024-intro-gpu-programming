#!/bin/bash

#SBATCH -A TRN001
#SBATCH -J complete_the_data_transfers
#SBATCH -N 1
#SBATCH -t 10
#SBATCH -p batch
#SBATCH -o %x-%j.out
#SBATCH --reservation=tapia-doe

OMP_NUM_THREADS=8 srun -n1 -c8 --gpus=1 ./average_array_elements


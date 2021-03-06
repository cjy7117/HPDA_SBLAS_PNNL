#! /bin/bash
#!/bin/bash 
### Begin BSUB Options 
#BSUB -P csc143 
#BSUB -J SP_test 
#BSUB -W 00:25 
#BSUB -nnodes 1 
#BSUB -alloc_flags "smt1"
### End BSUB Options and begin shell commands
NUMA=AAA

if ((${NUMA} == 1))
then
	export OMP_PLACES="{0},{28},{56},{88},{116},{144}"
fi
if ((${NUMA} == 0))
then
	export OMP_PLACES="{0},{4},{8},{12},{16},{20}"
fi


export OMP_PROC_BIND=close

JSRUN='jsrun -n 1 -a 1 -c 42 -g 6 -r 1 -l CPU-CPU -d packed -b packed:42 --smpiargs="-disable_gpu_hooks"'


DATA_PREFIX=/gpfs/alpine/scratch/jieyang/csc331/spmv_matrix
RESULT_PREFIX=/gpfs/alpine/scratch/jieyang/csc331/spmv_results

#DATA_PREFIX=./
#NGPU=6
NTEST=10

PART_OPT=PPP
MERG_OPT=EEE

NVPROF='nvprof --profile-from-start off --print-gpu-trace --export-profile'

# for real type matrices
for matrix_file in MMM
do
  for NGPU in GGG
  do
    _CSV_OUTPUT=${RESULT_PREFIX}/${matrix_file}_${NGPU}_${PART_OPT}_${MERG_OPT}_${NUMA}
    _PROF_OUTPUT=${RESULT_PREFIX}/${matrix_file}_${NGPU}_${PART_OPT}_${MERG_OPT}_${NUMA}
    #NVPROF_CMD=${NVPROF}' '${_PROF_OUTPUT}.prof
    [ -f ${_CSV_OUTPUT}.csv ] && rm ${_CSV_OUTPUT}.csv
    [ -f ${_PROF_OUTPUT}.prof ] && rm ${_PROF_OUTPUT}.prof
    $JSRUN ${NVPROF_CMD} ./test_spmv_smt f $DATA_PREFIX/$matrix_file $NGPU $NTEST ${_CSV_OUTPUT} ${PART_OPT} ${MERG_OPT}
  done
done

#!/bin/csh

#### script adotped from Yuhan
#### orig location:            /global/scratch/ljin/SARMAP/CCTM/SARMAP_209_1LEMIS_35ling3.3_ICv2
#### additional comments in run_CCTM_258_7day.tin1a.csh
#### this script current loc:  /global/scratch/tin/SARMAP/CCTM/SARMAP_209_1LEMIS_35ling3.3_ICv2/ADJ_AVE_FRE_NO2
#### backup: /global/scratch/tin/tin-gh/CMAQ/run_eta_2021

#### dir structure copied per /global/scratch/tin/SARMAP/ReadMe.rst
#### try running as

#SBATCH --time=72:00:00
#SBATCH --job-name=209FRENO2
#SBATCH --partition=lr5
#SBATCH -C lr5_c28
#SBATCH --qos=lr_normal
#####SBATCH --account=pc_adjoint
#####SBATCH --nodes=5
#####SBATCH --ntasks-per-node=16
#SBATCH --account=scs
#SBATCH --nodes=3                    ## Yuhan used 5*16 seems ok
#SBATCH --ntasks-per-node=27         ## also need to change  NPROCS NPCOL_NPROW below               #### ++

setenv NPCOL_NPROW "10 8"
setenv NPROCS 80


## timing info is printed into the output file when a step is completed,  ???
## formerly recorded in tin-gh/CMAQ/run_eta/perf.rst for newer results.
echo "start time"
date
echo "hosting node"
hostname
setenv USERNAME `/usr/bin/whoami`
echo "----------result of squeue -u $USERNAME :: ---------------"
squeue -u $USERNAME
echo "------ modules as it stands :: ------------------- "
module list
which mpirun
which mpicc
echo "COMMON_ENV_TRACE: $COMMON_ENV_TRACE"
echo "MODULEPATH: $MODULEPATH"
echo $MODULEPATH  | sed 's/:/\n/g'

which mpirun
which mpicc

#### output??
#### Yuhan didn't seems to have specified an output dir.  eg job
#### 29774393=209S2S 4 nodes      /global/sched/slurm/jobscripts/2021-03-26/job29733855
#### 29800904=t2mFREO3 5 nodes
#### seems like DIR_OUT default to `pwd` in com_global.csh
#### previously pghuy and I set it explicityly, so doing that again:
##xx mkdir       -p /global/scratch/tin/bench_cmaq/OUT_cmaq_run1/ADJ_AVE_FRE_NO2_${SLURM_JOBID}   ## OUTPUT++++
##xx setenv DIR_OUT /global/scratch/tin/bench_cmaq/OUT_cmaq_run1/ADJ_AVE_FRE_NO2_${SLURM_JOBID}   ## OUTPUT++++
mkdir       -p /global/scratch/tin/SARMAP/CCTM/SARMAP_209_1LEMIS_35ling3.3_ICv2/ADJ_AVE_FRE_NO2/OUT_cmaq_run1/ADJ_AVE_FRE_NO2_${SLURM_JOBID}   ## OUTPUT++++
setenv DIR_OUT /global/scratch/tin/SARMAP/CCTM/SARMAP_209_1LEMIS_35ling3.3_ICv2/ADJ_AVE_FRE_NO2/OUT_cmaq_run1/ADJ_AVE_FRE_NO2_${SLURM_JOBID}   ## OUTPUT++++

echo "--===============end=of=tin=stuff=========================--" ####
echo "--========================================================--"





setenv metopt LAY35_LingOpt
####setenv dirnme ljin   
setenv dirnme tin                  ## affect INPUT dir, changed to use my copy/link
#### originally needed to read:
#### /global/scratch/ljin/SARMAP/CCTM/SARMAP_209_1LEMIS_35ling3.3_ICv2/ADJ_AVE_FRE_NO2/

setenv KZMIN F

setenv NME_SCRIPT run_CCTM.csh

setenv NME_DOM SARMAP
setenv NME_MONTH 209
setenv NME_WEEK 

setenv CMAQ_CONF SAPRC99ROS

setenv NME_EM LAY1
setenv EMYEAR 2012

setenv STDATE 2000209
setenv STTIME 070000
setenv NSTEPS 1670000
setenv TSTEP 010000

setenv ADJ_STDATE_TOT 2000209
setenv ADJ_STTIME_TOT 070000
setenv ADJ_TOTLEN 1670000

setenv RTO_FWD F
setenv RTO_FWD_RST F
setenv RTO_BWD T
setenv RTO_BWD_RST F
setenv RTO_CHK F

setenv XFIRST_FWD T
setenv XFIRST_BWD T

setenv SIGMA_SYNC_TOP 0.05


setenv TSTEP_ACONC 10000

setenv REC_SPECIES NO2
setenv REC_VAR AVE_FRE
setenv TSTEP_AL5CHK 10000

setenv L5FCHK_READ F
setenv L5FCHK_WRITE F
setenv L5FCHK_DATE $STDATE
setenv L5FCHK_TIME $STTIME

# Overwrite some default variables

# -> CHK files to read are in the parent directory
setenv DIR_CONC `pwd | awk -F/ '{$NF=""; print}' | sed 's/ /\//g'`

# Overwrite some default variables

# ---> data dir
setenv DIR_BAADATA /global/scratch/${dirnme}/SARMAP  #### dirnme <- ljin  #### now use tin
setenv DIR_RUN $DIR_BAADATA

# use 35 layer met
setenv DIR_MCIP ${DIR_RUN}/MCIP/${metopt}  ## linked


# ---> Use Layxx BCON and ICON 
setenv DIR_IC ${DIR_RUN}/ICON/${metopt}		## linked
setenv NME_IC ${NME_DOM}_IC_${metopt}_v2

setenv DIR_BC ${DIR_RUN}//BCON/${metopt}
setenv NME_BC ${NME_DOM}_BC_${metopt}

# ----> EMIS
setenv DIR_EMIS ${DIR_RUN}/EMISSIONS//${metopt}
setenv NME_EMIS ${NME_DOM}_${NME_MONTH}_${EMYEAR}_${NME_EM}.EMISSIONS.nc 

# ---> rec file cropped to smaller domain
setenv DIR_REC ${DIR_RUN}/RECEPTORS/${metopt}
setenv NME_REC receptor_${NME_MONTH}_F_lastday_${REC_VAR}.nc

# ---> set an empty ocean file to kill the error (ocean file is not needed for ozone run)
#setenv DIR_OCEAN ${DIR_RUN}/OCEAN


# ---> use Ling cctm code
 setenv DIR_CMAQ_W /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB/built_gcc_gfortran_parallel_O3_LingOpt/


#### orig location: /global/scratch/ljin/SARMAP/CCTM/SARMAP_209_1LEMIS_35ling3.3_ICv2
# ----> source the modules
#--- source ../../lawrencium-modules.csh
#### orig location: /global/scratch/ljin/SARMAP/CCTM/SARMAP_209_1LEMIS_35ling3.3_ICv2
setenv DirBase /global/scratch/tin/SARMAP/CCTM/SARMAP_209_1LEMIS_35ling3.3_ICv2/ADJ_AVE_FRE_NO2/ ####
source ${DirBase}/../../lawrencium-modules.csh ####
#### mod load gcc/6.3.0 openmpi/3.0.1-gcc netcdf/4.4.1.1-gcc-s python/3.6 udunits/2.2.24-gcc #### may have to load in .bashrc

# Run the scripts

#----set scr=../../../com_global.csh
set scr=${DirBase}/../../../com_global.csh ####
echo "--======================================================================-- #### L118 com_global ====--"
echo "Script: ${scr}" ; cat ${scr} ; echo "Running ${scr}" ; source ${scr}



echo "--======================================================================-- #### L123 com_CCTM ====--"
#----set scr=../../com_CCTM.csh
set scr=${DirBase}/../../com_CCTM.csh
echo "Script: ${scr}" ; cat ${scr} ; echo "Running ${scr}" ; source ${scr}

echo "--======================================================================-- #### end"

#set scr=../../com_CCTM_inout.csh
#echo "Script: ${scr}" ; cat ${scr}

#echo "Script: ${NME_SCRIPT}" ; #cat ${NME_SCRIPT}

#!/bin/csh

#SBATCH --job-name=ADJ258Sn
#SBATCH --partition=lr6
#SBATCH --qos=lr_normal
#SBATCH --account=scs
#SBATCH -o ADJ258Sn_%N_job_%j.out
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=tin@lbl.gov
#SBATCH --nodes=4  # 4 nodes perf was ok.  24 nodes was unbearably slow.  8 or 6 nodes were bad too.
#SBATCH --ntasks-per-node=32          ## also need to change  NPROC NPCOL_NPROW below ++

## parallel processing, https://www.cmascenter.org/cmaq/documentation/4.7.1/Operational_Guidance_Document.pdf
## did not explain what col and rows are, just that they mult result is NPROCS
## so setting to equate cores * nodes.  COL > ROW is recommended
##setenv NPCOL_NPROW "32 16" # "8 8"
##setenv NPROCS 512 # 64 
##setenv NPCOL_NPROW "32 24" 
##setenv NPROCS 768
setenv NPCOL_NPROW "16 8" # "32 4" 
setenv NPROCS 128




## input, need to read:
## /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/RECEPTORS/SARMAP_EP258_F.nc
## output was set in my env var below:
## /global/scratch/tin/adj_kzF_O3_GE66_Popdens_258_${JOBID}/iolog_000.out  
## this script location:
## /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/CCTM/SARMAP_KZMIN_F_O3/ADJ_RUN/run_CCTM_258_7day.tin.csh


## timing info is printed into the output file when a step is completed, 

## pghuy on lr3, 16 cores, likely asked for 4 nodes: adj_kzF_O3_GE66_Popdens_258_20253866 # maybe out of time by step 29?
## Walltime for backward step     1 (out of   167): 0.228843E+04
## Walltime for backward step    16 (out of   167): 0.360874E+04
## Walltime for backward step    29 (out of   167): 0.321298E+04
## lr3 1 step takes ~38 min, 106 hours, which is why pghuy asked to get longer run time.  16c*4n= 64 threads.


## on lr6, 32cores, 16 nodes, but uptime indicate only 2 nodes in use, cuz just have 64 threads of jobs:
## Walltime for backward step     1 (out of   167): 0.784240E+03
## Walltime for backward step    16 (out of   167): 0.113043E+04
## Walltime for backward step    29 (out of   167): 0.102657E+04
## Walltime for backward step    37 (out of   167): 0.958917E+03
## 2 active nodes on lr6, 32cores, so still 64 threads. step 1 took 13 min
## so maybe 2x-3x faster on lr6?

## but became much slower in lr6 32*24 ??   Eventually cancelled after 3+ hours of no walltime output report

## lr6 32c * 4 nodes.  timing is in seconds, so ~10 min for step 1 in this run, after maybe ~4 min to get 14G SARMAP_258_2012_ALL_HYBRID.AL5CHK.nc in place
## 4 nodes vs 2 LR6 nodes was only just marginally faster than the 2 actual node used in 8/10 run
## Walltime for backward step     1 (out of   167): 0.618170E+03
## Walltime for backward step     2 (out of   167): 0.660169E+03
## if take ~10 min / step, 167 steps would take 28 hours.

## lr6 32c * 8 nodes, try 1: 
## swamped again?  13+ min  SARMAP_258_2012_ALL_HYBRID.AL5CHK.nc still 28k in size.  cancelled.

## lr6 32c * 8 nodes, try 2: 
## seems really no good. 5+ min  SARMAP_258_2012_ALL_HYBRID.AL5CHK.nc still 28k in size.  cancelled.

## lr6 32c * 6 nodes
## maybe when number of cores exceed steps requirement then it is bad performing?
## no, the 167 steps are sequential... not sure if other things limit to 128 threads.  but leave as that for now.

## back to lr6 32c * 4 nodes
## Walltime for backward step     1 (out of   167): 0.480253E+03
## Walltime for backward step     2 (out of   167): 0.501883E+03


setenv NME_SCRIPT run_CCTM_209.csh

setenv REC_VAR O3_GE66_Popdens 

setenv NME_DOM SARMAP
setenv NME_MONTH 258     ## likely number of days since Jan 1.
setenv NME_WEEK

setenv CMAQ_CONF O3

setenv NME_EM ALL_HYBRID
setenv EMYEAR 2012

## cctm, cmaq chem transport model,  options desc in p64 of CMAQ v4.6 Operational Guidance doc 
## http://views.cira.colostate.edu/data/Documents/CMAQ/cmaq-manual.pdf
## annotated pdf in : gdoc G:\My Drive\2read\airModel
setenv STDATE 2000258   ## year=2000, 258 days after jan 1 = mid september
setenv STTIME 70000
setenv NSTEPS 1670000   ## this was 710000 in run_CCTM_258.csh  # HHMMSS, ie just short of 7 days from just short of 3 days
setenv TSTEP 010000		  ## HHMMSS

setenv TSTEP_ACONC 010000
 
setenv ADJ_STDATE_TOT 2000258
setenv ADJ_STTIME_TOT 70000
setenv ADJ_TOTLEN 1670000    ## this was 710000 in run_CCTM_258.csh

setenv RTO_FWD F
setenv RTO_FWD_RST F
setenv RTO_BWD T
setenv RTO_BWD_RST F
setenv RTO_CHK F

setenv XFIRST_FWD T
setenv XFIRST_BWD F

setenv SIGMA_SYNC_TOP 0.05


## hmm, only care about ozone?
## but later has def of: setenv REC_VAR O3_GE66_Popdens 
setenv REC_SPECIES O3

setenv TSTEP_AL5CHK 10000

setenv L5FCHK_READ F
setenv L5FCHK_WRITE F

# Overwrite some default variables
# we now set the kzmin to false
## KZMIN has to do with Min eddy diffusivity
setenv KZMIN F 

mkdir -p /global/scratch/tin/adj_kzF_${REC_VAR}_${NME_MONTH}_${SLURM_JOBID}
setenv DIR_OUT /global/scratch/tin/adj_kzF_${REC_VAR}_${NME_MONTH}_${SLURM_JOBID}
# REC_VAR is 

# ---> Use the weekday bio emis
setenv DIR_CONC /global/scratch/pghuy/DIR_CONC/${NME_DOM}_${NME_MONTH}_F
## this is output dir too it seems
## sym link, didn't want to overwrite, so created my own empty dir:
## nope, apparently need to read... so, wtf??
##setenv DIR_CONC /global/scratch/tin/DIR_CONC/${NME_DOM}_${NME_MONTH}_F


setenv NME_REC ${NME_DOM}_EP${NME_MONTH}_F.nc 

## run based on some tutorial... should read that
setenv DIR_RUN /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run
setenv DIR_CODE /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/code

setenv DIR_EMIS  /global/home/groups-sw/pc_adjoint/data/SARMAP/EMIS
setenv NME_EMIS weekday_bio.ep$NME_MONTH

setenv DIR_CMAQ_W /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB/built_gcc_gfortran_parallel_O3_default-eddy
## Above is Oh 3, not zero 3 !  for ozone.

setenv DIR_IC ${DIR_CONC}
setenv NME_IC ${NME_DOM}_${NME_MONTH}_${EMYEAR}_${NME_EM}.CONC.nc 

##
umask 002 

################################################################################

# Run the scripts

## **>> com_global.csh maybe sourcing for non existing 
## /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/lawrencium-modules.csh: No such file or directory.
## found one at /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/my-run-directory-tree/lawrencium-modules.csh
## but too old, so created a dummy lawrencium-modules.csh


set scr=../../../com_global.csh
echo "Script: ${scr}" ; cat ${scr} ; echo "Running ${scr}" ; source ${scr}

set scr=../../com_CCTM.csh
echo "Script: ${scr}" ; cat ${scr} ; echo "Running ${scr}" ; source ${scr}

## maybe source of CTM_CONC_1 error:
##   set CONCfile = ${APPL}."CONC".nc                   # CTM_CONC_1
## from: setenv EXECUTION_ID $APPL
## from: EXECUTION_ID=SARMAP_258_2012_ALL_HYBRID
## ie SARMAP_258_2012_ALL_HYBRID.CONC.nc 
## dir=  /global/scratch/pghuy/DIR_CONC/SARMAP_258_F/SARMAP_258_2012_ALL_HYBRID.CONC.nc
## but that was under "Output files" section... can't write?

set scr=../../com_CCTM_inout.csh
echo "Script: ${scr}" ; ## cat ${scr}

#!/bin/csh

#SBATCH --job-name=ADJ258S2_cmaq_run2_4x16_lr5	## ++++
#SBATCH --partition=lr5    #lr3	#lr6		## ++++
#SBATCH --qos=lr_normal
# #SBATCH --qos=cf_normal
#SBATCH --account=scs
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=tin@lbl.gov
#SBATCH -o ADJ258S2_%N_job_%j.4x16_lr5.out  	## ++++
### 4 nodes perf was ok.  24 nodes was unbearably slow.  8 or 6 nodes were bad too.
### hmmm... using 8 nodes (x32core), *nc creation takes too long :(
#SBATCH --nodes=4  # 4 nodes perf was ok.  24 nodes was unbearably slow.  8 or 6 nodes were bad too.    ## ++++
#SBATCH --ntasks-per-node=16   #28   #16          ## also need to change  NPROC NPCOL_NPROW below 	## ++++
## also need to change  NPROC NPCOL_NPROW below ++


#### **** +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ **** ####
#### **** +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ **** ####
#### ****                                                               **** ####
#### **** double check cmaq_run1 vs cmaq_run2 before sbatch submit ++++ **** ####
#### **** double check cmaq_run1 vs cmaq_run2 before sbatch submit !!!! **** ####
#### ****                                                               **** ####
#### **** +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ **** ####
#### **** +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ **** ####

## parallel processing, https://www.cmascenter.org/cmaq/documentation/4.7.1/Operational_Guidance_Document.pdf
## did not explain what col and rows are, just that they mult result is NPROCS
## so setting to equate cores * nodes.  COL > ROW is recommended
##setenv NPCOL_NPROW "32 16" # "8 8"
##setenv NPROCS 512 # 64 
##setenv NPCOL_NPROW "32 24" 
##setenv NPROCS 768
setenv NPCOL_NPROW "8 8" # "32 4" 			## ++++
setenv NPROCS 64 #128 #112 #128 #64			## ++++

echo "NPCOL_NPROW is set to: ${NPCOL_NPROW}"
echo "NPROCS is set to: ${NPROCS}"

## input, need to read:
## /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/RECEPTORS/SARMAP_EP258_F.nc
## output was set in my env var below:
## /global/scratch/tin/adj_kzF_O3_GE66_Popdens_258_${JOBID}/iolog_000.out  
## this script location:
## /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/CCTM/SARMAP_KZMIN_F_O3/ADJ_RUN/run_CCTM_258_7day.tin.csh

## timing info is printed into the output file when a step is completed, 
## see tin-gh/CMAQ/run_eta/perf.rst for newer results.

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


#setenv MODULEPATH  "/global/software/sl-7.x86_64/modules/gcc/6.3.0/:${MODULEPATH}"  # should be set by gcc, but not functional in csh??
#echo "modules after purge and specific load (lrc SMF):"
#module purge
#module load tmux
#module load r/3.4.2 # not needed
#module unload gcc   # unload is very problematic in csh
#module load gcc/6.3.0
#echo "**>> MODULEPATH after loading gcc/6.3.0: $MODULEPATH <<**"
#echo $MODULEPATH  | sed 's/:/\n/g'
#module load openmpi/3.0.1-gcc
#module load netcdf #use version 4.4.1.1-s
#module load python/2.7
#module unload emacs/24.1
#module load ncl  
#module load nco
#module load ncview
#module load udunits/2.2.24-gcc

module list

# for now, i went back to .bashrc , see email for what module ended up loaded.
# next time, try to get it to this list:
# Ling's list. R not needed
#  1) tmux/2.7               5) netcdf/4.6.1-gcc-s     9) udunits/2.2.24-gcc    13) antlr/2.7.7-gcc       17) emacs/25.1
#  2) gcc/6.3.0              6) python/2.7            10) szip/2.1.1            14) nco/4.7.4-gcc-s
#  3) openmpi/3.0.1-gcc      7) hdf5/1.8.18-gcc-s     11) ncl/6.3.0-gcc         15) ncview/2.1.7-gcc
#  4) hdf5/1.8.20-gcc-s      8) netcdf/4.4.1.1-gcc-s  12) gsl/2.3-gcc           16) vim/7.4

echo "====beyond all the module load stuff===================================="

which mpirun
which mpicc



echo "===============end=of=tin=stuff========================="
echo "========================================"



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
##setenv XFIRST_BWD T  ## hopefully reduce crash, but seems to do worse... 
echo "XFIRST_BWD is set to: ${XFIRST_BWD} "

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

#mkdir       -p /global/scratch/tin/cmaq_run1/adj_kzF_${REC_VAR}_${NME_MONTH}_${SLURM_JOBID}   ## OUTPUT++
#setenv DIR_OUT /global/scratch/tin/cmaq_run1/adj_kzF_${REC_VAR}_${NME_MONTH}_${SLURM_JOBID}   ## OUTPUT++
mkdir       -p /global/scratch/tin/cmaq_run2/adj_kzF_${REC_VAR}_${NME_MONTH}_${SLURM_JOBID}  	## OUTPUT++++
setenv DIR_OUT /global/scratch/tin/cmaq_run2/adj_kzF_${REC_VAR}_${NME_MONTH}_${SLURM_JOBID}    	## OUTPUT++++ simultaneous run 2 in cmaq2
# REC_VAR is 
echo "=== Output  DIR_OUT set to ${DIR_OUT} :: ==="
ls -l ${DIR_OUT}

# ---> Use the weekday bio emis
##setenv DIR_CONC /global/scratch/pghuy/DIR_CONC/${NME_DOM}_${NME_MONTH}_F
#### made my own copy only for _F, per Ling suggestion.
#setenv DIR_CONC /global/scratch/tin/cmaq_run1/DIR_CONC/${NME_DOM}_${NME_MONTH}_F   ## INPUT++   simultaneous run  (cmaq_run1) in a cmaq2 
setenv DIR_CONC /global/scratch/tin/cmaq_run2/DIR_CONC/${NME_DOM}_${NME_MONTH}_F   ## INPUT++++ simultaneous run 2 in a cmaq2 INPUT dir
echo "=== INput  DIR_CONC set to ${DIR_CONC} :: ==="
ls -l ${DIR_CONC}

## this is output dir too it seems
## sym link, didn't want to overwrite, so created my own empty dir:
## nope, apparently need to read... so, wtf??
##setenv DIR_CONC /global/scratch/tin/DIR_CONC/${NME_DOM}_${NME_MONTH}_F


setenv NME_REC ${NME_DOM}_EP${NME_MONTH}_F.nc 

## run based on some tutorial... should read that
setenv DIR_RUN  /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run
setenv DIR_CODE /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/code

setenv DIR_EMIS  /global/home/groups-sw/pc_adjoint/data/SARMAP/EMIS
setenv NME_EMIS weekday_bio.ep$NME_MONTH

setenv DIR_CMAQ_W /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB/built_gcc_gfortran_parallel_O3_default-eddy
## Above is Oh 3, not zero 3 !  for ozone.

setenv DIR_IC ${DIR_CONC}
setenv NME_IC ${NME_DOM}_${NME_MONTH}_${EMYEAR}_${NME_EM}.CONC.nc 

##
umask 002 


echo "========================================"
echo "========================================"

echo "capturing slurm job submission script itself -- dollar0: $0"
cat -n $0
echo "---job-script-------------------------------------"
#echo "capturing slurm job submission script itself... (explicity filename)"
#cat  run_CCTM_258_7day.tin.csh

echo "===end=job=script====================================="
echo "========================================"
echo "========================================"

################################################################################

# Run the scripts

## **>> com_global.csh maybe sourcing for non existing 
## /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/lawrencium-modules.csh: No such file or directory.
## found one at /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/my-run-directory-tree/lawrencium-modules.csh
## but too old, so created a dummy lawrencium-modules.csh


set scr=../../../com_global.csh
echo "Script: ${scr}" ; cat -n ${scr} ; echo "Running ${scr}" ; 
echo "----------------------------------------"
source ${scr}
echo "========================================"

set scr=../../com_CCTM.csh
echo "Script: ${scr}" ; cat -n ${scr} ; echo "Running ${scr}" ; 

echo "----------------------------------------"
source ${scr}
echo "========================================"

## maybe source of CTM_CONC_1 error:
##   set CONCfile = ${APPL}."CONC".nc                   # CTM_CONC_1
## from: setenv EXECUTION_ID $APPL
## from: EXECUTION_ID=SARMAP_258_2012_ALL_HYBRID
## ie SARMAP_258_2012_ALL_HYBRID.CONC.nc 
## dir=  /global/scratch/pghuy/DIR_CONC/SARMAP_258_F/SARMAP_258_2012_ALL_HYBRID.CONC.nc
## but that was under "Output files" section... can't write?

set scr=../../com_CCTM_inout.csh
echo "Script: ${scr}" ; ## cat ${scr}


echo "========================================"
echo "========================================"

module list
echo "end time"
date
echo "hosting node"
hostname

 
################################################################################
# vim modeline, also see alias `vit`.  use 8 space for tab cuz cat align by 8 spaces
# vim:  noexpandtab nosmarttab noautoindent nosmartindent tabstop=8 shiftwidth=8 paste formatoptions-=cro 

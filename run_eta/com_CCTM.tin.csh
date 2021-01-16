#!/bin/csh

## file orig in /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/CCTM/com_CCTM.csh
## but may have to change slightly to run debugger/vagrant.  -tin 2021.0115

setenv LOGFILE ./${NME_LOGIOAPI}
setenv METpath ${DIR_MCIP}
setenv MCIPSUFF ${NME_DOM}_${NME_EP}
setenv ICpath ${DIR_IC}
setenv ICfile ${NME_IC}
setenv BCpath ${DIR_BC}
setenv BCfile ${NME_BC}
setenv EMISpath ${DIR_EMIS}
if (! $?EMISfile ) then
 setenv EMISfile ${NME_EMIS}
endif
#setenv EMISfile emis_206
setenv OCEANfile ${NME_OCEAN}

setenv FIL_REC ${DIR_REC}/${NME_REC}

setenv FIL_ASTEP ${DIR_ASTEP}/${NME_ASTEP}

setenv EXECPATH ${DIR_CMAQ_W}/bin/CCTM
setenv EXECNAME cctm
which cctm ## tin

setenv REC_FILE ${DIR_REC}/${NME_REC}

setenv IOAPI_CHECK_HEADERS T
setenv EXECUTION_ID $APPL

# Remove existing log file
rm -v $LOGFILE
echo "ignore above if rm  LOGFILE ($LOGFILE)  error  out"  ## tin

# Write IOAPI log on succesful write
setenv IOAPI_LOG_WRITE Y

# Stop on inconsistent input file [ T | Y | F | N ]
setenv FL_ERR_STOP T

# Remove existing output files? One of delete, update, keep
set DISP = delete

# Output files
set CONCfile = ${APPL}."CONC".nc                   # CTM_CONC_1
set CHKfile = ${APPL}."CHK".nc                     # CONC_CHK
set L2CHKfile = ${APPL}."L2CHK".nc                 # CONC_L2CHK
set L4CHKfile = ${APPL}."L4CHK".nc                 # CONC_L4CHK
set L5CHKfile = ${APPL}."L5CHK".nc                 # CONC_L5CHK
set AL5CHKfile = ${APPL}."AL5CHK".nc               # CONC_AL5CHK
set L5FCHKfile = ${APPL}."L5FCHK".nc               # CONC_LF5CHK
set L6CHKfile = ${APPL}."L6CHK".nc                 # CONC_L6CHK
set ACONCfile = ${APPL}."ACONC".nc                 # A_CONC_1
set DD1file = ${APPL}."DRYDEP".nc                  # CTM_DRY_DEP_1
set WD1file = ${APPL}."WETDEP1".nc                 # CTM_WET_DEP_1
set WD2file = ${APPL}."WETDEP2".nc                 # CTM_WET_DEP_2
set AV1file = ${APPL}."AEROVIS".nc                 # CTM_VIS_1
set AD1file = ${APPL}."AERODIAM".nc                # CTM_DIAM_1
set PG1file = ${APPL}."PING".nc                    # CTM_PING_1
set PGDfile = ${APPL}."PINGDRYDEP".nc              # CTM_PING_DDEP_1
set PGWfile = ${APPL}."PINGAERODIAM".nc            # CTM_PING_DIAM_1
set PA1file = ${APPL}."PA_1".nc                    # CTM_IPR_1
set PA2file = ${APPL}."PA_2".nc                    # CTM_IPR_2
set PA3file = ${APPL}."PA_3".nc                    # CTM_IPR_3
set IRR1file = ${APPL}."IRR_1".nc                  # CTM_IRR_1
set IRR2file = ${APPL}."IRR_2".nc                  # CTM_IRR_2
set IRR3file = ${APPL}."IRR_3".nc                  # CTM_IRR_3

# Log file name extensions.
setenv CTM_APPL $APPL

# Floor file
setenv FLOOR_FILE ${DIR_OUT}/FLOOR_${APPL}.nc

# Ping floor file [remember: env var .le. 16 chars]
setenv PLUME_FLOOR_FILE ${DIR_OUT}/CPLUME_FLOOR_${APPL}.nc

# Location of GRIDDESC file and grid name (the grid name is defined in the
# GRIDDESC file)
setenv GRIDDESC $METpath/GRIDDESC
setenv GRID_NAME `sed -n '2p' $GRIDDESC | sed s/\'//g`

# Input files and directories

# Location of JPROC outputs
setenv JVALpath ${DIR_RUN}/JPROC/${CMAQ_CONF} 

# Where OCEANfile is
#set OCEANpath = ${DIR_OCEAN}

set TR_EMpath = $EMISpath
set TR_EMfile = $EMISfile

set GC_ICpath = $ICpath
set GC_ICfile = $ICfile

set GC_BCpath = $BCpath
set GC_BCfile = $BCfile

set GC2file = ${MCIPSUFF}.GRIDCRO2D.nc
set GC3file = ${MCIPSUFF}.GRIDCRO3D.nc
set GD2file = ${MCIPSUFF}.GRIDDOT2D.nc
if ( ! $?MC2file ) then
  set MC2file = ${MCIPSUFF}.METCRO2D.nc
endif
set MD3file = ${MCIPSUFF}.METDOT3D.nc
set MC3file = ${MCIPSUFF}.METCRO3D.nc
set MB3file = ${MCIPSUFF}.METBDY3D.nc

set TR_DVpath = $METpath
set TR_DVfile = $MC2file

# 7-level photolysis data with file header
set JVALfile = JTABLE_

set AE_ICpath = $ICpath
set NR_ICpath = $ICpath
set TR_ICpath = $ICpath
set AE_ICfile = $ICfile
set NR_ICfile = $ICfile
set TR_ICfile = $ICfile

set AE_BCpath = $BCpath
set NR_BCpath = $BCpath
set TR_BCpath = $BCpath
set AE_BCfile = $BCfile
set NR_BCfile = $BCfile
set TR_BCfile = $BCfile

# KZMIN: if set to true (T), Kzmin (I am assuming "minimum vetrical eddy
# diffusivity coefficient") is calculated online as a function of the
# percentage of urban area in each cell (Kzmin = (0.5 * (1.0 - Furban)) + (2.0
# * Furban) where "Furban" is the fraction of urban area in the grid cell (from
# 0.0 to 1.0)). If set to false (F), a constant value (in space and time) of
# 1.0 m2/s is used. As of now (July 15th 2013) I don't have enough data to have
# the percentage of urban area in my MCIP outputs (variable PURB).
#setenv KZMIN T 
#setenv KZMIN F
# Script to define input and output files and directories from the variables
# set above. Note: use the default given in the CMAQ v4.5-ADJ script tar ball.
echo "DBG:: is beolow sourceing ok? ($DIR_RUN) -Tin" 
##source ${DIR_RUN}/CCTM/com_CCTM_inout.csh
## running my local copy -Tin 2021.0115
source ./com_CCTM_inout.csh
if ( $status ) then
  echo "Error when sourcing com_CCTM_inout.csh"
	echo "exiting 1 -Tin" ## 2021.0115 
  exit 1
endif

# Look for existing log files and delete them if appropriate
cd ${DIR_OUT}
set test = `ls CTM_LOG_???.${APPL}`
if ( "$test" != "" ) then
  if ( $DISP == 'delete' ) then
    echo " ancillary log files being deleted"
    foreach file ( $test )
      echo " deleting $file"
      rm -v $file
    end
  else
    echo "*** Logs exist - run ABORTED ***"
    exit 1
  endif
endif

setenv CTM_STDATE $STDATE
setenv CTM_STTIME $STTIME
setenv CTM_RUNLEN $NSTEPS
setenv CTM_TSTEP $TSTEP
setenv CTM_PROGNAME $EXECNAME

# mpirun executable
set MPIRUN = `which mpirun`

# Verbose
echo "Complete environment:"
env

echo "TIN:  which-ing cctm:"
which cctm
which CCTM

# Executable call for single PE
if ( $NPROCS == 1 ) then
  echo "about to run in single thread: time $NPROCS $EXECPATH/$EXECNAME"
  time  $EXECPATH/$EXECNAME
else
  # Executable call for multiple PE, set location of MPIRUN script
  #time $MPIRUN -v --mca btl openib,self,sm -np $NPROCS valgrind $EXECPATH/$EXECNAME
  # Don't forget to set NPCOL_NPROW
  #time $MPIRUN -v -np $NPROCS valgrind --track-origins=yes --leak-check=yes $EXECPATH/$EXECNAME
  echo "about to run : time $MPIRUN -v -np $NPROCS $EXECPATH/$EXECNAME"
	echo "cctm  via vagrant  may need to be chaned here. Tin" # 2021.0115
  time $MPIRUN -v -np $NPROCS $EXECPATH/$EXECNAME
endif

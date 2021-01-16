# in_out.q

#### script cp from /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/CCTM/com_CCTM_inout.csh  
echo "____running TIN's local copy of com_CCTM_inout.csh"

# RCS file, release, date & time of last delta, author, state, [and locker]
# $Header: /project/work/rep/SCRIPTS/src/cctm/in_out.q,v 1.3 2005/03/17 21:54:45 sjr Exp $

# what(1) key, module and SID; SCCS file; date and time of last delta:
# %W% %P% %G% %U%

# for supplementary emissions file ...

 if ( $?EMISpath2 ) then
    setenv EMIS_SUP          $EMISpath2/$EMISfile2
    if ( ! (-e $EMIS_SUP) ) then
       echo " $EMIS_SUP not used "
       endif
    endif

# for MEPSE file ...

 if ( $?MEPSEpath ) then
    setenv      MEPSE_1         $MEPSEpath/$MEPSEfile
    if ( ! (-e $MEPSE_1) ) then
       echo  " $MEPSE_1 not found "
       exit 1
       endif
    endif

# for PDM file ...

 if ( $?PDMpath ) then
    setenv      PDM_PING_1      $PDMpath/$PDMfile
    if ( ! (-e $PDM_PING_1) ) then
       echo  " $PDM_PING_1 not found "
       exit 1
       endif
    endif

# for previous Ping conc file ...

echo "TIN DBG: checking var $ PINGpath , $ PINGfile : "
##echo "TIN DBG: checking var $PINGpath , $PINGfile "
## PING... not defined 2021.0115

 if ( $?PDM_PING_1 ) then
    if ( $INIT_PING == 'F' | $INIT_PING == 'N' ) then
       setenv      CTM_PING_0   $PINGpath/$PINGfile
       if ( ! (-e $CTM_PING_0) ) then
          echo  " $CTM_PING_0 not found "
					echo  " TIN: exiting 1 CTM_PING_O  not found, space is deliberate in comment" # 2021.0116
          exit 1
          endif
       endif
    endif

# for Tracer Dep vel and Emissions

 if ( $?TR_DVpath ) then
    setenv DEPV_TRAC_1          $TR_DVpath/$TR_DVfile
    if (! (-e $DEPV_TRAC_1) ) then
       echo " $DEPV_TRAC_1 not found "
       exit 1
       endif
    endif

 if ( $?TR_EMpath ) then
    setenv EMIS_TRAC_1          $TR_EMpath/$TR_EMfile
    if (! (-e $EMIS_TRAC_1) ) then
       echo " $EMIS_TRAC_1 not found "
       exit 1
       endif
    endif

# for OCEAN file ...

 if ( $?OCEANpath ) then
    setenv      OCEAN_1      $OCEANpath/$OCEANfile
    if ( ! (-e $OCEAN_1) ) then
       echo  " $OCEAN_1 not found "
       exit 1
       endif
    endif

# for emissions file ...

 setenv     EMIS_1          $EMISpath/$EMISfile

# for ICBC files ...

 setenv     INIT_GASC_1     $GC_ICpath/$GC_ICfile
 setenv     BNDY_GASC_1     $GC_BCpath/$GC_BCfile
 setenv     INIT_AERO_1     $AE_ICpath/$AE_ICfile
 setenv     BNDY_AERO_1     $AE_BCpath/$AE_BCfile
 setenv     INIT_NONR_1     $NR_ICpath/$NR_ICfile
 setenv     BNDY_NONR_1     $NR_BCpath/$NR_BCfile
 setenv     INIT_TRAC_1     $TR_ICpath/$TR_ICfile
 setenv     BNDY_TRAC_1     $TR_BCpath/$TR_BCfile

# for meteorological files ...

 setenv     GRID_DOT_2D     $METpath/$GD2file
 setenv     GRID_CRO_2D     $METpath/$GC2file
#setenv     GRID_BDY_2D     $METpath/$GB2file
#setenv     GRID_DOT_3D     $METpath/$GD3file
 setenv     GRID_CRO_3D     $METpath/$GC3file
#setenv     GRID_BDY_3D     $METpath/$GB3file
 setenv     MET_CRO_2D      $METpath/$MC2file
#setenv     MET_BDY_2D      $METpath/$MB2file
 setenv     MET_DOT_3D      $METpath/$MD3file
 setenv     MET_CRO_3D      $METpath/$MC3file
 setenv     MET_BDY_3D      $METpath/$MB3file

# for layer definition file (use the MET_CRO_3D file)...

 setenv     LAYER_FILE      $METpath/$MC3file

# for J-values file ...

 setenv     XJ_DATA         $JVALpath/$JVALfile

#              $GRID_BDY_2D\
#              $MET_BDY_2D\

 set flist = ( $EMIS_1\
               $INIT_GASC_1\
               $BNDY_GASC_1\
               $INIT_AERO_1\
               $BNDY_AERO_1\
               $INIT_NONR_1\
               $BNDY_NONR_1\
               $INIT_TRAC_1\
               $BNDY_TRAC_1\
               $GRID_DOT_2D\
               $GRID_CRO_2D\
               $MET_CRO_2D\
               $MET_DOT_3D\
               $MET_CRO_3D\
               $MET_BDY_3D\
               $LAYER_FILE)
#               $XJ_DATA )
 foreach file ( $flist )
    if (! (-e $file) ) then
       echo " $file not found "
       exit 1
       endif
    end

# out.q
# action if the output files already exist ...
 setenv CTM_CONC_1      "${DIR_CONC}/$CONCfile -v"
 setenv CONC_CHK        "${DIR_CONC}/$CHKfile -v"
 setenv CONC_L2CHK      "${DIR_CONC}/$L2CHKfile -v"
 setenv CONC_L4CHK      "${DIR_CONC}/$L4CHKfile -v"
 setenv CONC_L5CHK      "${DIR_OUT}/$L5CHKfile -v"
 setenv CONC_AL5CHK     "${DIR_OUT}/$AL5CHKfile -v"
 setenv CONC_L5FCHK_W   "${DIR_OUT}/$L5FCHKfile -v"
 setenv CONC_L6CHK      "${DIR_OUT}/$L6CHKfile -v"
 setenv A_CONC_1        "${DIR_CONC}/$ACONCfile -v"
#setenv L_CONC_1        "${DIR_CONC}/$LCONCfile -v"
 setenv CTM_DRY_DEP_1   "${DIR_CONC}/$DD1file -v"
 setenv CTM_WET_DEP_1   "${DIR_CONC}/$WD1file -v"
 setenv CTM_WET_DEP_2   "${DIR_CONC}/$WD2file -v"
 setenv CTM_VIS_1       "${DIR_CONC}/$AV1file -v"
 setenv CTM_DIAM_1      "${DIR_CONC}/$AD1file -v"
 setenv CTM_PING_1      "${DIR_CONC}/$PG1file -v"
 setenv CTM_PING_DIAM_1 "${DIR_CONC}/$PGDfile -v"
 setenv CTM_PING_DDEP_1 "${DIR_CONC}/$PGWfile -v"
 setenv CTM_IPR_1       "${DIR_CONC}/$PA1file -v"
 setenv CTM_IPR_2       "${DIR_CONC}/$PA2file -v"
 setenv CTM_IPR_3       "${DIR_CONC}/$PA3file -v"
 setenv CTM_IRR_1       "${DIR_CONC}/$IRR1file -v"
 setenv CTM_IRR_2       "${DIR_CONC}/$IRR2file -v"
 setenv CTM_IRR_3       "${DIR_CONC}/$IRR3file -v"

#              $L_CONC_1\

 set flist = ( $CTM_CONC_1\
	       $CONC_CHK\
	       $CONC_L2CHK\
	       $CONC_L4CHK\
	       $CONC_L5CHK\
	       $CONC_L6CHK\
               $A_CONC_1\
               $CTM_DRY_DEP_1\
               $CTM_WET_DEP_1\
               $CTM_WET_DEP_2\
               $CTM_VIS_1\
               $CTM_DIAM_1\
               $CTM_PING_1\
               $CTM_PING_DIAM_1 \
               $CTM_PING_DDEP_1 \
               $CTM_IPR_1\
               $CTM_IPR_2\
               $CTM_IPR_3\
               $CTM_IRR_1\
               $CTM_IRR_2\
               $CTM_IRR_3 )
# unalias rm
# foreach file ( $flist )
#    if ( $file != '-v' ) then
#       if ( -e $file ) then
#          echo " $file already exists "
#          if ( $DISP == 'delete' ) then
#             echo " $file being deleted "
#             rm $file
#             else if ( $DISP == 'update' ) then
#             echo " $file being updated "
#             else
#             echo "*** RUN ABORTED ***"
#             exit 1
#             endif
#          endif
#       endif
#    end

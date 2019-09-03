
C***********************************************************************
C   Portions of Models-3/CMAQ software were developed or based on      *
C   information from various groups: Federal Government employees,     *
C   contractors working on a United States Government contract, and    *
C   non-Federal sources (including research institutions).  These      *
C   research institutions have given the Government permission to      *
C   use, prepare derivative works, and distribute copies of their      *
C   work in Models-3/CMAQ to the public and to permit others to do     *
C   so.  EPA therefore grants similar permissions for use of the       *
C   Models-3/CMAQ software, but users are requested to provide copies  *
C   of derivative works to the Government without restrictions as to   *
C   use by others.  Users are responsible for acquiring their own      *
C   copies of commercial software associated with Models-3/CMAQ and    *
C   for complying with vendor requirements.  Software copyrights by    *
C   the MCNC Environmental Modeling Center are used with their         *
C   permissions subject to the above restrictions.                     *
C***********************************************************************


C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/ICON/src/input/radmconc/hw_r2fd.icl,v 1.1.1.1 2005/09/09 19:23:43 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)hw_r2fd.icl	2.1 /project/mod3/ICON/src/input/radmconc/SCCS/s.hw_r2fd.icl 17 May 1997 08:34:06

C######################################################################
C## filename:       hr_r2fd.icl
C## model version:  HR-RADM (Soon to be RADM 2.7)
C## date:           October 5, 1991
C## developer:      AREAL, EPA  & CSC
C######################################################################
      CHARACTER*5   R2FDSD              !START DATE (YYDDD)
      CHARACTER*6   R2FDST,R2FDSS       !START TIME AND STEP SIZE
      CHARACTER*8   R2FDGID             !GRID NAME FOR DATA IN FILE
      CHARACTER*1   R2FDTST             !TEST SWITCH INDICATOR
      CHARACTER*4   R2FDNUM             !# OF DIM. DESCRIPTIONS
      CHARACTER*10  R2FDDMG(5)          !DIM. GROUP UP TO 5 LABEL -VALUE
      CHARACTER*80  R2FDSTR
      CHARACTER*1   R2FDAR(80)
      EQUIVALENCE  (R2FDSTR,R2FDAR(1))
      EQUIVALENCE  (R2FDAR(1),R2FDSD)
      EQUIVALENCE  (R2FDAR(6),R2FDST)
      EQUIVALENCE  (R2FDAR(12),R2FDSS)
      EQUIVALENCE  (R2FDAR(18),R2FDGID)
      EQUIVALENCE  (R2FDAR(26),R2FDTST)
      EQUIVALENCE  (R2FDAR(27),R2FDNUM)
      EQUIVALENCE  (R2FDAR(31),R2FDDMG(1))
      EQUIVALENCE  (R2FDAR(41),R2FDDMG(2))
      EQUIVALENCE  (R2FDAR(51),R2FDDMG(3))
      EQUIVALENCE  (R2FDAR(61),R2FDDMG(4))
      EQUIVALENCE  (R2FDAR(71),R2FDDMG(5))
C#####################################################################
C#####################################################################

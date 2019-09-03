
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/ICON/src/mech_conv/user_defined/skipline.F,v 1.1.1.1 2005/09/09 19:23:43 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%


      SUBROUTINE SKIPLINE

C***********************************************************************
C
C  FUNCTION: SKIPLINE reads to the next semicolon
C
C  PRECONDITIONS: None
C 
C  KEY SUBROUTINES/FUNCTIONS CALLED: GETCHR
C                                    RDLINE
C
C  REVISION HISTORY: Prototype created by Jerry Gipson, January, 1998
C
C***********************************************************************
      IMPLICIT NONE
      
C..INCLUDES:
      INCLUDE 'PARSE.EXT' 
      
C..ARGUMENTS: None
                                        
C..PARAMETERS: None

C..EXTERNAL FUNCTIONS: None

C..SAVED LOCAL VARIABLES: None 

C..SCRATCH LOCAL VARIABLES: None
         
C***********************************************************************

   20 CONTINUE
      CALL GETCHR
      IF( CHR .NE. ';' ) GO TO 20

      RETURN

      END

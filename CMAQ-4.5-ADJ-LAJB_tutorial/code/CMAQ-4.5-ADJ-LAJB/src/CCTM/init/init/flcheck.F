
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/CCTM/src/init/init/flcheck.F,v 1.1.1.1 2005/09/09 18:56:06 sjr Exp $

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

       SUBROUTINE FLCHECK SUBST_GRID_ID ( STDATE, STTIME, TSTEP )

C----------------------------------------------------------------------
C Function: To check file header data for consistency with COORD.EXT
C            and runlength; only gridded and boundary files are checked.

C Preconditions: None

C Key Subroutines/Functions Called:

C Revision History: Prototype created by Jerry Gipson, September, 1997
C                   Modified Jun, 1998 by Jerry Gipson to remove PING
C                   and MEPSE files from being checked
C                   Jeff - Nov 2000 - ck only input files for start date/time
C   30 Mar 01 J.Young: elim reference to grid
C
C   12 Sep 2013 Lucas A. J. Bastien. Added an if statement so that
C   CHECK3 (for checking the presence of the initial step in the file)
C   is not called on checkpoint files (used in CMAQ-v4.5-ADJ). At this
C   point, the initial step has not been written in checkpoint files and
C   calling CHECK3 on them results in header inconsistency warning/error.
C
C   23 Sep 2013 Lucas A. J. Bastien. Added a logical switch (variable
C   CHKPROC in module ADJPRM) that controls whether only headers of
C   non-checkpoint files or only headers of checkpoint files are
C   checked. Also excluded the check of CTM_DRY_DEP_1 in one specific
C   problematic situation.
C
C   08 Oct 2013 Lucas A. J. Bastien. Removed support for CONC_L2CHK and
C   CONC_L3CHK since they are not used for sensitivity analysis.
C
C   25 Jul 2014 Lucas A. J. Bastien. Improved checking mechanism for
C   CTM_DRY_DEP_1 when running backward loop without running the forward
C   loop in the same run.
C
C   25 Jul 2014 Lucas A. J. Bastien. Added file check for FIL_REC (done
C   separately from other files because it has specific requirements).
C
C   28 Jul 2014 Lucas A. J. Bastien. Removed support for L6CHK.
C
C   14 Aug 2014 Lucas A. J. Bastien. Modified checks for FIL_REC so that
C   it supports backward loop restart runs.
C----------------------------------------------------------------------

      USE ADJPRM                ! Adjoint parameters

      IMPLICIT NONE

C..INCLUDES:
!     INCLUDE SUBST_HGRD_ID     ! horizontal dimensioning parameters
!     INCLUDE SUBST_VGRD_ID     ! vertical dimensioning parameters
      INCLUDE SUBST_IOPARMS     ! I/O parameters definitions
      INCLUDE SUBST_IOFDESC     ! file header data structure
      INCLUDE SUBST_IODECL      ! I/O definitions and declarations
!     INCLUDE SUBST_COORD_ID    ! coord. and domain definitions (req IOPARMS)
      INCLUDE SUBST_FILES_ID    ! file name parameters

C..ARGUMENTS:
      INTEGER STDATE              ! Current date (YYYYDDD)
      INTEGER STTIME              ! Current time (HHMMSS)
      INTEGER TSTEP               ! Current time step (HHMMSS)

C..PARAMETERS:

C..EXTERNAL FUNCTIONS:
      INTEGER ENVINT    ! Gets integer value of environment variable
      LOGICAL ENVYN     ! Gets logical value of environment variable
      INTEGER, EXTERNAL :: TIME2SEC ! Converts HHMMSS to raw seconds

C..SAVED LOCAL VARIABLES: None

C..SCRATCH LOCAL VARIABLES:
      CHARACTER*80 MSG    ! Message
      CHARACTER*16 PNAME  ! Program name

      INTEGER JDATE     ! Time step date (YYYYDDD)
      INTEGER JTIME     ! Time step time (HHMMSS)
      INTEGER N         ! Loop index
      INTEGER STATUS    ! Status of returned value

      LOGICAL LERROFF   ! Flag to stop run if errors found
      LOGICAL LERROR    ! Flag to indicate error for 1 or more files
      LOGICAL LOK       ! Flag to indicate error for 1 file
      LOGICAL LMISC     ! Flag for other errors

      LOGICAL ISCHK     ! Flag to indicate whether the current file is a
                        ! checkpoint file

C----------------------------------------------------------------------

      DATA PNAME/'FLCHECK'/

      LERROFF = .TRUE.
      LERROFF = ENVYN( 'FL_ERR_STOP', 'Flag for stopping on errors',
     &           LERROFF, STATUS )

      LERROR = .FALSE.

      DO N = 1, N_FILES

C Is that a (legit) checkpoint file?

         ISCHK = ( ( TRIM(LGCL_NAME(N)) .EQ. "CONC_CHK" ) .OR.
     &             ( TRIM(LGCL_NAME(N)) .EQ. "CONC_L2CHK" ) .OR.
     &             ( TRIM(LGCL_NAME(N)) .EQ. "CONC_L4CHK" ) .OR.
     &             ( TRIM(LGCL_NAME(N)) .EQ. "CONC_L5CHK" ) .OR.
     &             ( TRIM(LGCL_NAME(N)) .EQ. "CONC_AL5CHK" ) .OR.
     &             ( TRIM(LGCL_NAME(N)) .EQ. "CONC_L5FCHK_R" ) .OR.
     &             ( TRIM(LGCL_NAME(N)) .EQ. "CONC_L5FCHK_W" ))

C Check either all non-chekpoint files or only checkpoint files
C (depending on value of CHKPROC).

         IF ( ( CHKPROC .AND. ISCHK ) .OR.
     &      ( (.NOT. CHKPROC) .AND. (.NOT. ISCHK) ) )  THEN

            LOK = OPEN3( LGCL_NAME( N ), FSREAD3, PNAME )

            IF ( LOK ) THEN

               IF ( DESC3( LGCL_NAME( N ) ) ) THEN

C only check gridded or boundary files

                  IF ( FTYPE3D .EQ. GRDDED3 .OR. FTYPE3D .EQ. BNDARY3 ) THEN

                     MSG = 'Checking header data for file: ' // LGCL_NAME( N )
                     CALL M3MESG( MSG )

                     CALL GRDCHECK SUBST_GRID_ID ( LGCL_NAME( N ), LOK )

c Check time steps for time dependent files. Note that at this point,
c ACONC and *CHK files will contain no data beyond the netcdf
c header. For these files, the start/end dates and times will therefore
c not be found and we skip this check. Also, if we are not running a
c backward simulation, checking the RECEPTOR file might lead to false
c errors (since the RECEPTOR file is used only during backward
c simulations, not during forward simulations) which we can ignore. We
c skip the test in that case too

                     IF ((TSTEP3D .GT. 0) .AND. (.NOT. ISCHK) .AND.
     &                   (TRIM(LGCL_NAME(N)) .NE. "A_CONC_1") .AND.
     &                   (RTO_BWD .OR. (TRIM(LGCL_NAME(N))
     &                                  .NE. "FIL_REC"))) THEN

                        JDATE = STDATE
                        JTIME = STTIME

                        LMISC = CHECK3( LGCL_NAME( N ), ALLVAR3,
     &                                  JDATE, JTIME )

                        IF ( .NOT. LMISC ) THEN

C There is a specific case that needs specific work around. It is when
C running the backward loop without running the forward loop (when the
C forward loop has been run in a separate run), and the backward loop
C starts at the same STIME/SDATE than the forward loop. In that case,
C CTM_DRY_DEP_1 already exists but its SDATE/STIME is one TSTEP3D later
C than the SDATE/STIME of the simulation (by construction). Therefore,
C before declaring that the simulation SDATE/STIME is not in
C CTM_DRY_DEP_1, FLCHECK needs to check the next time step too. As of
C now, CTM_DRY_DEP_1 is not used in the backward run, so skipping its
C checking would seem acceptable. However, it is better to have the
C proper check already implemeted in case CTM_DRY_DEP_1 becomes used in
C later versions of this code. Note that this whole thing is a non-issue
C when the forward run includes spin-up that the backward run excludes,
C because in that case SDATE/STIME of the backward simulation will be in
C the CTM_DRY_DEP_1 file.

                           IF ( RTO_BWD .AND. (.NOT. RTO_FWD) .AND.
     &                     (TRIM(LGCL_NAME(N)) .EQ. "CTM_DRY_DEP_1") )
     &                     THEN

                              CALL NEXTIME ( JDATE, JTIME, TSTEP3D )

                              IF ( .NOT. CHECK3(LGCL_NAME( N ), ALLVAR3,
     &                                          JDATE, JTIME )) THEN

                                 LOK = .FALSE.
                                 MSG = 'Wrong CTM_DRY_DEP_1 start time'
                                 CALL M3MESG( MSG )

                              END IF

                              CALL NEXTIME ( JDATE, JTIME, -TSTEP3D )

                           ELSE ! Not the CTM_DRY_DEP_1 special case

                              LOK = .FALSE.
                              MSG = 'Starting time not on file'
                              CALL M3MESG( MSG )

                           END IF ! Special case for CTM_DRY_DEP_1

                        END IF ! .NOT. LMISC

c skip checking ending time for output files

                        IF ( IN_MODE( N ) ) THEN
                           CALL NEXTIME ( JDATE, JTIME, ADJ_RUNLEN )
                           IF ( .NOT. CHECK3( LGCL_NAME( N ), ALLVAR3,
     &                                        JDATE, JTIME ) ) THEN
                              LOK = .FALSE.
                              MSG = 'Ending time not on file'
                              CALL M3MESG( MSG )
                           END IF
                        END IF

                     END IF   ! if TSTEP3D .GT. 0

                     IF ( .NOT. LOK ) LERROR = .TRUE.

                  END IF   ! only check gridded or boundary files
               ELSE
               LOK = .FALSE.
               MSG = 'DESC3 failed for ' // LGCL_NAME( N )
               CALL M3MESG( MSG )
               END IF   ! DESC3 successful
            END IF   ! successful open

!           IF ( LOK ) THEN
               IF( .NOT. CLOSE3( LGCL_NAME( N ) ) ) THEN
                  MSG = '  >>> COULD NOT CLOSE ' // LGCL_NAME( N )
                  CALL M3WARN ( PNAME, STDATE, STTIME, MSG )
                  END IF
!              END IF

         END IF  ! skip Ping and Mepse files

      END DO

C     So was there any error or not?

      IF ( LERROR ) THEN
         MSG = 'Inconsistent header data on input files'
         IF (LERROFF ) THEN
            CALL M3EXIT ( PNAME, STDATE, STTIME, MSG, XSTAT2 )
         ELSE
            CALL M3WARN ( PNAME, STDATE, STTIME, MSG )
         END IF
      ELSE
         MSG = '   No inconsistent header data found on input files'
         CALL M3MESG( MSG )
      END IF

C     Check FIL_REC separately (M3EXIT if anything goes wrong)

      IF (RTO_BWD) THEN

C     Re-initialize LOK

         LOK = .TRUE.

C     Check that it can be opened and that its file description can be
C     read

         MSG = "Checking header data for file: FIL_REC"
         CALL M3MESG( MSG )

         IF ( .NOT. OPEN3( FIL_REC, FSREAD3, PNAME ) ) THEN
            MSG = "Cannot open FIL_REC for checking"
            CALL M3EXIT ( PNAME, STDATE, STTIME, MSG, XSTAT1 )
         END IF

         IF ( .NOT. DESC3( FIL_REC ) ) THEN
            MSG = "Cannot get FIL_REC description for checking"
            CALL M3EXIT ( PNAME, STDATE, STTIME, MSG, XSTAT1 )
         END IF

C     Check the grid

         CALL GRDCHECK SUBST_GRID_ID ( FIL_REC, LOK )

         IF ( .NOT. LOK ) THEN
            MSG = "Grid check failed for FIL_REC"
            CALL M3EXIT ( PNAME, STDATE, STTIME, MSG, XSTAT2 )
         END IF

C     Check that initial time (for the total simulation, including
C     restarts) is on the file

         IF ( .NOT. CHECK3(FIL_REC, ALLVAR3, ADJ_STDATE_TOT,
     &                     ADJ_STTIME_TOT) ) THEN
            MSG = "Start date/time not in FIL_REC"
            CALL M3EXIT ( PNAME, STDATE, STTIME, MSG, XSTAT2 )
         END IF

C     Check that the duration described by the receptor file is
C     consistent with the total length of the simulation (i.e. including
C     restarts). When trying to read receptor data for the last actual
C     model time step (call it n), CMAQ will try to interpolate data
C     between time steps n and n+1. The time step n+1, although not
C     actually part of the simulation, is present in the receptor file
C     so that CMAQ can do the interpolation without error, hence the -1
C     in the following line

         IF (ADJ_TOTSEC .NE. TIME2SEC(TSTEP3D)*(MXREC3D-1)) THEN
            MSG = "FIL_REC duration and simulation length mismatch"
            CALL M3EXIT ( PNAME, STDATE, STTIME, MSG, XSTAT2 )
         END IF

C     We want to close FIL_REC cleanly

         IF ( .NOT. CLOSE3( FIL_REC ) ) THEN
            MSG = "FIL_REC could not be closed"
            CALL M3EXIT ( PNAME, STDATE, STTIME, MSG, XSTAT1 )
         END IF

      END IF ! RTO_BWD, check FIL_REC

      END SUBROUTINE FLCHECK

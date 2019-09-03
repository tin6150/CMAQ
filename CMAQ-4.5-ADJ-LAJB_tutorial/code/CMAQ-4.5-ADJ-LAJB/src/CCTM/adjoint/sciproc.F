   
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

C:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      SUBROUTINE SCIPROC ( CGRID, JDATE, JTIME, TSTEP, ASTEP, LAST )

C-----------------------------------------------------------------------
C Function:
C    Controls all of the physical and chemical processes for a grid
C    Operator splitting symmetric around chemistry

C CAUTION:
C     This is a modified SCIPROC subroutine with some of the physical processes
C     such as ADJADV,PING,CLDPROC and AERO switched off. For the adjoint model 
C     only chemistry and transport processes are considered with this package.
 
C Preconditions:
C    Dates and times represented YYYYDDD:HHMMSS.
C    No "skipped" dates and times.  All boundary input variables (layered or
C    non-layered) have the same perimeter structure with a thickness of NTHIK
 
C Subroutines and functions called:
C    All physical and chemical subroutines, 
C    DECOUPLE, COUPLE, VDIFF, XADV, YADV, ZADV, HDIFF
 
C Revision History:
C    Oct. 24, 1995 by M. Talat Odman and Clint L. Ingram at NCSC: created
C    Jeff
C    13 Dec 97 - Jeff - uncouple diffusion processes
C    27 Jun 98 - Jeff - sync step = chem step
C     7 Jul 01 - Shawn - mv cloud processing before chem
C       Jan 02 - Jeff - dyn alloc; remove PCGRID argument to ping
C    23 Jun 03 J.Young: for layer dependent advection tstep
C    18 Aug 03 J. Pleim - move vdiff before advection
C    29 Aug 03 J.Young: eliminate symmetric processing option and unsed
C                       SUBST_GRID_ID string
C     7 Dec 04 J.Young: vert dyn alloc - ASTEP assumed shape
C    31 Jan 05 J.Young: dyn alloc - establish both horizontal & vertical
C                       domain specifications in one module (GRID_CONF)
C    07 Apr 07 K.Singh & Sandu A.: Modified SCIPROC to run only processes
C                       involved in adjoint calculations.
C    04 Sep 13 Lucas A. J. Bastien: renaming some files and subroutines.
C    23 Sep 13 Lucas A. J. Bastien: Now there are FORTRAN variables that
C                                   control whether different processes
C                                   (vertical and horizontal diffusion
C                                   and advection, chemistry) are taken
C                                   into account or not. These variables
C                                   are among the RTO_* variables (RTO
C                                   for run time options), located in
C                                   the module ADJPRM, and read from the
C                                   environment.
C    08 Oct 13 Lucas A. J. Bastien: Control of whether horizontal
C                                   advection is run or not is now split
C                                   between advection in the x direction
C                                   and advection in the y direction
C                                   (removed the variable RTO_HADV and
C                                   added the variables RTO_XADV and
C                                   RTO_YADV). Also, added switch to
C                                   control whether checkpointing should
C                                   be done or not. This behavior is
C                                   controlled by the variable
C                                   RTO_CHK. This variable is set by the
C                                   user at run time using the
C                                   environment variable of the same
C                                   name.
C    15 Nov 13 Lucas A. J. Bastien: Fixed conditions for when
C                                   COUPLE/DECOUPLE should be
C                                   called. Note that I am still
C                                   confused with this so it might still
C                                   not be correct.
C    24 Jul 14 Lucas A. J. Bastien: Removed RTO_* options that
C                                   corresponded to mechanism selection
C                                   (I'm not sure how to deal with
C                                   couple/decouple when only a few
C                                   mechanisms are selected).
C    28 Jul 14 Lucas A. J. Bastien: Now L4CHK only contains the variable
C                                   RHOJ. I made the necessary changes
C                                   for that.
C    14 Aug 14 Lucas A. J. Bastien: Added support for restart runs,
C                                   independently for forward and
C                                   backward runs.
C-----------------------------------------------------------------------

      USE PCGRID_DEFN  ! inherits GRID_CONF and CGRID_SPCS
!     USE CGRID_SPCS   ! CGRID species number and offsets
      USE ADJPRM       ! Adjoint parameters

      IMPLICIT NONE   

C Include files:

!     INCLUDE SUBST_HGRD_ID     ! horizontal dimensioning parameters
!     INCLUDE SUBST_VGRD_ID     ! vertical dimensioning parameters
      INCLUDE SUBST_GC_SPC      ! gas chemistry species table
!     INCLUDE SUBST_AE_SPC      ! aerosol species table
!     INCLUDE SUBST_NR_SPC      ! non-reactive species table
!     INCLUDE SUBST_TR_SPC      ! tracer species table
      INCLUDE SUBST_IOPARMS     ! I/O parameters definitions
      INCLUDE SUBST_IOFDESC     ! file header data structure
      INCLUDE SUBST_IODECL      ! I/O definitions and declarations
      INCLUDE SUBST_PACTL_ID    ! PA control parameters
      INCLUDE SUBST_FILES_ID    ! I/O definitions and declarations

C Arguments:
      REAL, POINTER :: CGRID( :,:,:,: )

      INTEGER   :: JDATE        ! current model date, coded YYYYDDD
      INTEGER   :: JTIME        ! current model time, coded HHMMSS
      INTEGER   :: TSTEP( 2 )   ! time step vector (HHMMSS)
                                ! TSTEP(1) = local output step
                                ! TSTEP(2) = sciproc sync. step (chem)

!     INTEGER      ASTEP( NLAYS )  ! layer advection time step
      INTEGER   :: ASTEP( : )      ! layer advection time step
      LOGICAL   :: LAST            ! Flag for last iteration

C Parameters:

C External Functions (not already declared by IODECL3.EXT):

      INTEGER, EXTERNAL :: INDEX1
      LOGICAL, EXTERNAL :: ENVYN
      LOGICAL, EXTERNAL :: PWRITE3

C Local Variables:

      CHARACTER( 16 ) :: PNAME = 'SCIPROC'

      LOGICAL, SAVE :: FIRSTIME = .TRUE.
      LOGICAL, SAVE :: XFIRST

      CHARACTER( 120 ) :: XMSG = ' '
      CHARACTER( 36 ) :: NMSG = 'After NEXTIME: returned JDATE, JTIME'

      INTEGER, SAVE :: LOGDEV

      INTEGER      SDATE        ! current science process date, coded YYYYDDD
      INTEGER      STIME        ! current science process time, coded HHMMSS
 
      INTEGER      ALLOCSTAT
      INTEGER      STATUS          ! ENV... status
      CHARACTER( 80 ) :: VARDESC   ! environment variable description
      CHARACTER( 80 ) :: MSG = ' '
      CHARACTER( 16 ) :: CTM_CKSUM = 'CTM_CKSUM'     ! env var for cksum on
!     LOGICAL, SAVE   :: CKSUM     ! flag for cksum on, default = [F]
      LOGICAL, SAVE   :: CKSUM     ! flag for cksum on, default = [T]
      INTEGER, SAVE   :: IRHOJ     ! Index of RHOJ in CGRID

      INTERFACE
         SUBROUTINE CKSUMMER ( PNAME, CGRID, JDATE, JTIME )
            IMPLICIT NONE
            CHARACTER( * ), INTENT( IN ) :: PNAME
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
         END SUBROUTINE CKSUMMER
         SUBROUTINE PA_UPDATE ( PNAME, CGRID, JDATE, JTIME, TSTEP )
            IMPLICIT NONE
            CHARACTER( * ), INTENT( IN ) :: PNAME
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
         END SUBROUTINE PA_UPDATE
         SUBROUTINE XADV ( CGRID, JDATE, JTIME, TSTEP, ASTEP )
            IMPLICIT NONE
!           INCLUDE SUBST_VGRD_ID     ! vertical dimensioning parameters
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
            INTEGER, INTENT( IN )     :: ASTEP( : )
         END SUBROUTINE XADV
         SUBROUTINE YADV ( CGRID, JDATE, JTIME, TSTEP, ASTEP )
            IMPLICIT NONE
!           INCLUDE SUBST_VGRD_ID     ! vertical dimensioning parameters
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
            INTEGER, INTENT( IN )     :: ASTEP( : )
         END SUBROUTINE YADV
         SUBROUTINE ZADV ( CGRID, JDATE, JTIME, TSTEP )
            IMPLICIT NONE
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
         END SUBROUTINE ZADV
!        SUBROUTINE LOAD_RHOJ ( CGRID, JDATE, JTIME )
!           IMPLICIT NONE
!           REAL, POINTER             :: CGRID( :,:,:,: )
!           INTEGER, INTENT( IN )     :: JDATE, JTIME
!        END SUBROUTINE LOAD_RHOJ
         SUBROUTINE ADJADV ( CGRID, JDATE, JTIME, TSTEP )
            IMPLICIT NONE
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
         END SUBROUTINE ADJADV
         SUBROUTINE COUPLE ( CGRID, JDATE, JTIME, TSTEP )
            IMPLICIT NONE
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
         END SUBROUTINE COUPLE
         SUBROUTINE DECOUPLE ( CGRID, JDATE, JTIME, TSTEP )
            IMPLICIT NONE
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
         END SUBROUTINE DECOUPLE
         SUBROUTINE HDIFF ( CGRID, JDATE, JTIME, TSTEP )
            IMPLICIT NONE
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
         END SUBROUTINE HDIFF
         SUBROUTINE VDIFF ( CGRID, JDATE, JTIME, TSTEP )
            IMPLICIT NONE
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
         END SUBROUTINE VDIFF
!#       SUBROUTINE PING ( PCGRID, JDATE, JTIME, TSTEP )
!#          IMPLICIT NONE
!#          REAL, INTENT( INOUT )     :: PCGRID( :,:,:,: )
!#          INTEGER, INTENT( IN )     :: JDATE, JTIME
!#          INTEGER, INTENT( IN )     :: TSTEP( 2 )
!#       END SUBROUTINE PING
         SUBROUTINE CLDPROC ( CGRID, JDATE, JTIME, TSTEP )
            IMPLICIT NONE
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
         END SUBROUTINE CLDPROC
         SUBROUTINE CHEM ( CGRID, JDATE, JTIME, TSTEP )
            IMPLICIT NONE
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
         END SUBROUTINE CHEM
         SUBROUTINE AERO ( CGRID, JDATE, JTIME, TSTEP )
            IMPLICIT NONE
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
         END SUBROUTINE AERO
         SUBROUTINE WR_L4CHK ( CGRID, JDATE, JTIME )
            IMPLICIT NONE
            REAL, POINTER, INTENT(IN) :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
         END SUBROUTINE WR_L4CHK
      END INTERFACE
  
C-----------------------------------------------------------------------

      CGRID => PCGRID( 1:NCOLS,1:NROWS,:,: ) ! required for PinG

C If ISPCA .ne. 0, then air is advected and concs. are adjusted

      IF ( FIRSTIME ) THEN

         FIRSTIME = .FALSE.
         LOGDEV = INIT3 ()

!        CKSUM = .FALSE.         ! default
         CKSUM = .TRUE.          ! default
         VARDESC = 'Cksum on flag'
         CKSUM = ENVYN( CTM_CKSUM, VARDESC, CKSUM, STATUS )
         IF ( STATUS .NE. 0 ) WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            XMSG = 'Environment variable improperly formatted'
            CALL M3EXIT( PNAME, JDATE, JTIME, XMSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = 'Environment variable set but empty Using default:'
            WRITE( LOGDEV, '(5X, A, I9)' ) MSG, JTIME
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = 'Environment variable not set ... Using default:'
            WRITE( LOGDEV, '(5X, A, I9)' ) MSG, JTIME
         END IF

C     Get index of RHOJ variable in CGRID from description of CONC_CHK
C     since CRGID is written to that file. Do that only if we are
C     checkpointing

         IF (RTO_CHK) THEN

            IF ( .NOT. DESC3( CONC_CHK ) ) THEN
               MSG = "Could not get "// CONC_CHK // " file description"
               CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT1 )
            END IF

            IRHOJ = INDEX1( "RHOJ", NVARS3D, VNAME3D )
            IF ( IRHOJ .EQ. 0 ) THEN
               MSG = "Could not find index for variable RHOJ in " //
     &              CONC_CHK
               CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
            END IF

            IF (IRHOJ .NE. NVARS3D) THEN
               MSG = "Expected RHOJ to be last in " // CONC_CHK
               CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
            END IF

         END IF

C Adjust concentrations with advected Air Density X Jacobian?

!        IF ( N_GC_SPCD .GT. N_GC_SPC ) CALL LOAD_RHOJ ( CGRID, JDATE, JTIME )

C     Whether to start with x or y advection for the first iteration

         XFIRST = XFIRST_FWD
         
      END IF ! FIRSTIME

C Physical Processes for any Grid

      CALL VDIFF ( CGRID, JDATE, JTIME, TSTEP )
      IF ( CKSUM ) CALL CKSUMMER ( 'VDIFF', CGRID, JDATE, JTIME )
      IF ( LIPR ) CALL PA_UPDATE ( 'VDIF', CGRID, JDATE, JTIME, TSTEP )

C couple CGRID for advection or horizontal diffusion

      CALL COUPLE ( CGRID, JDATE, JTIME, TSTEP )
      IF ( CKSUM ) CALL CKSUMMER ( 'COUPLE', CGRID, JDATE, JTIME )

      IF ( XFIRST ) THEN
               
         XFIRST = .FALSE.
               
         CALL XADV ( CGRID, JDATE, JTIME, TSTEP, ASTEP )
         IF ( CKSUM ) CALL CKSUMMER ( 'XADV', CGRID, JDATE, JTIME )
         IF ( LIPR ) CALL PA_UPDATE ( 'XADV', CGRID, JDATE, JTIME, TSTEP )
               
         CALL YADV ( CGRID, JDATE, JTIME, TSTEP, ASTEP )
         IF ( CKSUM ) CALL CKSUMMER ( 'YADV', CGRID, JDATE, JTIME )
         IF ( LIPR ) CALL PA_UPDATE ( 'YADV', CGRID, JDATE, JTIME, TSTEP )
               
      ELSE ! .NOT. XFIRST
               
         XFIRST = .TRUE.
               
         CALL YADV ( CGRID, JDATE, JTIME, TSTEP, ASTEP )
         IF ( CKSUM ) CALL CKSUMMER ( 'YADV', CGRID, JDATE, JTIME )
         IF ( LIPR ) CALL PA_UPDATE ( 'YADV', CGRID, JDATE, JTIME, TSTEP )
               
         CALL XADV ( CGRID, JDATE, JTIME, TSTEP, ASTEP )
         IF ( CKSUM ) CALL CKSUMMER ( 'XADV', CGRID, JDATE, JTIME )
         IF ( LIPR ) CALL PA_UPDATE ( 'XADV', CGRID, JDATE, JTIME, TSTEP )

      END IF ! XFIRST
            
      CALL ZADV ( CGRID, JDATE, JTIME, TSTEP )
      IF ( CKSUM ) CALL CKSUMMER ( 'ZADV', CGRID, JDATE, JTIME )
      IF ( LIPR ) CALL PA_UPDATE ( 'ZADV', CGRID, JDATE, JTIME, TSTEP )

C     Write RHOJ in CONC_L4CHK for JDATE, JTIME

      IF (RTO_CHK) CALL WR_L4CHK(CGRID, JDATE, JTIME)

c$$$      IF ( N_GC_SPCD .GT. N_GC_SPC ) THEN
c$$$
c$$$         CALL ADJADV ( CGRID, JDATE, JTIME, TSTEP )
c$$$
c$$$         IF ( CKSUM ) CALL CKSUMMER ( 'ADJADV', CGRID, JDATE, JTIME )
c$$$         IF ( LIPR ) CALL PA_UPDATE ( 'ADJC', CGRID, JDATE, JTIME, TSTEP )
c$$$      END IF

      CALL HDIFF ( CGRID, JDATE, JTIME, TSTEP )
      IF ( CKSUM ) CALL CKSUMMER ( 'HDIFF', CGRID, JDATE, JTIME )
      IF ( LIPR ) CALL PA_UPDATE ( 'HDIF', CGRID, JDATE, JTIME, TSTEP )
         
C     Decouple CGRID for cloud and chemistry

      SDATE = JDATE
      STIME = JTIME
      CALL NEXTIME ( SDATE, STIME, TSTEP( 2 ) )

      CALL DECOUPLE ( CGRID, SDATE, STIME, TSTEP )
      IF ( CKSUM ) CALL CKSUMMER ( 'DECOUPLE', CGRID, JDATE, JTIME )
         
c$$$!     CALL PING ( PCGRID, JDATE, JTIME, TSTEP )
c$$$      CALL PING ( JDATE, JTIME, TSTEP )
c$$$      IF ( CKSUM ) CALL CKSUMMER ( 'PING', CGRID, JDATE, JTIME )
c$$$      IF ( LIPR ) CALL PA_UPDATE ( 'PING', CGRID, JDATE, JTIME, TSTEP )
c$$$
c$$$      CALL CLDPROC ( CGRID, JDATE, JTIME, TSTEP )
c$$$
c$$$      IF ( CKSUM ) CALL CKSUMMER ( 'CLDPROC', CGRID, JDATE, JTIME )
c$$$      IF ( LIPR ) CALL PA_UPDATE ( 'CLDS', CGRID, JDATE, JTIME, TSTEP )

      CALL CHEM ( CGRID, JDATE, JTIME, TSTEP ) 
      IF ( CKSUM ) CALL CKSUMMER ( 'CHEM', CGRID, JDATE, JTIME )
      IF ( LIPR ) CALL PA_UPDATE ( 'CHEM', CGRID, JDATE, JTIME, TSTEP ) 

c$$$      CALL AERO ( CGRID, JDATE, JTIME, TSTEP )
c$$$
c$$$      IF ( CKSUM ) CALL CKSUMMER ( 'AERO', CGRID, JDATE, JTIME )
c$$$      IF ( LIPR ) CALL PA_UPDATE ( 'AERO', CGRID, JDATE, JTIME, TSTEP )

      CALL NEXTIME ( JDATE, JTIME, TSTEP( 2 ) )
      WRITE( LOGDEV,'(/ 5X, A, I8, I7.6)' ) NMSG, JDATE, JTIME

      IF (LAST) THEN
         PRINT'(A, 1X, L1)', "SCIPROC: XFIRST FOR RESTART:", XFIRST
      END IF

      RETURN
      END

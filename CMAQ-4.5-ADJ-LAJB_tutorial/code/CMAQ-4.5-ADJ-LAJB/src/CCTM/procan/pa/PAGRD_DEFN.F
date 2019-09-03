
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/CCTM/src/procan/pa/PAGRD_DEFN.F,v 1.1.1.1 2005/09/09 18:56:06 sjr Exp $

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

C:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      MODULE PAGRD_DEFN

C process analysis variables that are dependent on NCOLS, NROWS

C Preconditions: HGRD_INIT() called from PAR_INIT, which is called from DRIVER

C Revision History: J.Young 17 Aug 01: create
C                   D.Wong, J.Young Oct 01: set dimensions for DELC and CSAV
C                   correctly for subdomain; IRROUT must have full domain
C                   because of SE_DATA_COPY in pa_output
C                   J.Young 31 Jan 05: dyn alloc - establish both horizontal
C                                      & vertical domain specifications in
C                                      one module
C.......................................................................

      USE GRID_CONF           ! horizontal & vertical domain specifications
      USE SUBST_MODULES       ! stenex
!     USE SUBST_UTIL_MODULE   ! stenex

      IMPLICIT NONE

C set in HGRD_DEFN ...
C BEGCOL  = Starting column for output
C ENDCOL  = Ending column for output
C BEGROW  = Starting row for output
C ENDROW  = Ending row for output
C BEGLEV  = Starting layer for output
C ENDLEV  = Ending layer for output

C Total number of columns for PA output
      INTEGER, SAVE :: PACOLS
C Total number of rows for PA output
      INTEGER, SAVE :: PAROWS
C Total number of layers for PA output
      INTEGER, SAVE :: PALEVS

C Starting column of local PA grid in a processor
      INTEGER, SAVE :: MY_BEGCOL
C Ending column of local PA grid in a processor
      INTEGER, SAVE :: MY_ENDCOL
C Starting row of local PA grid in a processor
      INTEGER, SAVE :: MY_BEGROW
C Ending row of local PA grid in a processor
      INTEGER, SAVE :: MY_ENDROW
C Starting level of local PA grid in a processor
      INTEGER, SAVE :: MY_BEGLEV
C Ending level of local PA grid in a processor
      INTEGER, SAVE :: MY_ENDLEV

C Starting column of local IRR grid in a processor
      INTEGER, SAVE :: MY_IRR_BEGCOL
C Ending column of local IRR grid in a processor
      INTEGER, SAVE :: MY_IRR_ENDCOL
C Starting row of local IRR grid in a processor
      INTEGER, SAVE :: MY_IRR_BEGROW
C Ending row of local IRR grid in a processor
      INTEGER, SAVE :: MY_IRR_ENDROW
C Starting level of local IRR grid in a processor
      INTEGER, SAVE :: MY_IRR_BEGLEV
C Ending level of local IRR grid in a processor
      INTEGER, SAVE :: MY_IRR_ENDLEV

C Number of columns of local PA/IRR grid a processor has
      INTEGER, SAVE :: MY_PACOLS
C Number of rows of local PA/IRR grid a processor has
      INTEGER, SAVE :: MY_PAROWS

C Conc difference for a science process
      REAL, ALLOCATABLE, SAVE :: DELC( :,:,:,: )

C previous Conc in a science process
      REAL, ALLOCATABLE, SAVE :: CSAV( :,:,:,: )

C Array for outputting IRR results
      REAL, ALLOCATABLE, SAVE :: IRROUT( :,:,:,: )

      CONTAINS
         FUNCTION PAGRD_INIT () RESULT ( SUCCESS )

!        INCLUDE SUBST_VGRD_ID     ! vertical dimensioning parameters
         INCLUDE SUBST_IODECL      ! I/O definitions and declarations
         INCLUDE SUBST_PACTL_ID    ! PA control parameters
         INCLUDE SUBST_PACMN_ID    ! PA common block definitions

         LOGICAL SUCCESS
C dimensioning parameters for PA outputs
         INTEGER PACOLSD
         INTEGER PAROWSD
         INTEGER PALEVSD
         INTEGER IRCOLSD
         INTEGER IRROWSD
         INTEGER IRLEVSD

         LOGICAL, SAVE :: FIRSTIME = .TRUE.
         INTEGER ALST
         INTEGER X1F0  ! dimension homotopy for parallel or serial
         CHARACTER( 16 ) :: PNAME = 'PAGRD_INIT'
         CHARACTER( 96 ) :: XMSG = ' '

C This function is expected to be called only once - at startup

         IF ( FIRSTIME ) THEN
            FIRSTIME = .FALSE.
            SUCCESS = .TRUE.

            IF ( LIPR .OR. LIRR ) THEN

               IF ( PA_BEGCOL .LT. 1 .OR. PA_ENDCOL .GT. GL_NCOLS .OR.
     &              PA_BEGROW .LT. 1 .OR. PA_ENDROW .GT. GL_NROWS .OR.
     &              PA_BEGLEV .LT. 1 .OR. PA_ENDLEV .GT. NLAYS ) THEN
                  XMSG = 'Process Analysis domain inconsistent with CTM domain' 
                  CALL M3WARN ( PNAME, 0, 0, XMSG )
                  SUCCESS = .FALSE.; RETURN
                  END IF

C Determine IPR subgrid mapping with data redistribution
               CALL SUBST_SUBGRID_INDEX
     &             ( PA_BEGCOL, PA_ENDCOL, PA_BEGROW, PA_ENDROW,
     &               PA_BEGLEV, PA_ENDLEV,
     &               MY_BEGCOL, MY_ENDCOL, MY_BEGROW, MY_ENDROW,
     &               MY_BEGLEV, MY_ENDLEV, MY_PACOLS, MY_PAROWS )

C Determine IRR subgrid mapping without data redistribution
               CALL SUBST_SUBGRID_INDEX
     &             ( PA_BEGCOL, PA_ENDCOL, PA_BEGROW, PA_ENDROW,
     &               PA_BEGLEV, PA_ENDLEV,
     &               MY_IRR_BEGCOL, MY_IRR_ENDCOL, MY_IRR_BEGROW,
     &               MY_IRR_ENDROW, MY_IRR_BEGLEV, MY_IRR_ENDLEV, 'N' )

               PACOLS = PA_ENDCOL - PA_BEGCOL + 1
               PAROWS = PA_ENDROW - PA_BEGROW + 1
               PALEVS = PA_ENDLEV - PA_BEGLEV + 1

               PACOLSD = MY_PACOLS
               PAROWSD = MY_PAROWS
               PALEVSD = PALEVS

               X1F0 = ( MY_NCOLS / GL_NCOLS ) * ( MY_NROWS / GL_NROWS )
               IRCOLSD = X1F0 * PACOLS + ( 1 - X1F0 ) * NCOLS
               IRROWSD = X1F0 * PAROWS + ( 1 - X1F0 ) * NROWS
               IRLEVSD = PALEVS

               ALLOCATE ( DELC( PACOLSD,PAROWSD,PALEVSD,NIPRVARD ),
     &                    STAT = ALST )
               IF ( ALST .NE. 0 ) THEN
                  XMSG = '*** DELC Memory allocation failed'
                  CALL M3WARN ( PNAME, 0, 0, XMSG )
                  SUCCESS = .FALSE.; RETURN
                  END IF

               ALLOCATE ( CSAV( PACOLSD,PAROWSD,PALEVSD,NCSAVED ),
     &                    STAT = ALST )
               IF ( ALST .NE. 0 ) THEN
                  XMSG = '*** CSAV Memory allocation failed'
                  CALL M3WARN ( PNAME, 0, 0, XMSG )
                  SUCCESS = .FALSE.; RETURN
                  END IF

               IF ( LIRR ) THEN

                  ALLOCATE ( IRROUT( IRCOLSD,IRROWSD,IRLEVSD,NIRRVARD ),
     &                       STAT = ALST )
                  IF ( ALST .NE. 0 ) THEN
                     XMSG = '*** IRROUT Memory allocation failed'
                     CALL M3WARN ( PNAME, 0, 0, XMSG )
                     SUCCESS = .FALSE.; RETURN
                     END IF

                  END IF

               ELSE

               XMSG = 'No Process Analysis for this run'
               CALL M3WARN ( PNAME, 0, 0, XMSG )
               SUCCESS = .TRUE.; RETURN

               END IF

            ELSE   ! called more than once

            XMSG = 'Horizontal domain dependent variables already allocated'
            CALL M3WARN ( PNAME, 0, 0, XMSG )
            SUCCESS = .FALSE.; RETURN

            END IF   ! FIRSTIME

         RETURN
         END FUNCTION PAGRD_INIT

      END MODULE PAGRD_DEFN

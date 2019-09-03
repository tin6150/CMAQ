  
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

C     September 9th 2013, Lucas A. J. Bastien: removed the line:
C     EXTERNAL INTEGRATE
C     in subroutine CHEM. The subroutine INTEGRATE is defined in module
C     KPP_INTEGRATOR (file kppIntegrator.F). This module is used in
C     subroutine CHEM.

C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/CCTM/src/adjoint/kppdriver.F,v 1.1.1.1 2005/09/09 18:56:04 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

       SUBROUTINE CHEM( CGRID, JDATE, JTIME, TSTEP )

C**********************************************************************
C
C     KPP implementaion based on MEBI backbone (A. H.)
C
C**********************************************************************

      USE HGRD_DEFN             ! horizontal domain specifications
      USE VGRD_DEFN             ! vertical layer specifications
      USE HRDATA
      USE KPP_INTEGRATOR

      IMPLICIT NONE 

C..Includes:
!     INCLUDE SUBST_HGRD_ID   ! Horizontal grid data
!     INCLUDE SUBST_VGRD_ID   ! Vertical grid data
!     INCLUDE SUBST_BLKPRM    ! Blocking parameters
      INCLUDE SUBST_IOPARMS   ! Io/api parameters
      INCLUDE SUBST_IOFDESC   ! Io/api file descriptions
      INCLUDE SUBST_IODECL    ! Io/api declarations
      INCLUDE SUBST_FILES_ID  ! CMAQ files
!     INCLUDE SUBST_COORD_ID  ! Coordinate and domain definitions (req IOPARMS)
      INCLUDE SUBST_CONST     ! CMAQ constants
      INCLUDE SUBST_GC_SPC    ! Gas chem species names and MWs
      INCLUDE SUBST_RXCMMN    ! Mechanism reaction common block
      INCLUDE SUBST_GC_EMIS   ! Gas chem emissions name and mapping tables
!      INCLUDE SUBST_PACTL_ID  ! PA control parameters
!      INCLUDE SUBST_RXDATA      ! chemical mechamism reactions DATA

#ifdef emis_chem
      INCLUDE SUBST_EMPR_CH   ! Emissions processing in chem
#else
      INCLUDE SUBST_EMPR_VD   ! Emissions processing in vdif
#endif

      INCLUDE SUBST_PACTL_ID  ! Process analysis control parameters

C..Arguments:
!     REAL CGRID( NCOLS, NROWS, NLAYS, * )  ! Species concentrations
      REAL, POINTER :: CGRID( :,:,:,: )  ! Species concentrations
      REAL CHKGRID( NCOLS, NROWS, NLAYS, N_GC_SPC + 1 )

      INTEGER JDATE           ! Current date (YYYYDDD)
      INTEGER JTIME           ! Current time (HHMMSS)
      INTEGER TSTEP( 2 )      ! Time step vector (HHMMSS)

C..Parameters:
C Pascal to atm conversion factor
      REAL, PARAMETER :: PA2ATM = 1.0 / STDATMPA

C..External Functions:
      INTEGER INDEX1          ! Looks up name in a list
      INTEGER JUNIT           ! Gets logical device number
      INTEGER SEC2TIME        ! Returns time interval from seconds
      INTEGER TIME2SEC        ! Returns seconds in time interval
      INTEGER      SDATE        ! current science process date, coded YYYYDDD
      INTEGER      STIME        ! current science process time, coded HHMMSS

C..Saved Local Variables:

      CHARACTER( 16 ), SAVE :: PNAME = 'HRDRIVER'     ! Program name

      INTEGER, SAVE :: ISTFL            ! Unit no. of iteration stat output file
      LOGICAL, SAVE :: LFIRST = .TRUE.  ! Flag for first call to this subroutine

      REAL, SAVE :: MAOMV              ! Mol Wt of air over Mol Wt of water

C..Scratch Local Variables:
      CHARACTER( 132 ) :: MSG       ! Message text
      CHARACTER(  16 ) :: VNAME     ! Name of I/O API data variable
      
      INTEGER C, E, L, R, S   ! Loop indices

      INTEGER ITMSTEP         ! Chemistry integration interval (sec)   
      INTEGER MIDDATE         ! Date at time step midpoint
      INTEGER MIDTIME         ! Time at time step midpoint
      INTEGER NDARK           ! Number of layer 1 cells in darkness
      INTEGER NPH             ! Index for number of phot. rxns in PHOT
      INTEGER SPC             ! Species loop index
      INTEGER STATUS          ! Status code
      INTEGER VAR             ! Variable number on I/O API file
      INTEGER ALLOCSTAT 
      LOGICAL LSUNLIGHT       ! Flag for sunlight

      REAL ATMPRES            ! Cell pressure
      REAL CHEMSTEP           ! Chemistry integration interval (min)
      REAL H2O                ! Cell H2O mixing ratio (ppmV)
      REAL TEMP               ! Cell Temperature

      REAL PRES(    NCOLS, NROWS, NLAYS )        ! Cell pressure (Pa)
      REAL QV(      NCOLS, NROWS, NLAYS )        ! Cell water vapor (Kg/Kg air)
      REAL TA(      NCOLS, NROWS, NLAYS )        ! Cell temperature (K)
      REAL RJIN( NPHOTAB )                       ! J-values for a cell
      REAL RJ( NCOLS, NROWS, NLAYS, NPHOTAB )    ! J-values for each cell      

      INTEGER     GXOFF, GYOFF          ! global origin offset from file
C for INTERPX
      INTEGER, SAVE :: STRTCOLMC3, ENDCOLMC3, STRTROWMC3, ENDROWMC3

      REAL*8, SAVE ::  CHEMLAST(38,38,6)

C**********************************************************************

      IF( N_GC_SPC .EQ. 0 ) RETURN

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  On first call, call routines to set-up for EBI solver and 
c  set-up to do emissions here if that option is invoked
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      IF( LFIRST ) THEN

         LOGDEV = INIT3( )

         IF( MECHNAME .NE. 'CB4             ' .AND.
     &       MECHNAME .NE. 'CB4_AQ          ' .AND. 
     &       MECHNAME .NE. 'CB4_AE          ' .AND.
     &       MECHNAME .NE. 'CB4_AE2         ' .AND. 
     &       MECHNAME .NE. 'CB4_AE3         ' .AND. 
     &       MECHNAME .NE. 'CB4_AE4         ' .AND. 
     &       MECHNAME .NE. 'CB4_AE_AQ       ' .AND.
     &       MECHNAME .NE. 'CB4_AE2_AQ      ' .AND.
     &       MECHNAME .NE. 'CB4_AE3_AQ      ' .AND.
     &       MECHNAME .NE. 'CB4_AE4_AQ      ' .AND.
     &       MECHNAME .NE. 'CB4_AE3CA_AQ    ' .AND.
     &       MECHNAME .NE. 'CB4_AE4CA_AQ    ' .AND.
     &       MECHNAME .NE. 'CB4_AE3ST_AQ    ' .AND.
     &       MECHNAME .NE. 'CB4_AE4ST_AQ    ' ) THEN
             MSG = 'This version of the EBI solver can only be used with' 
     &            // ' the CB4 chemical mechanisms' 
             CALL M3EXIT( PNAME, 0, 0, MSG, XSTAT1 )
         ENDIF

         IF( INDEX( MECHNAME, 'AE' ) .NE. 0 ) THEN
           L_AE_VRSN = .TRUE.
         ELSE
           L_AE_VRSN = .FALSE.
         ENDIF

         IF( INDEX( MECHNAME, 'AQ' ) .NE. 0 ) THEN
           L_AQ_VRSN = .TRUE.
         ELSE
           L_AQ_VRSN = .FALSE.
         ENDIF

         IF( LIRR ) THEN
            MSG = 'IRR Analysis not allowed with EBI solver'
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT1 )
         ENDIF 

         CALL HRINIT

         ITMSTEP = TIME2SEC( TSTEP( 2 ) )
         CHEMSTEP = FLOAT( ITMSTEP ) / 60.0
         WRITE( LOGDEV, 92000 ) CHEMSTEP, DELTAT

         WRITE( LOGDEV, 92020 )
         DO SPC = 1, N_GC_SPC
            WRITE( LOGDEV, 92040 ) GC_SPC( SPC ), RTOL( SPC )
         ENDDO

         MAOMV =  MWAIR / MWWAT

c..If emissions processing requested stop
         IF( EMISCH ) THEN 

            MSG = 'ERROR: EBI solver not configured to '//
     &            'process emissions in chemistry'
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT1 )

         ENDIF   ! End if doing emissions


         CALL SUBHFILE ( MET_CRO_3D, GXOFF, GYOFF,
     &                   STRTCOLMC3, ENDCOLMC3, STRTROWMC3, ENDROWMC3 )

         LFIRST = .FALSE.

         CHEMLAST(1:38,1:38,1:6)=1.0d0

      ENDIF      ! First time

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
C  Set date and time to center of time step, get necessary physical 
C  data, and get photolysis rates
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      MIDDATE = JDATE
      MIDTIME = JTIME
      ITMSTEP = TIME2SEC( TSTEP( 2 ) )
      CHEMSTEP = FLOAT( ITMSTEP ) / 60.0D+00
      CALL NEXTIME( MIDDATE, MIDTIME, SEC2TIME( ITMSTEP / 2 ) )
 
C.. Get ambient temperature in K

      VNAME = 'TA' 
      IF ( .NOT. INTERPX( MET_CRO_3D, VNAME, PNAME,
     &                    STRTCOLMC3,ENDCOLMC3, STRTROWMC3,ENDROWMC3, 1,NLAYS,
     &                    MIDDATE, MIDTIME, TA ) ) THEN
         MSG = 'Could not read TA from MET_CRO_3D'
         CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT1 )
      ENDIF
      
C.. Get specific humidity in Kg H2O / Kg air
      VNAME = 'QV'
      IF ( .NOT. INTERPX( MET_CRO_3D, VNAME, PNAME,
     &                    STRTCOLMC3,ENDCOLMC3, STRTROWMC3,ENDROWMC3, 1,NLAYS,
     &                    MIDDATE, MIDTIME, QV ) ) THEN
         MSG = 'Could not read QV from MET_CRO_3D'
         CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT1 )
      ENDIF 
      
C.. Get pressure in Pascals
      VNAME = 'PRES'
      IF ( .NOT. INTERPX( MET_CRO_3D, VNAME, PNAME,
     &                    STRTCOLMC3,ENDCOLMC3, STRTROWMC3,ENDROWMC3, 1,NLAYS,
     &                    MIDDATE, MIDTIME, PRES ) ) THEN
         MSG = 'Could not read PRES from MET_CRO_3D'
         CALL M3EXIT ( PNAME, JDATE, JTIME, MSG, XSTAT1 )
      ENDIF
 
C.. Get photolysis rates in /min
      CALL PHOT ( MIDDATE, MIDTIME, JDATE, JTIME, NDARK, RJ )        

C -------------->>
c .. Writing the checkpoints.

      CHKGRID = CGRID

c-----------------------------------------------------------------
      IF ( .NOT. WRITE3( CONC_L2CHK, ALLVAR3, 
     &             JDATE, JTIME, CGRID ) ) THEN
         MSG = 'Could not write checkpoints to CONC_L2CHK'
         CALL M3EXIT ( PNAME, JDATE, JTIME, MSG, XSTAT1 )
      ENDIF
c-----------------------------------------------------------------

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Top of loop over cells 
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      DO L = 1, NLAYS
         DO R = 1, MY_NROWS
            DO C = 1, MY_NCOLS
 
c..Load ICs
               DO S = 1, N_GC_SPC
                  YC( S ) = MAX( CGRID( C, R, L, S ), 1.0E-30 )
               ENDDO


c..Set physical quantities
               TEMP = TA( C, R, L )
               ATMPRES = PA2ATM * PRES( C, R, L )
               H2O  = MAX ( QV( C, R, L ) * MAOMV *  1.0E+06, 0.0 )


c..Get rate constants
               LSUNLIGHT = .FALSE.
               DO NPH = 1, NPHOTAB
                  RJIN( NPH ) = RJ( C, R, L, NPH )
                  IF( RJ( C, R, L, NPH ) .GT. 0.0 ) LSUNLIGHT = .TRUE.
               ENDDO                         

               CALL HRCALCKS( NPHOTAB, LSUNLIGHT, RJIN, TEMP,
     &                        ATMPRES, H2O, RKI )


c..Call EBI solver

               CHEMSTD = DBLE(CHEMSTEP)
               YCD( : ) = DBLE ( YC( : ))

               RCTRL(3) = CHEMLAST(C,R,L) !0.8*RSTAT(2) ! right now it's reset to a 1 minute in the integrator

               CALL INTEGRATE( YCD, RKI, CHEMSTD, ATOL, RTOL, 
     &         ICTRL, RCTRL, ISTAT, RSTAT, KPP_ERR)

               CHEMLAST(C,R,L) = RSTAT(2)

               IF (KPP_ERR.LT.0) THEN
                  PRINT *, C,R,L
                  STOP
               END IF
               
c..Update concentration array
               DO S = 1, N_GC_SPC 
                  CGRID( C, R, L, S ) = SNGL ( YCD( S ))
               ENDDO

            ENDDO
         ENDDO
      ENDDO


      RETURN

C*********************** FORMAT STATEMENTS ****************************

92000 FORMAT( / 10X, 'Euler Backward Iterative Parameters -'
     &        / 10X, 'Chemistry Integration Time Interval (min):', F12.4,
     &        / 10X, 'EBI maximum time step (min):              ', F12.4 )

92020 FORMAT( //10X, 'Species convergence tolerances:' )

92040 FORMAT(   10X, A16, 2X, 1PE12.2 )

      END

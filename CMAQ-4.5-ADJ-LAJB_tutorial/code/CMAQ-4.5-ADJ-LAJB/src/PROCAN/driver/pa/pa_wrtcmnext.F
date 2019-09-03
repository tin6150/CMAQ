
C***************************************************************************
C  Significant portions of Models-3/CMAQ software were developed by        *
C  Government employees and under a United States Government contract.     *
C  Portions of the software were also based on information from non-       *
C  Federal sources, including software developed by research institutions  *
C  through jointly funded cooperative agreements. These research institu-  *
C  tions have given the Government permission to use, prepare derivative   *
C  works, and distribute copies of their work to the public within the     *
C  Models-3/CMAQ software release and to permit others to do so. EPA       *
C  therefore grants similar permissions for use of Models-3/CMAQ software, *
C  but users are requested to provide copies of derivative works to the    *
C  Government without re-strictions as to use by others.  Users are        *
C  responsible for acquiring their own copies of commercial software       *
C  associated with the Models-3/CMAQ release and are also responsible      *
C  to those vendors for complying with any of the vendors' copyright and   *
C  license restrictions. In particular users must obtain a Runtime license *
C  for Orbix from IONA Technologies for each CPU used in Models-3/CMAQ     *
C  applications.                                                           *
C                                                                          *
C  Portions of I/O API, PAVE, and the model builder are Copyrighted        *
C  1993-1997 by MCNC--North Carolina Supercomputing Center and are         *
C  used with their permissions subject to the above restrictions.          *
C***************************************************************************

C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/PROCAN/src/driver/pa/pa_wrtcmnext.F,v 1.1.1.1 2005/09/09 19:19:11 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)pa_wrtcmnext.F	1.1 /project/mod3/PROCAN/src/driver/pa/SCCS/s.pa_wrtcmnext.F 04 Jul 1997 14:13:48

      SUBROUTINE PA_WRTCMNEXT

C***********************************************************************
C
C  FUNCTION: To write the Models-3 Process Analysis Commons Include
C            File 
C
C  PRECONDITIONS: Requires mechanism to have been processed
C 
C  KEY SUBROUTINES/FUNCTIONS CALLED: None
C
C  REVISION HISTORY: Prototype created by Jerry Gipson, August, 1996
C                    Modified May, 1997 by Jerry Gipson to be consistent
C                      with beta CTM
C                    Modified Sept, 1997 by Jerry Gipson to be consistent
C                      with targeted CTM
C                    Updated May 2002 by Jerry Gipson for dynamic allocation
C                      version of CCTM
C
C***********************************************************************
      IMPLICIT NONE
      
C..INCLUDES:
      INCLUDE SUBST_IODECL 
      INCLUDE 'PA_IPRDEF.EXT'
      INCLUDE 'PA_GLOBAL.EXT'
      INCLUDE 'PA_PARSE.EXT'
      INCLUDE 'PA_VARS.EXT'
      INCLUDE 'PA_INCDATA.EXT'
      
C..ARGUMENTS: None
                                        
C..PARAMETERS: None

C..EXTERNAL FUNCTIONS:

      INTEGER JUNIT    ! Function to get unit number

C..SAVED LOCAL VARIABLES: None 

C..SCRATCH LOCAL VARIABLES:

      CHARACTER*1   DOT        ! Dot character
      CHARACTER*80  DELIM      ! Delimiter line output
      CHARACTER*80  CEES       ! String of cees
      CHARACTER*78  LINOUT     ! Output line


      INTEGER IOUT        ! Unit number for include file
      INTEGER LINLEN      ! Length of output line
      INTEGER MXCGRIDD    ! Dimension for number of familys for PA
      INTEGER MXNIRRRXNSD ! Dimension parameter for MXNIRRRXNS
      INTEGER MXTEMPTRMSD ! Dimension parameter for MXTEMPTRMS
      INTEGER N           ! Loop index
      INTEGER NCSAVED     ! Dimension for NCSAVE
      INTEGER NIRRVARD    ! Dimension of IRR output variables
      INTEGER N_IPR_SPCD     ! Dimension statement for no. of PA species
      INTEGER NIPRVARD     ! Dimension of PA output variables
      INTEGER NUMTEMPSD   ! Dimension for number of temp IRRs
      INTEGER NUMOUTPOSD  ! Dimension parameter for NUMOUTPOS
      INTEGER NUMOUTNEGD  ! Dimension parameter for NUMOUTNEG
      INTEGER NUMOUTINDD  ! Dimension parameter for NUMOUTIND
      INTEGER PACOLS      ! Number of output columns
      INTEGER PAROWS      ! Number of output rows
      INTEGER PALEVS      ! Number of output levels

      LOGICAL LPROC       ! Flag for processes to be monitoring
      LOGICAL LIRR        ! Flag for IRR computations
         
C***********************************************************************
      DATA LINLEN / 78 /

      DOT = '.'

      DO N = 1, 78
         DELIM( N : N ) = DOT
         CEES(  N : N ) = 'c'
      ENDDO     
      DELIM( 1 : 1 ) = 'C'


      IF( LFULLIRR ) THEN
         LIRR    = .TRUE.
         NIRRVAR = NRXNS
      ELSEIF( LPARTIRR ) THEN
         LIRR    = .TRUE.
         NIRRVAR = NIRROUT
      ELSE
         LIRR    = .FALSE.     
      ENDIF

      IF( N_IPR_SPC .GT. 0 ) THEN
         LPROC = .TRUE.
      ELSE
         LPROC = .FALSE.
      ENDIF

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Open and Control Include file and write the header data
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      IOUT = JUNIT( )
      OPEN( UNIT = IOUT,  FILE = 'PA_CMN.EXT' )
      WRITE( IOUT, 94000 ) DELIM( 1 : 72 )
      LINOUT = 'C    INCLUDE FILE   PA_CMN.EXT'
      WRITE( IOUT, 94000 ) LINOUT
      WRITE( IOUT, 94000 ) LINOUT( 1 : 1 )
      LINOUT = 'C    CONTAINS: Common variables for Process Analysis'
      WRITE( IOUT, 94000 ) LINOUT
      WRITE( IOUT, 94000 ) LINOUT( 1 : 1 )
      LINOUT = 'C    DEPENDENT UPON: Mechanism Input file'
      WRITE( IOUT, 94000 ) LINOUT
      WRITE( IOUT, 94000 ) LINOUT( 1 : 1 )
      LINOUT = 'C    CREATED BY: Process Analysis Control Program'
      WRITE( IOUT, 94000 ) LINOUT
      LINOUT = 'C                ' // TDATOUT
      WRITE( IOUT, 94000 ) LINOUT
      WRITE( IOUT, 94000 ) LINOUT( 1 : 1 )
      WRITE( IOUT, 94000 ) DELIM( 1 : 72 )
      WRITE( IOUT, 94000 ) 

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Write messages about array dimensioning if needed
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      IF( .NOT. LIRR ) THEN
         WRITE( IOUT, 94000 ) CEES( 1 : 72 )
         WRITE( IOUT, 94020 )
         WRITE( IOUT, 94000 ) CEES( 1 : 72 )
         WRITE( IOUT, 94000 )
         wriTE( IOUT, 94000 )
      ENDIF

      IF( .NOT. LPROC ) THEN
         WRITE( IOUT, 94000 ) CEES( 1 : 72 )
         WRITE( IOUT, 94040 )
         WRITE( IOUT, 94000 ) CEES( 1 : 72 )
         WRITE( IOUT, 94000 ) 
         WRITE( IOUT, 94000 ) 
      ENDIF

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Write domain related variables
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
#ifdef nodynalloc
      WRITE( IOUT, 94000 ) CEES( 1 : 72 )
      WRITE( IOUT, 94060 )
      WRITE( IOUT, 94000 ) CEES( 1 : 72 )
      WRITE( IOUT, 94080 )
      WRITE( IOUT, 94000 ) CEES( 1 : 72 )

      IF(  .NOT. LIRR .AND. .NOT. LPROC ) THEN
         BEGCOL = 1
         ENDCOL = 1
         BEGROW = 1
         ENDROW = 1
         BEGLEV = 1
         ENDLEV = 1
         PACOLS = 1
         PAROWS = 1
         PALEVS = 1
      ELSE
         PACOLS = ENDCOL - BEGCOL + 1
         PAROWS = ENDROW - BEGROW + 1
         PALEVS = ENDLEV - BEGLEV + 1
      ENDIF

      WRITE( IOUT, 94100 ) BEGCOL,  ENDCOL,  BEGROW,  ENDROW,  BEGLEV, 
     &                     ENDLEV,  PACOLS,  PAROWS,  PALEVS

      IF( LPROC .OR. LIRR ) WRITE( IOUT, 94101 ) 

      IF( LPROC ) THEN
         WRITE( IOUT, 94102 ) 
      ELSE
         WRITE( IOUT, 94104 ) 
      ENDIF

      IF( LIRR ) THEN
         WRITE( IOUT, 94106 ) 
      ELSE
         WRITE( IOUT, 94108 ) 
      ENDIF

#endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Write output file variables 
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      WRITE( IOUT, 94000 ) CEES( 1 : 72 )
      WRITE( IOUT, 94120 ) 
      WRITE( IOUT, 94000 ) CEES( 1 : 72 )
      WRITE( IOUT, 94140 ) 
      WRITE( IOUT, 94000 ) CEES( 1 : 72 )
      WRITE( IOUT, 94160 ) NIPRVAR,  NIRRVAR
      NIPRVARD  = MAX( NIPRVAR , 1 )
      NIRRVARD  = MAX( NIRRVAR , 1 )
      WRITE( IOUT, 94180 ) NIPRVARD,  NIRRVARD
      WRITE( IOUT, 94200 )
 
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Write integrated process rate variables 
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      WRITE( IOUT, 94000 ) CEES( 1 : 72 )
      WRITE( IOUT, 94260 ) 
      WRITE( IOUT, 94000 ) CEES( 1 : 72 )
      WRITE( IOUT, 94280 ) 
      WRITE( IOUT, 94000 ) CEES( 1 : 72 )

      N_IPR_SPCD  = MAX( N_IPR_SPC, 1 )
      NCSAVED     = MAX( NCSAVE, 1 )
      MXCGRIDD    = MAX( MXCGRID, 1 )

      WRITE( IOUT, 94300 ) NPROCS,  N_IPR_SPC,  NCSAVE,  MXCGRID, 
     &                     N_IPR_SPCD, NCSAVED,  MXCGRIDD
      WRITE( IOUT, 94320 )
#ifdef nodynalloc
      WRITE( IOUT, 94321 )
#else
      WRITE( IOUT, 94322 )
#endif
 
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Write integrated reaction rate variables 
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      WRITE( IOUT, 94000 ) CEES( 1 : 72 )
      WRITE( IOUT, 94360 ) 
      WRITE( IOUT, 94000 ) CEES( 1 : 72 )
      WRITE( IOUT, 94380 ) 
      WRITE( IOUT, 94000 ) CEES( 1 : 72 )

      WRITE( IOUT, 94400 ) 
      IF( LFULLIRR ) THEN
         WRITE( IOUT, 94420 )
      ELSE
         WRITE( IOUT, 94440 )
      ENDIF

      WRITE( IOUT, 94460 ) 
      IF( LPARTIRR ) THEN
         WRITE( IOUT, 94480 )
      ELSE
         WRITE( IOUT, 94500 )
      ENDIF

      IF( .NOT. LPARTIRR ) THEN
         NUMTEMPS    = 0
         NUMOUTPOS   = 0
         NUMOUTNEG   = 0
         NUMOUTIND   = 0
         MXNIRRRXNS  = 0
         MXTEMPTRMS  = 0
      ENDIF

      WRITE( IOUT, 94520 ) NUMTEMPS,  NUMOUTPOS,  NUMOUTNEG,  NUMOUTIND, 
     &                     MXNIRRRXNS,  MXTEMPTRMS
      NUMTEMPSD    = MAX(  NUMTEMPS,   1 )
      NUMOUTPOSD   = MAX(  NUMOUTPOS,  1 )
      NUMOUTNEGD   = MAX(  NUMOUTNEG,  1 )
      NUMOUTINDD   = MAX(  NUMOUTIND,  1 )
      MXNIRRRXNSD  = MAX(  MXNIRRRXNS, 1 )
      MXTEMPTRMSD  = MAX(  MXTEMPTRMS, 1 )

      WRITE( IOUT, 94540 ) NUMTEMPSD,  NUMOUTPOSD,  NUMOUTNEGD,  NUMOUTINDD, 
     &                     MXNIRRRXNSD,  MXTEMPTRMSD

      IF( NIRRVAR .NE. 0 ) THEN
         WRITE( IOUT, 94542 )
      ELSE 
         WRITE( IOUT, 94544 )
      ENDIF

      WRITE( IOUT, 94580 )
#ifdef nodynalloc
      WRITE( IOUT, 94581 )
#else
      WRITE( IOUT, 94582)
#endif

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Write common blocks
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      WRITE( IOUT, 94000 ) CEES( 1 : 72 )
      WRITE( IOUT, 94700 ) 
      WRITE( IOUT, 94000 ) CEES( 1 : 72 )
      WRITE( IOUT, 94720 ) 
      WRITE( IOUT, 94740 ) 
      WRITE( IOUT, 94760 )
#ifdef nodynalloc
      WRITE( IOUT, 94780 ) 
#else
      WRITE( IOUT, 94781 )
#endif

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Write monocode extensions (declarations and common block) and end
c  line and return
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
#ifdef nodynalloc
      WRITE( IOUT, 94000 ) CEES( 1 : 72 )
      WRITE( IOUT, 94810 ) 
      WRITE( IOUT, 94000 ) CEES( 1 : 72 )
      WRITE( IOUT, 94820 ) 
      IF( LPROC .OR. LIRR ) WRITE( IOUT, 94830 )
#endif 

      LINOUT = DELIM
      LINOUT( 14 : 58 ) = ' End of Process Analysis COMMON Include File '
      WRITE( IOUT, 94000 ) LINOUT
      CLOSE( IOUT )
      RETURN

C*********************** FORMAT STATEMENTS *****************************

94000 FORMAT( A )

94020 FORMAT( 
     & 'c  Integrated Reaction Rates are not being computed.  All',
     &     ' associated'/
     & 'c  arrays will be set to the smallest possible dimension.' )

94040 FORMAT( 
     & 'c  Integrated Process Rates are not being computed.  All',
     &     ' associated'/
     & 'c  arrays will be set to the smallest possible dimension.' )

94060 FORMAT( 
     & 'c  The following variables define the domain for all IPR'
     &/'c  and IRR output variables:' )
94080 FORMAT( 
     & 'c    BEGCOL  = Starting column for output'/
     & 'c    ENDCOL  = Ending column for output'/
     & 'c    BEGROW  = Starting row for output'/
     & 'c    ENDROW  = Ending row for output'/
     & 'c    BEGLEV  = Starting layer for output'/
     & 'c    ENDLEV  = Ending layer for output'/
     & 'c    PACOLS  = Total number of columns for PA output'/
     & 'c    PAROWS  = Total number of rows for PA output'/
     & 'c    PALEVS  = Total number of layers for PA output'/
     & 'c    PACOLSD = Column dimension parameter for PA outputs'/
     & 'c    PAROWSD = Row dimension parameter for PA outputs'/
     & 'c    PALEVSD = Level dimension parameter for PA outputs'/
     & 'c    IRCOLSD = Column dimension parameter for IRR outputs'/
     & 'c    IRROWSD = Column dimension parameter for IRR outputs'/
     & 'c    IRLEVSD = Column dimension parameter for IRR outputs' )

94100 FORMAT( /
     & 6X, 'INTEGER BEGCOL'/
     & 6X, 'PARAMETER ( BEGCOL =', I4, ' )' //
     & 6X, 'INTEGER ENDCOL'/
     & 6X, 'PARAMETER ( ENDCOL =', I4, ' )' //
     & 6X, 'INTEGER BEGROW'/
     & 6X, 'PARAMETER ( BEGROW =', I4, ' )' //
     & 6X, 'INTEGER ENDROW'/
     & 6X, 'PARAMETER ( ENDROW =', I4, ' )' //
     & 6X, 'INTEGER BEGLEV'/
     & 6X, 'PARAMETER ( BEGLEV =', I4, ' )' //
     & 6X, 'INTEGER ENDLEV'/
     & 6X, 'PARAMETER ( ENDLEV =', I4, ' )' //
     & 6X, 'INTEGER PACOLS'/
     & 6X, 'PARAMETER ( PACOLS =', I4, ' )' //
     & 6X, 'INTEGER PAROWS'/
     & 6X, 'PARAMETER ( PAROWS =', I4, ' )' //
     & 6X, 'INTEGER PALEVS'/
     & 6X, 'PARAMETER ( PALEVS =', I4, ' )' /// )

94101 FORMAT( /
     & 6X, 'INTEGER     X1F0' /
     & 6X, 'PARAMETER ( X1F0 =  (NCOLS / GL_NCOLS) * (NROWS / GL_NROWS) )' / )

94102 FORMAT( /
     & 6X, 'INTEGER PACOLSD'/
     & 6X, 'PARAMETER ( PACOLSD = X1F0 * PACOLS + (1 - X1F0) * NCOLS )' //
     & 6X, 'INTEGER PAROWSD'/
     & 6X, 'PARAMETER ( PAROWSD = X1F0 * PAROWS + (1 - X1F0) * NROWS )' //
     & 6X, 'INTEGER PALEVSD'/
     & 6X, 'PARAMETER ( PALEVSD = PALEVS  )' // )

94104 FORMAT( /
     & 6X, 'INTEGER PACOLSD'/
     & 6X, 'PARAMETER ( PACOLSD = 1  )' //
     & 6X, 'INTEGER PAROWSD'/
     & 6X, 'PARAMETER ( PAROWSD = 1  )' //
     & 6X, 'INTEGER PALEVSD'/
     & 6X, 'PARAMETER ( PALEVSD = 1  )' // )

94106 FORMAT( /
     & 6X, 'INTEGER IRCOLSD'/
     & 6X, 'PARAMETER ( IRCOLSD = X1F0 * PACOLS + (1 - X1F0) * NCOLS )' //
     & 6X, 'INTEGER IRROWSD'/
     & 6X, 'PARAMETER ( IRROWSD = X1F0 * PAROWS + (1 - X1F0) * NROWS )' //
     & 6X, 'INTEGER IRLEVSD'/
     & 6X, 'PARAMETER ( IRLEVSD = PALEVS  )' // )

94108 FORMAT( /
     & 6X, 'INTEGER IRCOLSD'/
     & 6X, 'PARAMETER ( IRCOLSD = 1  )' //
     & 6X, 'INTEGER IRROWSD'/
     & 6X, 'PARAMETER ( IRROWSD = 1  )' //
     & 6X, 'INTEGER IRLEVSD'/
     & 6X, 'PARAMETER ( IRLEVSD = 1  )' // )

94120 FORMAT( 
     &'c  The following variables are used in the output file ', 
     &      'descriptions' )
94140 FORMAT( 
     &'c     NIPRVAR   = Number of IPR output variables'/
     &'c     NIRRVAR   = Number of IRR output variables'/
     &'c     NIPRVARD  = Dimension for IPR output variables'/
     &'c     NIRRVARD  = Dimension for IRR output variables'/
     &'c     IPRNAME   = Name of IPR output variable'/
     &'c     IRRNAME   = Name of IRR output variable'/
     &'c     IPRDESC    = Extended name of IPR output variable'/
     &'c     IRRDESC   = Extended name of IRR output variable' )

94160 FORMAT( /
     & 6X, 'INTEGER NIPRVAR'/
     & 6X, 'PARAMETER ( NIPRVAR =', I4, ' )' //
     & 6X, 'INTEGER NIRRVAR'/
     & 6X, 'PARAMETER ( NIRRVAR =', I4, ' )' / )

94180 FORMAT( /
     & 6X, 'INTEGER NIPRVARD'/
     & 6X, 'PARAMETER ( NIPRVARD =', I4, ' )' //
     & 6X, 'INTEGER NIRRVARD'/
     & 6X, 'PARAMETER ( NIRRVARD =', I4, ' )' / )

94200 FORMAT( 
     & 6X, 'CHARACTER*16 IPRNAME( NIPRVARD )' /
     & 6X, 'CHARACTER*60 IPRDESC( NIPRVARD )' /
     & 6X, 'CHARACTER*16 IRRNAME( NIRRVARD )' /
     & 6X, 'CHARACTER*60 IRRDESC( NIRRVARD )' /// )

94260 FORMAT( 
     & 'c  The following variables are used in the integrated process', 
     &     ' rate '/'c  computations.' )

94280 FORMAT( 
     & 'c    NPROCS     = No. of science processes that can be ', 
     &                  ' monitored' /
     & 'c    N_IPR_SPC  = Number of families for IPR' /
     & 'c    NCSAVE     = Number of CTM species concs to save for IPR' /
     & 'c    MXCGRID    = Max number of CTM species in an IPR family' /
     & 'c    N_IPR_SPCD = Dimension for number of families for IPR' /
     & 'c    NCSAVED    = Dimension for NCSAVE' /
     & 'c    MXCGRIDD   = Dimension for MXCGRID' /
     & 'c    NCGRID     = Array of no. of CTM species in an IPR family' /
     & 'c    IPROUT     = Array of IPR output variable indices' /
     & 'c    IPR2GRD    = Array of CTM species indices for IPR',
     &                   ' families' /
     & 'c    IPR2SAV    = Array of saved species indices for IPR',
     &                   ' families' /
     & 'c    SV2GRD     = Array of CTM indicies for saved concs' /
     & 'c    SPCOEF     = Array of coefficients for IPR familys' ) 

94300 FORMAT( /
     & 6X, 'INTEGER NPROCS'/
     & 6X, 'PARAMETER ( NPROCS =', I4, ' )' //
     & 6X, 'INTEGER N_IPR_SPC'/
     & 6X, 'PARAMETER ( N_IPR_SPC =', I4, ' )' //
     & 6X, 'INTEGER NCSAVE'/
     & 6X, 'PARAMETER ( NCSAVE =', I4, ' )' //
     & 6X, 'INTEGER MXCGRID'/
     & 6X, 'PARAMETER ( MXCGRID =', I4, ' )' //
     & 6X, 'INTEGER N_IPR_SPCD'/
     & 6X, 'PARAMETER ( N_IPR_SPCD =', I4, ' )' //
     & 6X, 'INTEGER NCSAVED'/
     & 6X, 'PARAMETER ( NCSAVED =', I4, ' )' //
     & 6X, 'INTEGER MXCGRIDD'/
     & 6X, 'PARAMETER ( MXCGRIDD =', I4, ' )' // )

94320 FORMAT( 
     & 6X, 'CHARACTER*16 PROCNAME(  NPROCS  )' //
     & 6X, 'INTEGER NCGRID( N_IPR_SPCD )' /
     & 6X, 'INTEGER SV2GRD( NCSAVED )' /
     & 6X, 'INTEGER IPROUT( N_IPR_SPCD ,  NPROCS )' /
     & 6X, 'INTEGER IPR2GRD( N_IPR_SPCD ,  MXCGRIDD )' /
     & 6X, 'INTEGER IPR2SAV ( N_IPR_SPCD ,  MXCGRIDD )' //
     & 6X, 'LOGICAL LPROCOUT(  NPROCS  )' //
     & 6X, 'REAL SPCOEF( N_IPR_SPCD ,  MXCGRIDD )' )
94321 FORMAT(
     & 6X, 'REAL DELC( PACOLSD ,  PAROWSD ,  PALEVSD ,  NIPRVARD )' /
     & 6X, 'REAL CSAV( PACOLSD ,  PAROWSD ,  PALEVSD ,  NCSAVED )' /// )
94322 FORMAT( /// )

94360 FORMAT( 
     & 'c  The following variables are used in the integrated reaction', 
     &     ' rate' / 'c  computations.' )

94380 FORMAT( 
     & 'c    LFULLIRR     = Flag for computing IRRs for every reaction' /
     & 'c    LPARTIRR     = Flag for computing IRRs for selected', 
     &                    ' reactions' /
     & 'c    NUMTEMPS     = No. of temporary intermediate IRRs to', 
     &                    ' compute' /
     & 'c    NUMOUTPOS    = No. of temp. IRR terms to add iff the', 
     &                   ' IRR > 0' /
     & 'c    NUMOUTNEG    = No. of temp. IRR terms to add iff the', 
     &                   ' IRR < 0' /
     & 'c    NUMOUTIND    = No. of temp. IRR terms to add regardless', 
     &                   ' of sign' /
     & 'c    MXNIRRRXNS   = Max no. of reaction terms in an output IRR' /
     & 'c    MXTEMPTRMS   = Max no. of reaction terms in a temp. IRR' /
     & 'c    NUMTEMPSD    = Dimension for number of temp IRRs' /
     & 'c    NUMOUTPOSD   = Dimension parameter for NUMOUTPOS' /
     & 'c    NUMOUTNEGD   = Dimension parameter for NUMOUTNEG' /
     & 'c    NUMOUTINDD   = Dimension parameter for NUMOUTIND' /
     & 'c    MXNIRRRXNSD  = Dimension parameter for MXNIRRRXNS' /
     & 'c    MXTEMPTRMSD  = Dimension parameter for MXTEMPTRMS' /
     & 'c    NIRRRXNS     = Vector of no. of reaction terms in an', 
     &                    ' output IRR' /
     & 'c    TEMPTERMS    = Vector of no. of terms in a temporary IRR' /
     & 'c    TEMPOUTPOS   = Vector of no. of IRR terms to add if', 
     &                    ' IRR > 0' /
     & 'c    TEMPOUTNEG   = Vector of no. of IRR terms to add if', 
     &                    ' IRR < 0' /
     & 'c    TEMPOUTIND   = Vector of no. of IRR terms to add', 
     &                    ' regardless of sign' /
     & 'c    INDXOUTPOS   = Vector of indices pointing to IRR output', 
     &                    ' variable' /
     & 'c    INDXOUTNEG   = Vector of indices pointing to IRR output', 
     &                    ' variable' /
     & 'c    INDXOUTIND   = Vector of indices pointing to IRR output', 
     &                    ' variable' /
     & 'c    COEFOUTPOS   = Vector of temp IRR coefficients' /
     & 'c    COEFOUTNEG   = Vector of temp IRR coefficients' /
     & 'c    COEFOUTIND   = Vector of temp IRR coefficients' /
     & 'c    TEMPRXN      = Array of reaction nos. for a temp. IRR' /
     & 'c    IRRRXN       = Array of reaction nos. for an output IRR' /
     & 'c    TEMPCOEF     = Array of reaction coefficients for a', 
     &                    ' temp IRR' /
     & 'c    IRRCOEF      = Array of reaction coefficients for an', 
     &                   ' output IRR' /
     & 'c    IRRSTEP      = Array of output IRRs for one time step' /
     & 'c    IRRBLK       = Array of output IRRs for a block of cells' /
     & 'c    IRROUT       = Array of IRRs to output' ) 

94400 FORMAT( / 6X,  'LOGICAL LFULLIRR' )
94420 FORMAT(   6X,  'PARAMETER ( LFULLIRR = .TRUE. )' )
94440 FORMAT(   6X,  'PARAMETER ( LFULLIRR = .FALSE. )' )  
94460 FORMAT( / 6X,  'LOGICAL LPARTIRR' )
94480 FORMAT(   6X,  'PARAMETER ( LPARTIRR = .TRUE. )' )
94500 FORMAT(   6X,  'PARAMETER ( LPARTIRR = .FALSE. )' ) 

94520 FORMAT( /
     & 6X, 'INTEGER NUMTEMPS' /
     & 6X, 'PARAMETER ( NUMTEMPS =', I4, ' )' //
     & 6X, 'INTEGER NUMOUTPOS' /
     & 6X, 'PARAMETER ( NUMOUTPOS =', I4, ' )' //
     & 6X, 'INTEGER NUMOUTNEG'/
     & 6X, 'PARAMETER ( NUMOUTNEG =', I4, ' )'//
     & 6X, 'INTEGER NUMOUTIND'/
     & 6X, 'PARAMETER ( NUMOUTIND =', I4, ' )'//
     & 6X, 'INTEGER MXNIRRRXNS'/
     & 6X, 'PARAMETER ( MXNIRRRXNS =', I4, ' )'//
     & 6X, 'INTEGER MXTEMPTRMS'/
     & 6X, 'PARAMETER ( MXTEMPTRMS =', I4, ' )' )

94540 FORMAT( /
     & 6X, 'INTEGER NUMTEMPSD'/
     & 6X, 'PARAMETER ( NUMTEMPSD =', I4, ' )'//
     & 6X, 'INTEGER NUMOUTPOSD'/
     & 6X, 'PARAMETER ( NUMOUTPOSD =', I4, ' )'//
     & 6X, 'INTEGER NUMOUTNEGD'/
     & 6X, 'PARAMETER ( NUMOUTNEGD =', I4, ' )'//
     & 6X, 'INTEGER NUMOUTINDD'/
     & 6X, 'PARAMETER ( NUMOUTINDD =', I4, ' )'//
     & 6X, 'INTEGER MXNIRRRXNSD'/
     & 6X, 'PARAMETER ( MXNIRRRXNSD =', I4, ' )'//
     & 6X, 'INTEGER MXTEMPTRMSD'/
     & 6X, 'PARAMETER ( MXTEMPTRMSD =', I4, ' )' )

94542 FORMAT( /
     & 6X, 'INTEGER BLKSIZED'/
     & 6X, 'PARAMETER ( BLKSIZED = BLKSIZE )'// )

94544 FORMAT( /
     & 6X, 'INTEGER BLKSIZED'/
     & 6X, 'PARAMETER ( BLKSIZED = 1 )'// )

94580 FORMAT( /
     & 6X, 'INTEGER NIRRRXNS( NIRRVARD )'/
     & 6X, 'INTEGER TEMPTERMS( NUMTEMPSD )'/
     & 6X, 'INTEGER TEMPOUTPOS( NUMOUTPOSD )'/
     & 6X, 'INTEGER INDXOUTPOS( NUMOUTPOSD )'/
     & 6X, 'INTEGER TEMPOUTNEG( NUMOUTNEGD )'/
     & 6X, 'INTEGER INDXOUTNEG( NUMOUTNEGD )'/
     & 6X, 'INTEGER TEMPOUTIND( NUMOUTINDD )'/
     & 6X, 'INTEGER INDXOUTIND( NUMOUTINDD )'/
     & 6X, 'INTEGER IRRRXN( NIRRVARD,  MXNIRRRXNSD )'/
     & 6X, 'INTEGER TEMPRXN( NUMTEMPSD,  MXTEMPTRMSD )'//
     & 6X, 'REAL COEFOUTPOS( NUMOUTPOSD )'/
     & 6X, 'REAL COEFOUTNEG( NUMOUTNEGD )'/
     & 6X, 'REAL COEFOUTIND( NUMOUTINDD )'/
     & 6X, 'REAL TEMPCOEF( NUMTEMPSD ,  MXTEMPTRMSD )'/
     & 6X, 'REAL IRRCOEF( NIRRVARD ,  MXNIRRRXNSD )'/
     & 6X, 'REAL IRRSTEP( BLKSIZED,  NIRRVARD )'/
     & 6X, 'REAL IRRBLK( BLKSIZED,  NIRRVARD )')
94581 FORMAT(
     & 6X, 'REAL IRROUT(  IRCOLSD ,  IRROWSD ,  IRLEVSD ,  NIRRVARD )'/// )
94582 FORMAT( /// )

94700 FORMAT( 'c  Common Blocks:' )

94720 FORMAT( 
     & 5X, ' COMMON /PACHAR/ IPRNAME, '/
     & 5X, '&                IPRDESC, '/
     & 5X, '&                IRRNAME, '/
     & 5X, '&                IRRDESC, '/
     & 5X, '&                PROCNAME'// )
     
94740 FORMAT( 
     & 5X, ' COMMON /PALGCL/ LPROCOUT'// )

94760 FORMAT( 
     & 5X, ' COMMON /PAINTG/ NCGRID, '/
     & 5X, '&                SV2GRD, '/
     & 5X, '&                IPROUT, '/
     & 5X, '&                IPR2GRD, '/
     & 5X, '&                IPR2SAV , '/ 
     & 5X, '&                NIRRRXNS, '/  
     & 5X, '&                TEMPTERMS, '/  
     & 5X, '&                TEMPOUTPOS, '/ 
     & 5X, '&                TEMPOUTNEG, '/ 
     & 5X, '&                TEMPOUTIND, '/ 
     & 5X, '&                INDXOUTPOS, '/ 
     & 5X, '&                INDXOUTNEG, '/ 
     & 5X, '&                INDXOUTIND, '/ 
     & 5X, '&                TEMPRXN, '/    
     & 5X, '&                IRRRXN'// )     


94780 FORMAT( 
     & 5X, ' COMMON /PAREAL/ SPCOEF, '/
     & 5X, '&                DELC, '/
     & 5X, '&                CSAV, '/
     & 5X, '&                COEFOUTPOS, '/
     & 5X, '&                COEFOUTNEG, '/
     & 5X, '&                COEFOUTIND, '/
     & 5X, '&                TEMPCOEF, '/
     & 5X, '&                IRRCOEF, '/
     & 5X, '&                IRRSTEP, '/
     & 5X, '&                IRRBLK, '/
     & 5X, '&                IRROUT'/// )

94781 FORMAT( 
     & 5X, ' COMMON /PAREAL/ SPCOEF, '/
     & 5X, '&                COEFOUTPOS, '/
     & 5X, '&                COEFOUTNEG, '/
     & 5X, '&                COEFOUTIND, '/
     & 5X, '&                TEMPCOEF, '/
     & 5X, '&                IRRCOEF, '/
     & 5X, '&                IRRSTEP, '/
     & 5X, '&                IRRBLK ' /// )
 
94810 FORMAT( 
     & 'c  The following variables define the PA subdomain in each processor',
     & / 'c  for a parallel CCTM application.' )

94820 FORMAT( 
     & 6X, 'INTEGER MY_BEGROW',
     & 4X, '! Starting row of local PA grid in a processor' /
     & 6X, 'INTEGER MY_ENDROW',
     & 4X, '! Ending row of local PA grid in a processor' /
     & 6X, 'INTEGER MY_BEGCOL',
     & 4X, '! Starting column of local PA grid in a processor' /
     & 6X, 'INTEGER MY_ENDCOL',
     & 4X, '! Ending column of local PA grid in a processor' /
     & 6X, 'INTEGER MY_BEGLEV',
     & 4X, '! Starting level of local PA grid in a processor' /
     & 6X, 'INTEGER MY_ENDLEV',
     & 4X, '! Ending level of local PA grid in a processor' /
     & 6X, 'INTEGER MY_PAROWS',
     & 4X, '! Number of rows of local PA grid a processor has' /
     & 6X, 'INTEGER MY_PACOLS',
     & 4X, '! Number of columns of local PA grid a processor has' /
     & 6X, 'INTEGER MY_IRR_BEGROW',
     & 2X, '! Starting row of local IRR grid in a processor' /
     & 6X, 'INTEGER MY_IRR_ENDROW',
     & 2X, '! Ending row of local IRR grid in a processor' /
     & 6X, 'INTEGER MY_IRR_BEGCOL',
     & 2X, '! Starting column of local IRR grid in a processor' /
     & 6X, 'INTEGER MY_IRR_ENDCOL',
     & 2X, '! Ending column of local IRR grid in a processor' /
     & 6X, 'INTEGER MY_IRR_BEGLEV',
     & 2X, '! Starting level of local IRR grid in a processor' /
     & 6X, 'INTEGER MY_IRR_ENDLEV',
     & 2X, '! Ending level of local IRR grid in a processor' // )

94830 FORMAT( 
     & 5X, ' COMMON / PA_GRID / MY_BEGROW, MY_ENDROW, MY_BEGCOL, MY_ENDCOL,' /
     & 5X, '&                   MY_BEGLEV, MY_ENDLEV, MY_PAROWS, MY_PACOLS,' /
     & 5X, '&                   MY_IRR_BEGROW, MY_IRR_ENDROW, MY_IRR_BEGCOL,' /
     & 5X, '&                   MY_IRR_ENDCOL, MY_IRR_BEGLEV, MY_IRR_ENDLEV'
     &     // )

      END

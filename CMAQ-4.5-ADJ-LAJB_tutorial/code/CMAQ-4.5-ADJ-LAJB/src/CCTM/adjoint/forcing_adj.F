C     Portions of Models-3/CMAQ software were developed or based on
C     information from various groups: Federal Government employees,
C     contractors working on a United States Government contract, and
C     non-Federal sources (including research institutions).  These
C     research institutions have given the Government permission to use,
C     prepare derivative works, and distribute copies of their work in
C     Models-3/CMAQ to the public and to permit others to do so.  EPA
C     therefore grants similar permissions for use of the Models-3/CMAQ
C     software, but users are requested to provide copies of derivative
C     works to the Government without restrictions as to use by others.
C     Users are responsible for acquiring their own copies of commercial
C     software associated with Models-3/CMAQ and for complying with
C     vendor requirements.  Software copyrights by the MCNC
C     Environmental Modeling Center are used with their permissions
C     subject to the above restrictions.

      SUBROUTINE FORCING_ADJ(LGRID, TSTEP, JDATE, JTIME)

C     AUTHOR: Lucas A. J. Bastien
C
C     PURPOSE: calculates the contribution of the forcing term of the
C     adjoint equation.

      USE HGRD_DEFN             ! horizontal domain specifications
      USE VGRD_DEFN             ! vertical domain specifications
      USE ADJPRM                ! Adjoint parameters

      IMPLICIT NONE

C     Include files

      INCLUDE SUBST_IOPARMS     ! I/O parameters
      INCLUDE SUBST_IOFDESC     ! File description
      INCLUDE SUBST_IODECL      ! I/O definitions and declarations
      INCLUDE SUBST_FILES_ID    ! Files logical names

C     Dummy variables

      REAL, POINTER :: LGRID( :,:,:,: )   ! Adjoint variable
      INTEGER, INTENT(IN) :: TSTEP(2)     ! Model time steps
      INTEGER, INTENT(IN) :: JDATE, JTIME ! Date and time

C     Local variables

      LOGICAL, SAVE :: FIRSTIME = .TRUE.
      CHARACTER( 16 ) :: PNAME = 'FORCING_ADJ'
      INTEGER :: LOGDEV
      CHARACTER( 80 ) :: MSG
      INTEGER, SAVE :: ISPC  ! Index of species in CGRID
      INTEGER :: C, R        ! Iterate over columns and rows
      REAL, SAVE :: DTSEC    ! Time step in seconds
      REAL :: RECEPTOR(MY_NCOLS, MY_NROWS)

C     External function(s)

      INTEGER, EXTERNAL :: INDEX1   ! Find index of species in list
      INTEGER, EXTERNAL :: TIME2SEC ! Transform times into seconds

C     ------------------------------------------------------------------

      IF (FIRSTIME) THEN

         FIRSTIME = .FALSE.
         LOGDEV = INIT3 ()

C     Open the receptor file and get its description

         IF ( .NOT. OPEN3( FIL_REC, FSREAD3, PNAME ) ) THEN
            MSG = "Could not open " // FIL_REC // " file for reading"
            CALL M3EXIT ( PNAME, JDATE, JTIME, MSG, XSTAT1 )
         END IF

         IF ( .NOT. DESC3( FIL_REC) ) THEN
            MSG = "Could not get "// FIL_REC // " file description"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT1 )
         END IF

C     3D receptors are not supported yet

         IF ( NLAYS3D .NE. 1 ) THEN
            MSG = "3D receptors are not supported yet"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         END IF

C     TODO: check in CCTM/vdiff/eddy/vdiffim.F: the part where it goes
C     as: IF (GDTYP_GD .EQ. LATGRD3 ) THEN DX1 = DG2M * XCELL_GD and DX2
C     = DG2M * YCELL_GD. I am assuming that I need something similar
C     here but I am not sure. Right now, the program stops if
C     encoutering that case.

         IF ( GDTYP_GD .EQ. LATGRD3 ) THEN
            MSG = "GDTYP_GD .EQ. LATGRD3 NOT YET IMPLEMENTED "
     &             // "(SEE SOURCE CODE)"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         END IF

C     CGRID is read and written from/to CHK, therefore get the list of
C     species by getting the description of that file. Bad method. TODO:
C     find the correct map instead.

         IF ( .NOT. DESC3(CONC_CHK) ) THEN
            MSG = "Could not get "// CONC_CHK // " file description"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT1 )
         END IF

C     Get the index of the species in the list

         ISPC = INDEX1( TRIM(REC_SPECIES), NVARS3D, VNAME3D )
         IF ( ISPC .EQ. 0 ) THEN
            MSG = "Could not find index for species " // TRIM(REC_SPECIES)
     &           // " in " // CONC_CHK
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         END IF

C     The time step is the synchronization time step

         DTSEC = FLOAT(TIME2SEC(TSTEP(2)))

      END IF ! FIRSTIME

      CALL RD_RECEPTOR(RECEPTOR, JDATE, JTIME)

      DO C = 1, MY_NCOLS
         DO R = 1, MY_NROWS
            LGRID(C,R,1,ISPC) = LGRID(C,R,1,ISPC) + RECEPTOR(C,R)*DTSEC
         END DO
      END DO

      RETURN

      END SUBROUTINE FORCING_ADJ

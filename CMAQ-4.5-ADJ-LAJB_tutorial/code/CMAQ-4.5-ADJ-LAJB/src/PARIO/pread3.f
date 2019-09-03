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
C
C     Author: Lucas A. J. Bastien (strongly inspired by PARIO/pwrite3.f,
C     with some code directly copied from it)
C
      LOGICAL FUNCTION PREAD3(FNAME, VNAME, LAYER, JDATE, JTIME,
     &                        BUFFER)

C.....................................................................
C
C  PURPOSE: Perform Models-3 file-read operation in a parallel
C           environment.
C
C  ARGUMENTS:
C   * FNAME: Logical name of file to read.
C   * VNAME: Name of variable to read.
C   * LAYER: Layer(s) to read (single layer or ALLAYS3 for all layers.
C   * JDATE: Date to read (YYYYDDD)
C   * JTIME: Time to read (HHMMSS)
C   * BUFFER: Buffer to store the data being read.
C
C  RETURN VALUE: .TRUE. if everything goes as expected, .FALSE. otherwise.
C
C-----------------------------------------------------------------------

C     Modules

      USE PIOMAPS_MODULE

      IMPLICIT NONE

C     Include files

      INCLUDE "PARMS3.EXT"  ! I/O parameters definitions
      INCLUDE "FDESC3.EXT"  ! File header data structure
      INCLUDE "STATE3.EXT"  ! I/O system state
      INCLUDE "IODECL3.EXT" ! I/O definitions and declarations
      INCLUDE "PIOGRID.EXT" ! Grid dimensions and decomposition
      INCLUDE 'mpif.h'      ! MPI definitions and parameters

C     Dummy arguments

      CHARACTER(LEN=*), INTENT(IN) :: FNAME, VNAME
      INTEGER, INTENT(IN) :: LAYER, JDATE, JTIME
      REAL, INTENT(INOUT) :: BUFFER(*)

C     External functions

      INTEGER, EXTERNAL :: INDEX1, JSTEP3
      LOGICAL, EXTERNAL :: PRDGRDD

C     Local variables

      CHARACTER(LEN=16) :: PNAME = "PREAD3", FIL16, VAR16, VNAM16
      CHARACTER(LEN=96) :: MSG
      CHARACTER(LEN=16), SAVE :: PREVFILE = ""
      LOGICAL :: FLCHANGE, LERROR, RERROR
      INTEGER :: FID, STEP, NVARS, IV, ERROR

C     ------------------------------------------------------------------

      PREAD3 = .FALSE.

      WRITE(LOGDEV, '(A)') ""
      WRITE(LOGDEV, '(5X, A)') "** PREAD3:"
      WRITE(LOGDEV, '(5X, A)') "File: " // TRIM(FNAME) // ";"
      WRITE(LOGDEV, '(5X, A, I7, A, I6, A)') "Timestep ", JDATE, ", ",
     &     JTIME, ";"
      WRITE(LOGDEV, '(5X, A)') "Variable(s): " // TRIM(VNAME) // ";"
      IF (LAYER .EQ. ALLAYS3) THEN
         WRITE(LOGDEV, '(5X, A)') "Layer(s): ALL;"
      ELSE
         WRITE(LOGDEV, '(5X,A, I3, A)') "Layer(s): ", LAYER, ";"
      END IF
      CALL FLUSH()

C     Input data validity

      IF (LEN(FNAME) .GT. 16) THEN
         MSG = "File logical name (" // FNAME // ") too long (>16)"
         CALL PM3WARN(PNAME, JDATE, JTIME, MSG)
         RETURN
      END IF

      IF (LEN(VNAME) .GT. 16) THEN
         MSG = "Variable name (" // VNAME // ") too long (>16)"
         CALL PM3WARN(PNAME, JDATE, JTIME, MSG)
         RETURN
      END IF

      FIL16 = FNAME ! Fixed-length-16 scratch copy of FNAME
      VAR16 = VNAME ! Fixed-length-16 scratch copy of VNAME

C     Check whether we are looking at the same file as the last time
C     this routine was called

      FID = INDEX1(FIL16, COUNT3, FLIST3)

      IF (PREVFILE .EQ. "") THEN
         FLCHANGE = .TRUE.
         PREVFILE = FIL16
      ELSE IF (FIL16 .EQ. PREVFILE) THEN
         FLCHANGE = .FALSE.
      ELSE
         FLCHANGE = .TRUE.
         PREVFILE = FIL16
      END IF

C     Get the index of the time step in the input file and do quality
C     checking

      STEP = JSTEP3(JDATE, JTIME, SDATE3(FID), STIME3(FID),
     &     ABS(TSTEP3(FID)))
      IF (STEP .LT. 0) THEN
         MSG = "Time step not on file" // FIL16
         CALL PM3WARN(PNAME, JDATE, JTIME, MSG)
         RETURN
      END IF

C     Get header information for input file

      IF (.NOT. DESC3(FIL16)) THEN
         MSG = "Could not get " // FIL16 // " file description"
         CALL PM3WARN(PNAME, JDATE, JTIME, MSG)
         RETURN
      END IF

C     This subroutine is designed for gridded files only

      IF (FTYPE3D .NE. GRDDED3) THEN
         MSG = FIL16 // " is not a gridded file"
         CALL PM3WARN(PNAME, JDATE, JTIME, MSG)
         RETURN
      END IF

C     Get processor-domain map

      IF (FLCHANGE) THEN
         CALL GET_READ_MAP(NUMPROCS, NPROWD, NPCOLD, GNROWS, GNCOLS,
     &                     NROWS3D, NCOLS3D, NLAYS3D, NROWS_PE,
     &                     NCOLS_PE, ROWSX_PE, COLSX_PE, RD_NROWS_PE,
     &                     RD_NCOLS_PE, RD_ROWSX_PE, RD_COLSX_PE)
      END IF

C     Process each variable

      IF (VAR16 .EQ. ALLVAR3) THEN
         NVARS = NVARS3D
      ELSE
         NVARS = 1
      END IF

      DO IV = 1, NVARS

         IF (VAR16 .EQ. ALLVAR3) THEN
            VNAM16 = VNAME3D(IV)
         ELSE
            VNAM16 = VAR16
         END IF

         LERROR= (.NOT. PRDGRDD(FIL16, VAR16, JDATE, JTIME,
     &                          NCOLS3D, NROWS3D, NLAYS3D,
     &                          LAYER, BUFFER))

C     Check whether all processes succeeded

         CALL MPI_ALLREDUCE(LERROR, RERROR, 1, MPI_LOGICAL, MPI_LAND,
     &                      MPI_COMM_WORLD, ERROR)

         IF (ERROR .NE. MPI_SUCCESS) THEN
            MSG = "Error in call to MPI_ALLREDUCE."
            CALL PM3WARN(PNAME, JDATE, JTIME, MSG)
            RETURN
         END IF

         IF (RERROR) THEN
            MSG = "Error during call to PRDGRDD."
            CALL PM3WARN(PNAME, JDATE, JTIME, MSG)
            RETURN
         END IF

      END DO

C     If we got here, everything went well

      WRITE(LOGDEV, '(5X, A)') "** Succesful."
      WRITE(LOGDEV, '(A)') ""
      CALL FLUSH()

      PREAD3 = .TRUE.
      RETURN

      END FUNCTION PREAD3

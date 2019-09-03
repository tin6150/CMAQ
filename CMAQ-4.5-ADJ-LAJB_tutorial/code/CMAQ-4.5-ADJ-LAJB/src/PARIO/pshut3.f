
C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/PARIO/src/pshut3.f,v 1.1.1.1 2005/09/09 16:18:17 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

        LOGICAL FUNCTION  PSHUT3 ( )

C***********************************************************************
C  FUNCTION:  Flushes and closes down all Models-3 files currently open by
C             PE 0 only.
C
C  RETURN VALUE:  TRUE iff it succeeds.
C
C  PRECONDITIONS:  none
C
C  SUBROUTINES AND FUNCTIONS CALLED:
C
C  REVISION  HISTORY:  
C       prototype 09/02 by David Wong
C***********************************************************************

      IMPLICIT NONE

C...........   INCLUDES:

        INCLUDE 'PARMS3.EXT'
        INCLUDE 'STATE3.EXT'
        INCLUDE 'NETCDF.EXT'
        INCLUDE 'PIOVARS.EXT'
	INCLUDE "mpif.h"

C...........   SCRATCH LOCAL VARIABLES and their descriptions:

        INTEGER         FILE            !  loop counter over files
        INTEGER         V               !  loop counter over vbles
        INTEGER         IERR            !  netCDF error status return
        INTEGER         ERROR           !  MPI error status return

C***********************************************************************
C   begin body of function  PSHUT3

        PSHUT3 = .TRUE.
        IF (.NOT. FINIT3) THEN
            RETURN
        END IF

        DO FILE = 1, COUNT3

           IF ((CDFID3(FILE) .GE. 0) .AND. (FLIST3(FILE) .NE. CMISS3)) THEN

              IF (MY_PE .EQ. 0) THEN
                 CALL NCCLOS( CDFID3( FILE ), IERR )
                 IF (IERR .NE. 0) THEN
                    WRITE (LOGDEV,91010)
     &                     'Error closing netCDF file ',
     &                     'File name:  ' // FLIST3( FILE ) ,
     &                     'netCDF error number', IERR
                    PSHUT3 = .FALSE.
                 END IF
              END IF
           END IF

           CALL BUFDEL3 (FILE)
           FLIST3(FILE) = CMISS3
           DO V = 1, NVARS3( FILE )
              ILAST3(V,FILE) = IMISS3
              LDATE3(V,FILE) = IMISS3
              LTIME3(V,FILE) = IMISS3
              NDATE3(V,FILE) = IMISS3
              NTIME3(V,FILE) = IMISS3
           END DO

        END DO      !  end loop on files

        COUNT3 = IMISS3
        FINIT3 = .FALSE.

        CALL MPI_BCAST (PSHUT3, 1, MPI_LOGICAL, 0 ,MPI_COMM_WORLD, ERROR)

        RETURN

C******************  FORMAT  STATEMENTS   ******************************

C...........   Error and warning message formats..... 91xxx

91010   FORMAT ( //5X , '>>> WARNING in subroutine SHUT3 <<<',
     &            3 ( /5X , A , : ) , I5, // )

        END FUNCTION PSHUT3

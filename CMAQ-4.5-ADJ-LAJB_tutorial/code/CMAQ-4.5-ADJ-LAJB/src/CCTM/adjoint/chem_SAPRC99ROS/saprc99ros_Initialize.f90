! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! Initialization File
! 
! Generated by KPP-2.2.3 symbolic chemistry Kinetics PreProcessor
!       (http://www.cs.vt.edu/~asandu/Software/KPP)
! KPP is distributed under GPL, the general public licence
!       (http://www.gnu.org/copyleft/gpl.html)
! (C) 1995-1997, V. Damian & A. Sandu, CGRER, Univ. Iowa
! (C) 1997-2005, A. Sandu, Michigan Tech, Virginia Tech
!     With important contributions from:
!        M. Damian, Villanova University, USA
!        R. Sander, Max-Planck Institute for Chemistry, Mainz, Germany
! 
! File                 : saprc99ros_Initialize.f90
! Time                 : Mon Feb  9 17:20:52 2015
! Working directory    : /gpanda/lbastien/synced/work/sensitivity/baa/run-KPP/saprc99ros
! Equation file        : saprc99ros.kpp
! Output root filename : saprc99ros
! 
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



MODULE saprc99ros_Initialize

  USE saprc99ros_Parameters, ONLY: dp, NVAR, NFIX
  IMPLICIT NONE

CONTAINS


! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! Initialize - function to initialize concentrations
!   Arguments :
! 
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SUBROUTINE Initialize ( )


  USE saprc99ros_Global

  INTEGER :: i
  REAL(kind=dp) :: x

  CFACTOR = 2.447600e+13_dp

  x = (0.0e0)*CFACTOR
  DO i = 1, NVAR
    VAR(i) = x
  END DO

  x = (0.0e0)*CFACTOR
  DO i = 1, NFIX
    FIX(i) = x
  END DO

  VAR(2) = (6.77e-4)*CFACTOR
  VAR(3) = (1.16e-3)*CFACTOR
  VAR(4) = (3.92e-4)*CFACTOR
  VAR(8) = (0.2E0)*CFACTOR
  VAR(9) = (5.e-2)*CFACTOR
  VAR(11) = (1.167e-2)*CFACTOR
  VAR(19) = (1.e-3)*CFACTOR
  VAR(20) = (1.88e-2)*CFACTOR
  VAR(21) = (4.69e-2)*CFACTOR
  VAR(23) = (3.06e-2)*CFACTOR
  VAR(24) = (8.74e-3)*CFACTOR
  VAR(29) = (5.89e-3)*CFACTOR
  VAR(30) = (4.17e-2)*CFACTOR
  VAR(31) = (1.18e-2)*CFACTOR
  VAR(34) = (5.60e-4)*CFACTOR
  VAR(38) = (7.51e-5)*CFACTOR
  VAR(39) = (6.06e-4)*CFACTOR
  VAR(41) = (8.37e-5)*CFACTOR
  VAR(42) = (5.07e-3)*CFACTOR
  VAR(44) = (1.89e-2)*CFACTOR
  VAR(45) = (1.21e-4)*CFACTOR
  VAR(47) = (4.33e-4)*CFACTOR
  VAR(49) = (8.20e-4)*CFACTOR
  VAR(50) = (1.30e-3)*CFACTOR
  VAR(51) = (1.04e-2)*CFACTOR
  VAR(52) = (8.93e-5)*CFACTOR
  VAR(53) = (7.97e-3)*CFACTOR
  VAR(55) = (2.316e-3)*CFACTOR
  VAR(56) = (1.121e-2)*CFACTOR
  VAR(58) = (7.843e-9)*CFACTOR
  VAR(59) = (1.72e-3)*CFACTOR
  VAR(60) = (3.26e-3)*CFACTOR
  VAR(61) = (1.93e-3)*CFACTOR
  VAR(69) = (1.0e-1)*CFACTOR
  VAR(70) = (5.0e-2)*CFACTOR
  FIX(1) = (1.0e+6)*CFACTOR
  FIX(2) = (2.09e+5)*CFACTOR
  FIX(3) = (2.0e+04)*CFACTOR
  FIX(5) = (1.0e0)*CFACTOR
! constant rate coefficients
  RCONST(150) = 1.5e-11
! END constant rate coefficients

! INLINED initializations

        TSTART = 12.0d0*3600.0d0
        TEND   = TSTART + 120.0d0*3600.0d0
        DT     = 3600.d0
        TEMP   = 300.0d0

! End INLINED initializations

      
END SUBROUTINE Initialize

! End of Initialize function
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



END MODULE saprc99ros_Initialize


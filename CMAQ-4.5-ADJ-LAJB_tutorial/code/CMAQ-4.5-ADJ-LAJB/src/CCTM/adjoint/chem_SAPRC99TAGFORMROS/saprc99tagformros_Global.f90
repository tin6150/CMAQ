! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! Global Data Module File
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
! File                 : saprc99tagformros_Global.f90
! Time                 : Sat Sep 23 17:16:32 2017
! Working directory    : /gpanda/lbastien/synced/work/sensitivity/baa/run-KPP/saprc99tagformros
! Equation file        : saprc99tagformros.kpp
! Output root filename : saprc99tagformros
! 
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



MODULE saprc99tagformros_Global

  USE saprc99tagformros_Parameters, ONLY: dp, NSPEC, NVAR, NFIX, NREACTKPP
  PUBLIC
  SAVE


! Declaration of global variables

! C - Concentration of all species
  REAL(kind=dp) :: C(NSPEC)
! VAR - Concentrations of variable species (global)
  REAL(kind=dp) :: VAR(NVAR)
! FIX - Concentrations of fixed species (global)
  REAL(kind=dp) :: FIX(NFIX)
! VAR, FIX are chunks of array C
      EQUIVALENCE( C(1),VAR(1) )
      EQUIVALENCE( C(77),FIX(1) )
! RCONST - Rate constants (global)
  REAL(kind=dp) :: RCONST(NREACTKPP)
! TIME - Current integration time
  REAL(kind=dp) :: TIME
! SUN - Sunlight intensity between [0,1]
  REAL(kind=dp) :: SUN
! TEMP - Temperature
  REAL(kind=dp) :: TEMP
! RTOLS - (scalar) Relative tolerance
  REAL(kind=dp) :: RTOLS
! TSTART - Integration start time
  REAL(kind=dp) :: TSTART
! TEND - Integration end time
  REAL(kind=dp) :: TEND
! DT - Integration step
  REAL(kind=dp) :: DT
! ATOL - Absolute tolerance
  REAL(kind=dp) :: ATOL(NVAR)
! RTOL - Relative tolerance
  REAL(kind=dp) :: RTOL(NVAR)
! STEPMIN - Lower bound for integration step
  REAL(kind=dp) :: STEPMIN
! STEPMAX - Upper bound for integration step
  REAL(kind=dp) :: STEPMAX
! CFACTOR - Conversion factor for concentration units
  REAL(kind=dp) :: CFACTOR
! DDMTYPE - DDM sensitivity w.r.t.: 0=init.val., 1=params
  INTEGER :: DDMTYPE

! INLINED global variable declarations

! INLINED global variable declarations


END MODULE saprc99tagformros_Global


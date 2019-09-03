! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! Sparse Jacobian Data Structures File
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
! File                 : saprc99tagformros_JacobianSP.f90
! Time                 : Sat Sep 23 17:16:32 2017
! Working directory    : /gpanda/lbastien/synced/work/sensitivity/baa/run-KPP/saprc99tagformros
! Equation file        : saprc99tagformros.kpp
! Output root filename : saprc99tagformros
! 
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



MODULE saprc99tagformros_JacobianSP

  PUBLIC
  SAVE


! Sparse Jacobian Data


  INTEGER, PARAMETER, DIMENSION(360) :: LU_IROW_0 = (/ &
       1,  1,  1,  2,  2,  2,  2,  2,  2,  2,  2,  2, &
       2,  2,  2,  2,  2,  3,  3,  3,  3,  3,  3,  3, &
       3,  3,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4, &
       4,  4,  4,  4,  5,  5,  5,  6,  6,  6,  6,  6, &
       7,  7,  7,  8,  8,  8,  8,  9,  9, 10, 10, 11, &
      11, 12, 12, 12, 12, 12, 13, 13, 13, 14, 14, 14, &
      15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, &
      19, 19, 19, 20, 20, 21, 21, 22, 22, 22, 22, 23, &
      23, 24, 24, 25, 25, 25, 25, 26, 26, 26, 26, 27, &
      27, 27, 27, 27, 28, 28, 28, 28, 28, 29, 29, 30, &
      30, 31, 31, 31, 31, 32, 32, 32, 32, 33, 33, 33, &
      33, 33, 34, 34, 34, 34, 34, 35, 35, 35, 35, 35, &
      35, 35, 36, 36, 36, 36, 36, 36, 37, 37, 37, 37, &
      37, 38, 38, 38, 38, 39, 39, 39, 39, 40, 40, 40, &
      40, 40, 40, 40, 40, 41, 41, 41, 41, 41, 41, 42, &
      42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 43, &
      43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, &
      43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, &
      43, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, &
      44, 44, 44, 45, 45, 45, 45, 45, 45, 45, 45, 45, &
      45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, &
      45, 45, 46, 46, 46, 46, 46, 47, 47, 47, 47, 47, &
      47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, &
      48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, &
      49, 49, 49, 49, 49, 50, 50, 50, 50, 50, 50, 50, &
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, &
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 51, 51, &
      51, 51, 51, 52, 52, 52, 52, 52, 52, 52, 53, 53, &
      53, 53, 53, 54, 54, 54, 54, 54, 54, 54, 55, 55, &
      55, 55, 55, 55, 55, 55, 55, 55, 55, 55, 55, 55 /)
  INTEGER, PARAMETER, DIMENSION(360) :: LU_IROW_1 = (/ &
      55, 55, 55, 55, 55, 55, 55, 55, 56, 56, 56, 56, &
      56, 57, 57, 57, 57, 57, 57, 57, 58, 58, 58, 58, &
      58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, &
      58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, &
      58, 58, 58, 58, 58, 58, 58, 58, 59, 59, 59, 59, &
      59, 59, 59, 59, 59, 59, 59, 59, 59, 60, 60, 60, &
      60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 61, &
      61, 61, 61, 61, 61, 61, 61, 61, 61, 61, 61, 61, &
      61, 61, 61, 61, 61, 61, 61, 61, 61, 61, 61, 61, &
      61, 61, 61, 62, 62, 62, 62, 62, 62, 62, 62, 62, &
      62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 63, &
      63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, &
      63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 64, 64, &
      64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, &
      64, 64, 64, 64, 64, 64, 65, 65, 65, 65, 65, 65, &
      65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, &
      65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, &
      66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, &
      66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, &
      66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, &
      66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, &
      66, 66, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, &
      67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 68, 68, &
      68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, &
      68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, &
      68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, &
      68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, &
      68, 68, 68, 68, 68, 68, 68, 69, 69, 69, 69, 69, &
      69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, &
      70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70 /)
  INTEGER, PARAMETER, DIMENSION(223) :: LU_IROW_2 = (/ &
      70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, &
      70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, &
      70, 70, 70, 70, 71, 71, 71, 71, 71, 71, 71, 71, &
      71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, &
      71, 71, 71, 71, 71, 72, 72, 72, 72, 72, 72, 72, &
      72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, &
      72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, &
      72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 73, &
      73, 73, 73, 73, 73, 73, 73, 73, 73, 73, 73, 73, &
      73, 73, 73, 73, 73, 73, 73, 73, 73, 73, 73, 73, &
      73, 73, 73, 73, 73, 73, 73, 73, 73, 73, 73, 73, &
      73, 73, 73, 73, 74, 74, 74, 74, 74, 74, 74, 74, &
      74, 74, 74, 74, 74, 74, 74, 74, 74, 74, 74, 74, &
      74, 74, 74, 74, 74, 75, 75, 75, 75, 75, 75, 75, &
      75, 75, 75, 75, 75, 75, 75, 75, 75, 75, 75, 75, &
      75, 75, 75, 75, 75, 75, 75, 75, 75, 75, 75, 75, &
      75, 75, 76, 76, 76, 76, 76, 76, 76, 76, 76, 76, &
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76, 76, 76, &
      76, 76, 76, 76, 76, 76, 76 /)
  INTEGER, PARAMETER, DIMENSION(943) :: LU_IROW = (/&
    LU_IROW_0, LU_IROW_1, LU_IROW_2 /)

  INTEGER, PARAMETER, DIMENSION(360) :: LU_ICOL_0 = (/ &
       1,  9, 68,  2, 20, 40, 46, 49, 51, 52, 53, 54, &
      56, 57, 64, 68, 71,  3, 53, 56, 64, 65, 66, 70, &
      75, 76,  4, 49, 51, 53, 54, 56, 64, 65, 66, 67, &
      69, 70, 74, 76,  5, 66, 75,  6, 66, 67, 69, 74, &
       7, 27, 72,  8, 27, 35, 72,  9, 68, 10, 64, 11, &
      68, 12, 24, 49, 64, 68, 13, 72, 75, 14, 72, 74, &
      15, 69, 72, 16, 67, 72, 17, 66, 68, 18, 72, 73, &
      19, 68, 71, 20, 68, 21, 68, 21, 22, 68, 72, 23, &
      68, 24, 68, 25, 66, 68, 72, 26, 66, 68, 76, 27, &
      36, 66, 72, 73, 28, 65, 68, 70, 76, 29, 68, 30, &
      68, 24, 30, 31, 68, 24, 30, 32, 68, 24, 30, 33, &
      68, 73, 24, 30, 34, 64, 68, 24, 30, 35, 56, 64, &
      68, 73, 27, 36, 48, 66, 72, 73, 37, 65, 66, 68, &
      70, 38, 66, 68, 73, 39, 66, 68, 73, 38, 39, 40, &
      58, 66, 68, 71, 73, 30, 41, 48, 66, 68, 73, 24, &
      30, 31, 32, 33, 42, 52, 54, 57, 64, 68, 73, 20, &
      29, 31, 32, 34, 38, 39, 42, 43, 46, 47, 49, 51, &
      52, 53, 54, 55, 56, 57, 58, 60, 61, 64, 66, 68, &
      73, 20, 21, 22, 23, 29, 44, 49, 53, 56, 59, 64, &
      68, 72, 73, 18, 33, 35, 36, 38, 39, 41, 42, 45, &
      47, 48, 52, 54, 55, 56, 57, 58, 61, 64, 66, 68, &
      72, 73, 46, 60, 64, 68, 73, 20, 24, 30, 31, 32, &
      34, 41, 46, 47, 48, 49, 54, 60, 64, 66, 68, 73, &
      33, 41, 48, 66, 67, 68, 69, 71, 72, 73, 74, 75, &
      49, 60, 64, 68, 73, 21, 23, 29, 31, 32, 44, 49, &
      50, 51, 53, 56, 57, 59, 60, 62, 63, 64, 65, 66, &
      67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 51, 60, &
      64, 68, 73, 51, 52, 56, 60, 64, 68, 73, 53, 60, &
      64, 68, 73, 51, 54, 56, 60, 64, 68, 73, 11, 21, &
      23, 29, 46, 53, 54, 55, 56, 59, 60, 61, 62, 63 /)
  INTEGER, PARAMETER, DIMENSION(360) :: LU_ICOL_1 = (/ &
      64, 67, 68, 69, 71, 73, 74, 75, 56, 60, 64, 68, &
      73, 51, 56, 57, 60, 64, 68, 73, 20, 21, 23, 26, &
      28, 29, 40, 44, 46, 47, 48, 49, 51, 52, 53, 54, &
      56, 57, 58, 59, 60, 62, 63, 64, 65, 66, 67, 68, &
      69, 70, 71, 72, 73, 74, 75, 76, 22, 49, 53, 54, &
      56, 59, 60, 64, 65, 68, 71, 72, 73, 10, 46, 49, &
      51, 52, 53, 56, 57, 60, 64, 68, 71, 72, 73, 20, &
      21, 23, 29, 31, 32, 34, 37, 46, 49, 52, 53, 54, &
      56, 57, 59, 60, 61, 62, 63, 64, 65, 66, 68, 70, &
      71, 72, 73, 21, 23, 29, 52, 53, 54, 56, 57, 59, &
      60, 62, 63, 64, 65, 68, 70, 71, 72, 73, 76, 23, &
      29, 30, 49, 51, 53, 54, 56, 57, 59, 60, 63, 64, &
      65, 68, 69, 70, 71, 72, 73, 74, 75, 76, 34, 46, &
      49, 51, 52, 53, 54, 56, 57, 60, 64, 66, 67, 68, &
      69, 71, 72, 73, 74, 75, 20, 21, 23, 24, 29, 30, &
      49, 51, 53, 54, 56, 57, 59, 60, 61, 62, 63, 64, &
      65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, &
       9, 17, 19, 20, 24, 25, 26, 27, 28, 30, 31, 32, &
      34, 36, 37, 38, 39, 40, 42, 43, 46, 47, 48, 49, &
      51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, &
      63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, &
      75, 76, 16, 51, 52, 54, 56, 57, 60, 64, 65, 66, &
      67, 68, 69, 70, 71, 72, 73, 74, 75, 76,  9, 10, &
      11, 17, 19, 20, 21, 23, 24, 25, 26, 28, 29, 30, &
      31, 32, 33, 34, 35, 37, 38, 39, 41, 42, 43, 44, &
      45, 46, 47, 48, 49, 51, 52, 53, 54, 55, 56, 57, &
      58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, &
      70, 71, 72, 73, 74, 75, 76, 15, 35, 56, 60, 64, &
      65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, &
      11, 20, 21, 23, 24, 29, 30, 31, 32, 33, 34, 37 /)
  INTEGER, PARAMETER, DIMENSION(223) :: LU_ICOL_2 = (/ &
      41, 46, 48, 49, 51, 52, 53, 54, 56, 57, 59, 60, &
      61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, &
      73, 74, 75, 76, 19, 40, 50, 51, 53, 56, 57, 58, &
      59, 60, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, &
      72, 73, 74, 75, 76, 13, 14, 15, 16, 18, 19, 22, &
      25, 27, 36, 40, 45, 47, 48, 49, 50, 51, 52, 53, &
      54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, &
      66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 18, &
      25, 33, 35, 36, 38, 39, 41, 42, 45, 46, 47, 48, &
      49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, &
      61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, &
      73, 74, 75, 76, 14, 47, 48, 49, 52, 54, 56, 57, &
      60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, &
      72, 73, 74, 75, 76, 12, 13, 24, 29, 31, 32, 42, &
      44, 49, 52, 53, 54, 55, 56, 57, 59, 60, 61, 62, &
      63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, &
      75, 76, 22, 26, 29, 44, 46, 49, 51, 53, 55, 56, &
      57, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, &
      70, 71, 72, 73, 74, 75, 76 /)
  INTEGER, PARAMETER, DIMENSION(943) :: LU_ICOL = (/&
    LU_ICOL_0, LU_ICOL_1, LU_ICOL_2 /)

  INTEGER, PARAMETER, DIMENSION(77) :: LU_CROW = (/ &
       1,  4, 18, 27, 41, 44, 49, 52, 56, 58, 60, 62, &
      67, 70, 73, 76, 79, 82, 85, 88, 90, 92, 96, 98, &
     100,104,108,113,118,120,122,126,130,135,140,147, &
     153,158,162,166,174,180,192,218,232,255,260,277, &
     289,294,323,328,335,340,347,369,374,381,417,430, &
     444,472,492,515,535,565,615,635,692,709,749,774, &
     816,857,882,915,944 /)

  INTEGER, PARAMETER, DIMENSION(77) :: LU_DIAG = (/ &
       1,  4, 18, 27, 41, 44, 49, 52, 56, 58, 60, 62, &
      67, 70, 73, 76, 79, 82, 85, 88, 90, 93, 96, 98, &
     100,104,108,113,118,120,124,128,132,137,142,148, &
     153,158,162,168,175,185,200,223,240,255,268,279, &
     289,301,323,329,335,341,354,369,376,399,422,438, &
     461,482,503,525,553,604,625,683,701,742,768,811, &
     853,879,913,943,944 /)


END MODULE saprc99tagformros_JacobianSP


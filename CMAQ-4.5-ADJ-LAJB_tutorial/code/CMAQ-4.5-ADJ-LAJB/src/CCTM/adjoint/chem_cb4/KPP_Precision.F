  

      MODULE KPP_PRECISION

C     
C     Definition of different levels of accuracy
C     for REAL variables using KIND parameterization
C     
C     KPP SP - Single precision kind
      INTEGER, PARAMETER :: sp = SELECTED_REAL_KIND(6,30)
C     KPP DP - Double precision kind
      INTEGER, PARAMETER :: dp = SELECTED_REAL_KIND(14,300)
C     KPP QP - Quadruple precision kind
      INTEGER, PARAMETER :: qp = SELECTED_REAL_KIND(18,400)

      END MODULE KPP_PRECISION



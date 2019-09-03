C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/STENEX/src/se_snl/se_global_sum_module.f,v 1.1.1.1 2005/09/09 18:58:42 sjr Exp $

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

C --------------------------------------------------------------------------
C Purpose:
C
C   use F90 interface feature to achieve "faked" polymorphism for global sum
C   routine
C
C Revision history:
C
C   Orginal version: 11/05/99 by David Wong
C
C Parameter List:
C
C   In: var -- sum variable
C
C Local Variable:
C
C   sum         -- local variable for computing global sum
C   error       -- error code for mpi call
C
C Include Files:
C
C   mpif.h
C   se_pe_info_ext:
C
C     se_my_pe    -- logical processor number
C -----------------------------------------------------------------------------

        module se_global_sum_module

        implicit none

        interface se_global_sum
          module procedure se_global_isum, se_global_rsum
        end interface

        contains

C -----------------------------------------------------------------------------
        function se_global_isum (var) result (se_global_isum_result)

        use se_pe_info_ext

	implicit none

        integer :: se_global_isum_result
        integer, intent(in) :: var

	include "mpif.h"

	integer :: sum, error

	call mpi_reduce (var, sum, 1, mpi_integer, mpi_sum, 0,
     &                   mpi_comm_world, error)

        if (se_my_pe .eq. 0) then
           se_global_isum_result = sum
	end if

        call mpi_bcast (se_global_isum_result, 1, mpi_integer, 0, 
     &                  mpi_comm_world, error)

	return
	end function se_global_isum
C -----------------------------------------------------------------------------

        function se_global_rsum (var) result (se_global_rsum_result)

        use se_pe_info_ext

	implicit none

        real :: se_global_rsum_result
        real, intent(in) :: var

	include "mpif.h"

	real sum
        integer error

	call mpi_reduce (var, sum, 1, mpi_real, mpi_sum, 0,
     &                   mpi_comm_world, error)

        if (se_my_pe .eq. 0) then
           se_global_rsum_result = sum
	end if

        call mpi_bcast (se_global_rsum_result, 1, mpi_real, 0, 
     &                  mpi_comm_world, error)

	return
	end function se_global_rsum

        end module se_global_sum_module

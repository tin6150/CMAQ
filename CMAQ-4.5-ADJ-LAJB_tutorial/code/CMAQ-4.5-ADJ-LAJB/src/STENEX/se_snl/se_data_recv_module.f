C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/STENEX/src/se_snl/se_data_recv_module.f,v 1.1.1.1 2005/09/09 18:58:42 sjr Exp $

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

C --------------------------------------------------------------------------
C Purpose:
C
C   use F90 interface feature to achieve "faked" polymorphism for data 
C   receiving routine
C
C Revision history:
C
C   Orginal version: 11/05/99 by David Wong
C
C Note:
C
C   se_[n]d[e]_data_recv where [n] denotes the dimensionality of the data 
C   and [e] is optional, indicates the first two dimensions are not both 
C   decomposed
C
C Subroutine parameter description:
C
C   In:    rind      -- stores low and high index of each dimension for 
C                       receiving process
C          recv_from -- stores processor number which data is received from
C          dir_ind   -- one of those eight major communication directions
C          tag       -- message tag
C
C   InOut: data      -- variable that receives data from other processors
C --------------------------------------------------------------------------

	module se_data_recv_module

          implicit none

	  interface se_data_recv
            module procedure se_1d_data_recv,
     &                       se_2d_data_recv, se_2de_data_recv,
     &                       se_3d_data_recv, se_3de_data_recv,
     &                       se_4d_data_recv
	  end interface

          contains

C -----------------------------------------------------------------------------
	subroutine se_1d_data_recv (data, rind, recv_from, dir_ind, tag)

        implicit none
        include "mpif.h"

        real, intent(inout) :: data(:)
        integer, pointer :: rind(:, :), recv_from(:)
        integer, intent(in) :: dir_ind, tag

        integer :: i, rcount, error
        integer :: status(MPI_STATUS_SIZE)
        real :: rarray(size(data))

C -- receive data from corresponding processor

        rcount = rind(2,dir_ind) - rind(1,dir_ind) + 1

        call mpi_recv (rarray, rcount, mpi_real, recv_from(dir_ind),
     &                 tag, mpi_comm_world, status, error)

C -- unpack received data
        rcount = 0
        do i = rind(1,dir_ind), rind(2,dir_ind)
           rcount = rcount + 1
           data(i) = rarray(rcount)
        end do

	end subroutine se_1d_data_recv

C -----------------------------------------------------------------------------
        subroutine se_2d_data_recv (data, rind, recv_from, dir_ind, tag)

        implicit none
        include "mpif.h"

        real, intent(inout) :: data(:,:)
        integer, pointer :: rind(:, :, :), recv_from(:)
        integer, intent(in) :: dir_ind, tag

        integer :: i, j, rcount, error
        integer :: status(MPI_STATUS_SIZE)
        real :: rarray(size(data))

        rcount = (rind(2,1,dir_ind) - rind(1,1,dir_ind) + 1) *
     &           (rind(2,2,dir_ind) - rind(1,2,dir_ind) + 1)

        call mpi_recv (rarray, rcount, mpi_real, recv_from(dir_ind),
     &                 tag, mpi_comm_world, status, error)

C -- unpack received data
        rcount = 0
        do j = rind(1,2,dir_ind), rind(2,2,dir_ind)
           do i = rind(1,1,dir_ind), rind(2,1,dir_ind)
              rcount = rcount + 1
              data(i,j) = rarray(rcount)
           end do
        end do

	end subroutine se_2d_data_recv

C -----------------------------------------------------------------------------
        subroutine se_2de_data_recv (data, rind, recv_from, dir_ind, tag)

        implicit none
        include "mpif.h"

        real, intent(inout) :: data(:,:)
        integer, pointer :: rind(:, :), recv_from(:)
        integer, intent(in) :: dir_ind, tag

        integer :: i, j, rcount, error
        integer :: status(MPI_STATUS_SIZE)
        real :: rarray(size(data))

        rcount = (rind(2,dir_ind) - rind(1,dir_ind) + 1) *
     &           (ubound(data,2) - lbound(data,2) + 1)

        call mpi_recv (rarray, rcount, mpi_real, recv_from(dir_ind),
     &                 tag, mpi_comm_world, status, error)

C -- unpack received data
        rcount = 0
        do j = lbound(data,2), ubound(data,2)
           do i = rind(1,dir_ind), rind(2,dir_ind)
              rcount = rcount + 1
              data(i,j) = rarray(rcount)
           end do
        end do

	end subroutine se_2de_data_recv

C -----------------------------------------------------------------------------
        subroutine se_3d_data_recv (data, rind, recv_from, dir_ind, tag)

        implicit none
        include "mpif.h"

        real, intent(inout) :: data(:,:,:)
        integer, pointer :: rind(:, :, :), recv_from(:)
        integer, intent(in) :: dir_ind, tag

        integer :: i, j, k, rcount, error
        integer :: status(MPI_STATUS_SIZE)
        real :: rarray(size(data))

        rcount = (rind(2,1,dir_ind) - rind(1,1,dir_ind) + 1) *
     &           (rind(2,2,dir_ind) - rind(1,2,dir_ind) + 1) *
     &           (rind(2,3,dir_ind) - rind(1,3,dir_ind) + 1)

        call mpi_recv (rarray, rcount, mpi_real, recv_from(dir_ind),
     &                 tag, mpi_comm_world, status, error)

C -- unpack received data
        rcount = 0
        do k = rind(1,3,dir_ind), rind(2,3,dir_ind)
           do j = rind(1,2,dir_ind), rind(2,2,dir_ind)
              do i = rind(1,1,dir_ind), rind(2,1,dir_ind)
                 rcount = rcount + 1
                 data(i,j,k) = rarray(rcount)
              end do
           end do
        end do

        end subroutine se_3d_data_recv

C -----------------------------------------------------------------------------
        subroutine se_3de_data_recv (data, rind, recv_from, dir_ind, tag)

        implicit none
        include "mpif.h"

        real, intent(inout) :: data(:,:,:)
        integer, pointer :: rind(:, :), recv_from(:)
        integer, intent(in) :: dir_ind, tag

        integer :: i, j, k, rcount, error
        integer :: status(MPI_STATUS_SIZE)
        real :: rarray(size(data))

        rcount = (rind(2,dir_ind) - rind(1,dir_ind) + 1) *
     &           (ubound(data,2) - lbound(data,2) + 1) *
     &           (ubound(data,3) - lbound(data,3) + 1)

        call mpi_recv (rarray, rcount, mpi_real, recv_from(dir_ind),
     &                 tag, mpi_comm_world, status, error)

C -- unpack received data
        rcount = 0
        do k = lbound(data,3), ubound(data,3)
           do j = lbound(data,2), ubound(data,2)
              do i = rind(1,dir_ind), rind(2,dir_ind)
                 rcount = rcount + 1
                 data(i,j,k) = rarray(rcount)
              end do
           end do
        end do

	end subroutine se_3de_data_recv

C -----------------------------------------------------------------------------
        subroutine se_4d_data_recv (data, rind, recv_from, dir_ind, tag)

        implicit none
        include "mpif.h"

        real, intent(inout) :: data(:,:,:,:)
        integer, pointer :: rind(:, :, :), recv_from(:)
        integer, intent(in) :: dir_ind, tag

        integer :: i, j, k, l, rcount, error
        integer :: status(MPI_STATUS_SIZE)
        real :: rarray(size(data))

        rcount = (rind(2,1,dir_ind) - rind(1,1,dir_ind) + 1) *
     &           (rind(2,2,dir_ind) - rind(1,2,dir_ind) + 1) *
     &           (rind(2,3,dir_ind) - rind(1,3,dir_ind) + 1) *
     &           (rind(2,4,dir_ind) - rind(1,4,dir_ind) + 1)

        call mpi_recv (rarray, rcount, mpi_real, recv_from(dir_ind),
     &                 tag, mpi_comm_world, status, error)

C -- unpack received data
        rcount = 0
        do l = rind(1,4,dir_ind), rind(2,4,dir_ind)
           do k = rind(1,3,dir_ind), rind(2,3,dir_ind)
              do j = rind(1,2,dir_ind), rind(2,2,dir_ind)
                 do i = rind(1,1,dir_ind), rind(2,1,dir_ind)
                    rcount = rcount + 1
                    data(i,j,k,l) = rarray(rcount)
                 end do
              end do
           end do
        end do

	end subroutine se_4d_data_recv

        end module se_data_recv_module

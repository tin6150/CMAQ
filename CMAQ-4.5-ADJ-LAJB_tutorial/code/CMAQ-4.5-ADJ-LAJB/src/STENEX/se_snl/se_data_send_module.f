C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/STENEX/src/se_snl/se_data_send_module.f,v 1.1.1.1 2005/09/09 18:58:42 sjr Exp $

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

C --------------------------------------------------------------------------
C Purpose:
C
C   use F90 interface feature to achieve "faked" polymorphism for data
C   sending routine
C
C Revision history:
C
C   Orginal version: 11/05/99 by David Wong
C                    07/23/01 by David Wong
C                      -- use mpi_isend rather than mpi_send to send messages
C                    03/06/02 David Wong
C                      -- use blocking communication scheme due to non-blocking
C                         timing problems on IBM SP
C
C Note:
C
C   se_[n]d[e]_data_send where [n] denotes the dimensionality of the data
C   and [e] is optional, indicates the first two dimensions are not both
C   decomposed
C
C Subroutine parameter description:
C
C   In:    sind    -- stores low and high index of each dimension for
C                     sending process
C          send_to -- stores processor number which data is sent to
C          dir_ind -- one of those eight major communication directions
C          tag     -- message tag
C          data    -- variable that sends data to other processors
C --------------------------------------------------------------------------

	module se_data_send_module

          implicit none

	  interface se_data_send
            module procedure se_1d_data_send,
     &                       se_2d_data_send, se_2de_data_send,
     &                       se_3d_data_send, se_3de_data_send,
     &                       se_4d_data_send
	  end interface

          contains

C --------------------------------------------------------------------------
	subroutine se_1d_data_send (data, sind, send_to, dir_ind, tag, request)

        implicit none
        include "mpif.h"

        real, intent(in) :: data(:)
        integer, pointer :: sind(:, :), send_to(:)
        integer, intent(in) :: dir_ind, tag
        integer, intent(out) :: request

        integer :: i, scount, error
        real :: sarray(size(data))

C -- pack data for sending
        scount = 0
        do i = sind(1,dir_ind), sind(2,dir_ind)
           scount = scount + 1
           sarray(scount) = data(i)
        end do

c       call mpi_isend (sarray, scount, mpi_real, send_to(dir_ind),
c    &                  tag, mpi_comm_world, request, error)
        call mpi_send (sarray, scount, mpi_real, send_to(dir_ind),
     &                  tag, mpi_comm_world, error)

	end subroutine se_1d_data_send

C -----------------------------------------------------------------------------
        subroutine se_2d_data_send (data, sind, send_to, dir_ind, tag, request)

        implicit none
        include "mpif.h"

        real, intent(in) :: data(:,:)
        integer, pointer :: sind(:, :, :), send_to(:)
        integer, intent(in) :: dir_ind, tag
        integer, intent(out) :: request

        integer :: i, j, scount, error
        real :: sarray(size(data))

        scount = 0

C -- pack data for sending
        do j = sind(1,2,dir_ind), sind(2,2,dir_ind)
           do i = sind(1,1,dir_ind), sind(2,1,dir_ind)
              scount = scount + 1
              sarray(scount) = data(i,j)
           end do
        end do

c       call mpi_isend (sarray, scount, mpi_real, send_to(dir_ind),
c    &                  tag, mpi_comm_world, request, error)
        call mpi_send (sarray, scount, mpi_real, send_to(dir_ind),
     &                  tag, mpi_comm_world, error)

	end subroutine se_2d_data_send

C -----------------------------------------------------------------------------
        subroutine se_2de_data_send (data, sind, send_to, dir_ind, tag, request)

        implicit none
        include "mpif.h"

        real, intent(in) :: data(:,:)
        integer, pointer :: sind(:, :), send_to(:)
        integer, intent(in) :: dir_ind, tag
        integer, intent(out) :: request

        integer :: i, j, scount, error
        real :: sarray(size(data))

        scount = 0

C -- pack data for sending
        do j = lbound(data,2), ubound(data,2)
           do i = sind(1,dir_ind), sind(2,dir_ind)
              scount = scount + 1
              sarray(scount) = data(i,j)
           end do
        end do

c       call mpi_isend (sarray, scount, mpi_real, send_to(dir_ind),
c    &                  tag, mpi_comm_world, request, error)
        call mpi_send (sarray, scount, mpi_real, send_to(dir_ind),
     &                  tag, mpi_comm_world, error)

	end subroutine se_2de_data_send

C -----------------------------------------------------------------------------
        subroutine se_3d_data_send (data, sind, send_to, dir_ind, tag, request)

        implicit none
        include "mpif.h"

        real, intent(in) :: data(:,:,:)
        integer, pointer :: sind(:, :, :), send_to(:)
        integer, intent(in) :: dir_ind, tag
        integer, intent(out) :: request

        integer :: i, j, k, scount, error
        real :: sarray(size(data))

        scount = 0

C -- pack data for sending
        do k = sind(1,3,dir_ind), sind(2,3,dir_ind)
           do j = sind(1,2,dir_ind), sind(2,2,dir_ind)
              do i = sind(1,1,dir_ind), sind(2,1,dir_ind)
                 scount = scount + 1
                 sarray(scount) = data(i,j,k)
              end do
           end do
        end do

c       call mpi_isend (sarray, scount, mpi_real, send_to(dir_ind),
c    &                  tag, mpi_comm_world, request, error)
        call mpi_send (sarray, scount, mpi_real, send_to(dir_ind),
     &                  tag, mpi_comm_world, error)

        end subroutine se_3d_data_send

C -----------------------------------------------------------------------------
        subroutine se_3de_data_send (data, sind, send_to, dir_ind, tag, request)

        implicit none
        include "mpif.h"

        real, intent(in) :: data(:,:,:)
        integer, pointer :: sind(:, :), send_to(:)
        integer, intent(in) :: dir_ind, tag
        integer, intent(out) :: request

        integer :: i, j, k, scount, error
        real :: sarray(size(data))

        scount = 0

C -- pack data for sending
        do k = lbound(data,3), ubound(data,3)
           do j = lbound(data,2), ubound(data,2)
              do i = sind(1,dir_ind), sind(2,dir_ind)
                 scount = scount + 1
                 sarray(scount) = data(i,j,k)
              end do
           end do
        end do

c       call mpi_isend (sarray, scount, mpi_real, send_to(dir_ind),
c    &                  tag, mpi_comm_world, request, error)
        call mpi_send (sarray, scount, mpi_real, send_to(dir_ind),
     &                  tag, mpi_comm_world, error)

	end subroutine se_3de_data_send

C -----------------------------------------------------------------------------
        subroutine se_4d_data_send (data, sind, send_to, dir_ind, tag, request)

        implicit none
        include "mpif.h"

        real, intent(in) :: data(:,:,:,:)
        integer, pointer :: sind(:, :, :), send_to(:)
        integer, intent(in) :: dir_ind, tag
        integer, intent(out) :: request

        integer :: i, j, k, l, scount, error
        real :: sarray(size(data))

        scount = 0

C -- pack data for sending
        do l = sind(1,4,dir_ind), sind(2,4,dir_ind)
           do k = sind(1,3,dir_ind), sind(2,3,dir_ind)
              do j = sind(1,2,dir_ind), sind(2,2,dir_ind)
                 do i = sind(1,1,dir_ind), sind(2,1,dir_ind)
                    scount = scount + 1
                    sarray(scount) = data(i,j,k,l)
                 end do
              end do
           end do
        end do

c       call mpi_isend (sarray, scount, mpi_real, send_to(dir_ind),
c    &                  tag, mpi_comm_world, request, error)
        call mpi_send (sarray, scount, mpi_real, send_to(dir_ind),
     &                  tag, mpi_comm_world, error)

	end subroutine se_4d_data_send

        end module se_data_send_module

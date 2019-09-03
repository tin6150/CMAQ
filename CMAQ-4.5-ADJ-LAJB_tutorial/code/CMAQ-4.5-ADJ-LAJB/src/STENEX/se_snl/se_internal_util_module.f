C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/STENEX/src/se_snl/se_internal_util_module.f,v 1.1.1.1 2005/09/09 18:58:42 sjr Exp $

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

C --------------------------------------------------------------------------
C Purpose:
C
C   -- use F90 module feature to group utility routines so that they can be
C      accessed within se library
C
C Revision history:
C
C   Orginal version: 11/05/99 by David Wong
C --------------------------------------------------------------------------

	module se_internal_util_module

        implicit none

        contains

C -----------------------------------------------------------------------------
C Purpose:
C
C   To determine mapping of a grid onto a processor configuration with data 
C redistribution by calculating starting and ending row and column. The mapping
C is kept in each PE. This routine provides flexibility (see routine parameter 
C list) of domain decomposition in the level dimension as well for future use. 
C Currently, only row and column dimensions are being decomposed.
C
C There are two ways, which determines by the existing of an optional variable
C flag, to generate a map: 1. the incoming parameters are indexes of a 
C partitioned sub-grid, 2. the incoming parameters are indexes of the original 
C sub-grid without partition.
C
C To deal with the first case, no special calculation is done except to assign 
C the incoming indexes to the map. Calculation is required for the second case. 
C For example, given 8 processors with 2 x 4 processor configuration (row by
C column), a 20x25 data grid, a 10 x 5 sub grid starts at (7,5), the following 
C are the starting and ending row and column, respectively.
C
C      PE #          row               column
C      -----------------------------------------
C       0           7, 11               5,  6
C       1           7, 11               7,  7
C       2           7, 11               8,  8
C       3           7, 11               9,  9
C       4          12, 16               5,  6
C       5          12, 16               7,  7
C       6          12, 16               8,  8
C       7          12, 16               9,  9
C
C Subroutine parameter description:
C
C   In:  begrow -- beginning row index
C        endrow -- ending row index
C        begcol -- beginning column index
C        endcol -- ending column index
C        nprow  -- number of processors along the row dimension
C        npcol  -- number of processors along the column dimension
C        flag   -- an optional variable to indicate which one of the two ways
C                  to generate a index map
C
C   Out: index  -- the index map
C
C Local variable description:
C
C   temp     -- temporary variable
C   error    -- mpi function call error code
C   block    -- block size
C   loc_prow -- local loop index
C   loc_pcol -- local loop index
C   my_pe    -- local processor number
C
C Include files:
C
C   mpif.h
C   se_pe_info_ext
C   se_domain_info_ext
C   se_ori_ext
C
C Revision history:
C
C   Orginal version: 2/15/99 by David Wong
C
C                    11/05/99 by David Wong
C                      -- recode the code using F90 syntax
C                      -- provide a centralize spot to modify the global map
C                         according to the data orientation
C
C                    10/05/00 by David Wong
C                      -- combined two mapping routine into one and using a new
C                         optional variable flag to distinguish them
C -----------------------------------------------------------------------------

	subroutine se_generate_map (begrow, endrow, begcol, endcol, 
     &                              nprow, npcol, index, flag)

        use se_pe_info_ext

	implicit none

        include "mpif.h"

        integer, intent(in)  :: begrow, endrow, begcol, endcol
        integer, intent(in)  :: nprow, npcol
        integer, optional, intent(in) :: flag
        integer, intent(out) :: index(:,:,:)

        integer :: my_pe, temp, block, loc_prow, loc_pcol, error

        if (present(flag)) then

C -- figure out the low and high column and row index of the
C    processor analysis (PA) grid, respectively

           index(1, 1, se_my_pe+1) = begcol
           index(2, 1, se_my_pe+1) = endcol

           index(1, 2, se_my_pe+1) = begrow
           index(2, 2, se_my_pe+1) = endrow

C -- each PE send PA grid index info to PE 0, gathering process

           call mpi_gather (index(1, 1, se_my_pe+1), 4, mpi_integer, 
     &                      index(1, 1, se_my_pe+1), 4, mpi_integer, 
     &                      0, mpi_comm_world, error)

C -- PE 0 boardcast entire PA grid index info

           call mpi_bcast (index(1, 1, 1), 4*se_numprocs, mpi_integer, 0,
     &                     mpi_comm_world, error)

        else

C -- figure out the low and high column and row index of the 
C    processor analysis (PA) grid, respectively

           do loc_pcol = 0, npcol-1
              temp = mod((endcol - begcol + 1), npcol)
              block = (endcol - begcol + 1) / npcol

              do loc_prow = 0, nprow-1
                 my_pe = loc_prow * npcol + loc_pcol
                 if (loc_pcol .lt. temp) then
                    index(1, 1, my_pe+1) = begcol + loc_pcol * (block + 1)
                    index(2, 1, my_pe+1) = index(1, 1, my_pe+1) + block
                 else
                    index(1, 1, my_pe+1) = begcol + temp * (block + 1)
     &                                     + (loc_pcol - temp) * block
                    index(2, 1, my_pe+1) = index(1, 1, my_pe+1) + block - 1
                 end if
              end do
           end do

           do loc_prow = 0, nprow-1
              temp = mod((endrow - begrow + 1), nprow)
              block = (endrow - begrow + 1) / nprow

              do loc_pcol = 0, npcol-1
                 my_pe = loc_prow * npcol + loc_pcol
                 if (loc_prow .lt. temp) then
                    index(1, 2, my_pe+1) = begrow + loc_prow * (block + 1)
                    index(2, 2, my_pe+1) = index(1, 2, my_pe+1) + block
                 else
                    index(1, 2, my_pe+1) = begrow + temp * (block + 1)
     &                                     + (loc_prow - temp) * block
                    index(2, 2, my_pe+1) = index(1, 2, my_pe+1) + block - 1
                 end if
              end do
           end do

        end if

	return
	end subroutine se_generate_map

C --------------------------------------------------------------------------
C Purpose:
C
C   -- to interchange two integer values
C
C Revision history:
C
C   Orginal version: 11/05/99 by David Wong
C --------------------------------------------------------------------------
        subroutine swap (data1, data2)

        implicit none

        integer, intent(inout) :: data1, data2

        integer :: temp

        temp = data1
        data1 = data2
        data2 = temp

        return
        end subroutine swap

C --------------------------------------------------------------------------
C Purpose:
C
C   -- to extract a character string of integer into individual integers
C
C Revision history:
C
C   Orginal version: 11/05/99 by David Wong
C                    05/04/01 by David Wong
C                     -- remove all leading double blank spaces
C --------------------------------------------------------------------------

        subroutine se_string_to_integer (str, data, n)

        character (len = *), intent(inout) :: str
        integer, intent(inout) :: data(*)
        integer, intent(out) :: n
        character (len = 80) :: loc_str

        integer i, j, stat, len
        logical stop

C -- remove all leading double blank spaces
        stop = .false.
        do while (.not. stop)
          i = index(trim(str), "  ")
          if (i == 0) then
             stop = .true.
          else
             do j = i+1, 80
                str(j-1:j-1) = str(j:j)
             end do
          end if
        end do

C -- if the first character is a blank space, remove it
        if (str(1:1) .eq. ' ') then
           str(1:79) = str(2:80)
        end if

C -- extract each individual integer
        stop = .false.
        i = 1
        j = 1
        do while (.not. stop)
           read (str(i:80), *, iostat=stat) data(j)
           if (stat .ne. 0) then
              j = j - 1
              stop = .true.
           else
              j = j + 1
              i = index(str(i:80), ' ') + i
           end if
        end do

        n = j

        end subroutine se_string_to_integer

C --------------------------------------------------------------------------
C Purpose:
C
C   -- to modify existing global map when a dot file is encountered (primarily
C      for DFIO application)
C
C Revision history:
C
C   Orginal version: 05/24/01 by David Wong
C --------------------------------------------------------------------------

        subroutine se_dotfile_map (map1, nprow1, npcol1, map2, nprow2, npcol2)

        implicit none

        integer, intent(inout) :: map1(:,:,:), map2(:,:,:)
        integer, intent(in)    :: nprow1, npcol1, nprow2, npcol2

        integer :: i

        do i = npcol1, nprow1*npcol1, npcol1
           map1(2,1,i) = map1(2,1,i) + 1
        end do
        do i = nprow1*npcol1, nprow1*npcol1-npcol1+1, -1
           map1(2,2,i) = map1(2,2,i) + 1
        end do

        do i = 1, nprow2*npcol2
           map2(2,1,i) = map2(2,1,i) + 1
           map2(2,2,i) = map2(2,2,i) + 1
        end do

        end subroutine se_dotfile_map

C --------------------------------------------------------------------------
C Purpose:
C
C   -- to adjust the stencil size for boundary processors when there is/are a
C      NE, SE, SW, or/and NW communication. Consider a 3 x 2 processor 
C      configuration as shown below and suppose there is a NE communication:
C
C         3   4   5
C         0   1   2
C
C      processor 0's NE portion will receive from processor 4. However there is
C      no processor which is NE of processor 4. This routine will make NE 
C      portion of processor 4 available and the data is coming from processor 
C      5.
C
C Subroutine parameter description:
C
C   In: ndis  -- north displacement
C       edis  -- east displacement
C       sdis  -- south displacement
C       wdis  -- west displacement
C       flag  -- indicator: sending (1) or receiving (2)
C
C  Out: n_adj -- north adjustment
C       e_adj -- east adjustment
C       s_adj -- south adjustment
C       w_adj -- west adjustment
C
C Revision history:
C
C   Orginal version: 1/17/01 by David Wong
C --------------------------------------------------------------------------
        subroutine se_corner_adjust (ndis, edis, sdis, wdis, flag,
     &                               n_adj, e_adj, s_adj, w_adj)

        use se_pe_info_ext

        implicit none

        integer, intent(in)  :: ndis, edis, sdis, wdis, flag
        integer, intent(out) :: n_adj, e_adj, s_adj, w_adj

        include 'mpif.h'

        integer :: my_pe, error

        call mpi_comm_rank (mpi_comm_world, my_pe, error)

        n_adj = 0
        e_adj = 0
        s_adj = 0
        w_adj = 0

C -- adjust sending parameters
        if (flag .eq. 1) then

C -- adjustment north and east bound, respectively
           if ((ndis .gt. 0) .and. (edis .gt. 0)) then
              if ((my_pe .gt. 0) .and. (my_pe .le. se_npcol-1)) then
                 n_adj = ndis
              end if
              if (      (my_pe .lt. se_npcol*se_nprow-1)
     &            .and. (mod(my_pe, se_npcol) .eq. se_npcol-1)) then
                 e_adj = edis
              end if
           end if

C -- adjustment south and east bound, respectively
           if ((sdis .gt. 0) .and. (edis .gt. 0)) then
              if (my_pe .gt. se_npcol*(se_nprow-1)) then
                 s_adj = sdis
                 end if
              if (      (my_pe .gt. se_npcol-1)
     &            .and. (mod(my_pe, se_npcol) .eq. se_npcol-1)) then
                 e_adj = edis
              end if
           end if

C -- adjustment south and west bound, respectively
           if ((sdis .gt. 0) .and. (wdis .gt. 0)) then
              if (      (my_pe .ge. se_npcol*(se_nprow-1))
     &            .and. (my_pe .lt. se_npcol*se_nprow-1)) then
                 s_adj = sdis
              end if
              if ((mod(my_pe, se_npcol) .eq. 0) .and. (my_pe .gt. 0)) then
                 w_adj = wdis
              end if
           end if

C -- adjustment north and west bound, respectively
           if ((ndis .gt. 0) .and. (wdis .gt. 0)) then
              if (my_pe .lt. se_npcol-1) then
                 n_adj = ndis
              end if
              if (      (mod(my_pe, se_npcol) .eq. 0)
     &            .and. (my_pe .lt. se_npcol*(se_nprow-1))) then
                 w_adj = wdis
              end if
           end if

        else     ! -- adjust receiving parameters

C -- adjustment north and east bound, respectively
           if ((ndis .gt. 0) .and. (edis .gt. 0)) then
              if (my_pe .lt. se_npcol-1) then
                 n_adj = ndis
              end if
              if (      (my_pe .gt. se_npcol-1)
     &            .and. (mod(my_pe, se_npcol) .eq. se_npcol-1)) then
                 e_adj = edis
              end if
           end if

C -- adjustment south and east bound, respectively
           if ((sdis .gt. 0) .and. (edis .gt. 0)) then
              if (      (my_pe .lt. se_nprow*se_npcol-1)
     &            .and. (my_pe .ge. se_npcol*(se_nprow-1))) then
                 s_adj = sdis
                 end if
              if (      (my_pe .lt. se_nprow*se_npcol-1)
     &            .and. (mod(my_pe, se_npcol) .eq. se_npcol-1)) then
                 e_adj = edis
              end if
           end if

C -- adjustment south and west bound, respectively
           if ((sdis .gt. 0) .and. (wdis .gt. 0)) then
              if (my_pe .gt. se_npcol*(se_nprow-1)) then
                 s_adj = sdis
              end if
              if (      (mod(my_pe, se_npcol) .eq. 0)
     &            .and. (my_pe .lt. se_npcol*(se_nprow-1))) then
                 w_adj = wdis
              end if
           end if

C -- adjustment north and west bound, respectively
           if ((ndis .gt. 0) .and. (wdis .gt. 0)) then
              if ((my_pe .lt. se_npcol) .and. (my_pe .ge. 0)) then
                 n_adj = ndis
              end if
              if ((mod(my_pe, se_npcol) .eq. 0) .and. (my_pe .gt. 0)) then
                 w_adj = wdis
              end if
           end if
        end if

        end subroutine se_corner_adjust
 
	end module se_internal_util_module

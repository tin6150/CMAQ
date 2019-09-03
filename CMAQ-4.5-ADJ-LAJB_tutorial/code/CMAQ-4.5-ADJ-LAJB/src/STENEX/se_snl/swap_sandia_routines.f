
C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/STENEX/src/se_snl/swap_sandia_routines.f,v 1.1.1.1 2005/09/09 18:58:42 sjr Exp $

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

c Swap 2d,3d,4d routines

c inter-processor swap within a 2d array

      subroutine swap2d(send,recv,n1,n2,dim1,dir)
      use swap_sandia
      implicit none
      include 'mpif.h'

      real send(*)           ! 1st value to be sent
      real recv(*)           ! 1st value to be received
      integer n1,n2          ! # of values to send in each dim of 2d array
      integer dim1           ! 1st dimension of 2d array
      integer dir	     ! direction to recv from: NSEW

      integer i,j,m,n,ntotal,offset_ij
      integer recvproc,sendproc
      integer irequest,istatus(MPI_STATUS_SIZE),ierror
      real, allocatable :: rbuf(:),sbuf(:)

      ntotal = n1*n2
      offset_ij = dim1 - n1
      recvproc = recvneigh(dir)
      sendproc = sendneigh(dir)

      if (recvproc >= 0) then
        allocate(rbuf(ntotal))
        call MPI_Irecv(rbuf,ntotal,MPI_REAL,recvproc,0,MPI_COMM_WORLD,
     $       irequest,ierror)
      endif

      if (sendproc >= 0) then
  
        allocate(sbuf(ntotal))
  
        m = 1
        n = 1

        do j = 1,n2
          do i = 1,n1
            sbuf(n) = send(m)
            n = n + 1
            m = m + 1
          enddo
          m = m + offset_ij
        enddo
  
        call MPI_Send(sbuf,ntotal,MPI_REAL,sendproc,0,MPI_COMM_WORLD,
     $       ierror)
  
        deallocate(sbuf)
  
      endif
  
      if (recvproc >= 0) then
  
        call MPI_Wait(irequest,istatus,ierror)
  
        m = 1
        n = 1

        do j = 1,n2
          do i = 1,n1
            recv(m) = rbuf(n)
            n = n + 1
            m = m + 1
          enddo
          m = m + offset_ij
        enddo
  
        deallocate(rbuf)
  
      endif
  
      return
      end subroutine swap2d

c inter-processor swap within a 3d array

      subroutine swap3d(send,recv,n1,n2,n3,dim1,dim2,dir)
      use swap_sandia
      implicit none
      include 'mpif.h'

      real send(*)           ! 1st value to be sent
      real recv(*)           ! 1st value to be received
      integer n1,n2,n3       ! # of values to send in each dim of 3d array
      integer dim1,dim2      ! 1st and 2nd dimensions of 3d array
      integer dir	     ! direction to recv from: NSEW

      integer i,j,k,m,n,ntotal,offset_ij,offset_jk
      integer recvproc,sendproc
      integer irequest,istatus(MPI_STATUS_SIZE),ierror
      real, allocatable :: rbuf(:),sbuf(:)

      ntotal = n1*n2*n3
      offset_ij = dim1 - n1
      offset_jk = dim1*dim2 - n2*dim1
      recvproc = recvneigh(dir)
      sendproc = sendneigh(dir)

      if (recvproc >= 0) then
        allocate(rbuf(ntotal))
        call MPI_Irecv(rbuf,ntotal,MPI_REAL,recvproc,0,MPI_COMM_WORLD,
     $       irequest,ierror)
      endif

      if (sendproc >= 0) then
  
        allocate(sbuf(ntotal))
  
        m = 1
        n = 1

        do k = 1,n3
          do j = 1,n2
            do i = 1,n1
              sbuf(n) = send(m)
              n = n + 1
              m = m + 1
            enddo
            m = m + offset_ij
          enddo
          m = m + offset_jk
        enddo
  
        call MPI_Send(sbuf,ntotal,MPI_REAL,sendproc,0,MPI_COMM_WORLD,
     $       ierror)
  
        deallocate(sbuf)
  
      endif
  
      if (recvproc >= 0) then
  
        call MPI_Wait(irequest,istatus,ierror)
  
        m = 1
        n = 1

        do k = 1,n3
          do j = 1,n2
            do i = 1,n1
              recv(m) = rbuf(n)
              n = n + 1
              m = m + 1
            enddo
            m = m + offset_ij
          enddo
          m = m + offset_jk
        enddo
  
        deallocate(rbuf)
  
      endif
  
      return
      end subroutine swap3d

c inter-processor swap within a 4d array

      subroutine swap4d(send,recv,n1,n2,n3,n4,dim1,dim2,dim3,dir)
      use swap_sandia
      implicit none
      include 'mpif.h'

      real send(*)           ! 1st value to be sent
      real recv(*)           ! 1st value to be received
      integer n1,n2,n3,n4    ! # of values to send in each dim of 4d array
      integer dim1,dim2,dim3 ! 1st,2nd,3rd dimensions of 4d array
      integer dir	     ! direction to recv from: NSEW

      integer i,j,k,l,m,n,ntotal,offset_ij,offset_jk,offset_kl
      integer recvproc,sendproc
      integer irequest,istatus(MPI_STATUS_SIZE),ierror
      real, allocatable :: rbuf(:),sbuf(:)

      ntotal = n1*n2*n3*n4
      offset_ij = dim1 - n1
      offset_jk = dim1*dim2 - n2*dim1
      offset_kl = dim1*dim2*dim3 - n3*dim1*dim2
      recvproc = recvneigh(dir)
      sendproc = sendneigh(dir)

      if (recvproc >= 0) then
        allocate(rbuf(ntotal))
        call MPI_Irecv(rbuf,ntotal,MPI_REAL,recvproc,0,MPI_COMM_WORLD,
     $       irequest,ierror)
      endif

      if (sendproc >= 0) then
  
        allocate(sbuf(ntotal))
  
        m = 1
        n = 1

        do l = 1,n4
          do k = 1,n3
            do j = 1,n2
              do i = 1,n1
                sbuf(n) = send(m)
                n = n + 1
                m = m + 1
              enddo
              m = m + offset_ij
            enddo
            m = m + offset_jk
          enddo
          m = m + offset_kl
        enddo
  
        call MPI_Send(sbuf,ntotal,MPI_REAL,sendproc,0,MPI_COMM_WORLD,
     $       ierror)
  
        deallocate(sbuf)
  
      endif
  
      if (recvproc >= 0) then
  
        call MPI_Wait(irequest,istatus,ierror)
  
        m = 1
        n = 1

        do l = 1,n4
          do k = 1,n3
            do j = 1,n2
              do i = 1,n1
                recv(m) = rbuf(n)
                n = n + 1
                m = m + 1
              enddo
              m = m + offset_ij
            enddo
            m = m + offset_jk
          enddo
          m = m + offset_kl
        enddo

        deallocate(rbuf)
  
      endif
  
      return
      end subroutine swap4d

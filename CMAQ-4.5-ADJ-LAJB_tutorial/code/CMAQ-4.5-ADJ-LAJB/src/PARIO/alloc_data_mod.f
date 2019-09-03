C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/PARIO/src/alloc_data_mod.f,v 1.1.1.1 2005/09/09 16:18:17 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

C....................................................................
C  CONTAINS:  Allocated variables used by pwrgrdd
              
C  REVISION HISTORY:
C       Original version 01/10/05 by David Wong
C....................................................................

      MODULE ALLOC_DATA_MODULE

      REAL, ALLOCATABLE, SAVE :: WRITBUF(:, :, :)
      REAL, ALLOCATABLE, SAVE :: RECVBUF(:)

      END MODULE ALLOC_DATA_MODULE

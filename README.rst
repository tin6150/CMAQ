TMP README
~~~~~~~~~~

This is my attempt to build CMAQ 5.2.1 in a container.
May not work yet.

Also adding Lucas Bastein Adjoin models, but that maybe for CMAQ 4.5.

Original README.md from CMAQ from EPA/CMAS is at README.orig.md


Docker parts
------------

  * tin6150/os4cmaq - base OS layer, currently CentOS 7.  Include OS' OpenMPI rpm.
  * tin6150/lib4cmaq - supporting libraries: HDF5, NetCDF
  * tin6150/adjoin   - Lucas' Adjoin model, based on CMAQ 4.5, use IOAPI 3.0
  * tin6150/cmaq     - cmaq program itself.  Currently for version 5.2.1 



Adjoin Model from Lucas
~~~~~~~~~~~~~~~~~~~~~~~

Lucas wrote a model that Ling/Huy are running.  He has a couple of papers.
supplement said to have source code:
https://www.atmos-chem-phys.net/19/8363/2019/acp-19-8363-2019-supplement.zip
  *	see TMP/ for such extract
	need to compare against /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB

if can't find latest from github, then maybe better off get code from Ling...
just copy into my forked CMAQ repo, and code would be avail then.



run_eta
=======

this folder contain scripts and logs that run Lucas' adjoin model.

CMAQ-4.5-ADJ-LAJB_tutorial
==========================

Copied code for Lucas Adjoin model, see the README in there for source and what files were included.



various log and info learned about CMAQ CCTM.
from job submission for pghuy

troubleshooting and trying to get optimization node usage 
to get run time to less than 72 hours limit of QoS


original script location
/global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/CCTM/SARMAP_KZMIN_F_O3/ADJ_RUN
former name    run_CCTM_258_7day.csh
name i gave it run_CCTM_258_7day.tin.csh  (much annotation in it now)

simply submit job as
sbatch run_CCTM_258_7day.tin.csh      ## orig version
sbatch run_CCTM_258_7day.tin1a.csh    ## slightly tweaked for multiple concurrent run, has lots of comments in it, use this in lrc **<<**

the ADJ*slurm_info files are manually captured output info of my job
such as squeue, ls output, and notes of what i have observed

summary for now is that pghuy/ling's job works fastest with 
(maybe 4*LR5 nodes).
can't seems to go beyond 64 domains.  
Maybe once did 4*28 on lr5, 112 domains, and worked?
But most runs more than 64 domains crashed, even some with only 64 domains crash (eg n0035.cf1, very finicky).





main output of CMAQ/CCTM is in 
/global/scratch/tin/cmaq_run* 

drwxrwxr-x 14 tin  itd       4096 Aug 11 14:03 adj_OLD_ERASEABLE
drwxr-xr-x  2 tin  itd      12288 Aug 11 14:00 adj_kzF_O3_GE66_Popdens_258_20368176.4xLR6_cancelled
drwxr-xr-x  2 tin  itd      20480 Aug 11 14:26 adj_kzF_O3_GE66_Popdens_258_20369139.8xLR6_maybeSwampped_cancelled
drwxr-xr-x  2 tin  itd      20480 Aug 11 14:42 adj_kzF_O3_GE66_Popdens_258_20369822.8xLR6_noGoodForReal
drwxr-xr-x  2 tin  itd      12288 Aug 11 14:51 adj_kzF_O3_GE66_Popdens_258_20370160.6xLR6_noGoodEither
drwxr-xr-x  2 tin  itd      12288 Aug 11 15:07 adj_kzF_O3_GE66_Popdens_258_20370779


many of the run with more than 4 nodes * 16 cores (64 domains) 
end up crashing
Huy end up doing all the run within the 72 hours limit of a job, i didn't end up doing anything.

for now, try to put Lucas code into a container, which hopefully means i know how to compile cmaq...


~~~~~~


perf.rst		= contain performance info of many run with varying number of nodes and cluster.  many crashes.  
				  may need to investigate crashes
				  best to do as enabling debug in CCTM?   maybe scaling problem, maybe mpi issue?
				  dont think it is bad hw...


reading list
============

Lucas tutorial, which is what Huy was running:
/global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB/documentation

/global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/document/README_pghuy.R
seems to be what Ling explained to Huy.

ccmt modeling code and config likely in a tutorial in 
/global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial



~~~~~

2021.01.14
trying to pick up again and debug the crashing problem.
maybe use valgrind to check if memory problem...
valgrand will take the debug (-g) bin from gcc and gfortran.

where is the script that actually run my example?  Ans:  run_eta/ [see higher up]
but need to get input files, since stuff in my global scratch got deleted somehow :-\






various log and info learned about CMAQ CCTM.
from job submission for pghuy

troubleshooting and trying to get optimization node usage 
to get run time to less than 72 hours limit of QoS


orig script location
/global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/CCTM/SARMAP_KZMIN_F_O3/ADJ_RUN
former name    run_CCTM_258_7day.csh
name i gave it run_CCTM_258_7day.tin.csh  (much annotation in it now)

simply submit job as
sbatch run_CCTM_258_7day.tin.csh

the *slurm_info files are manually captured output info of my job
such as squeue, ls output, and notes of what i have observed

summary for now is that pghuy/ling's job works fastest with 4* LR6 nodes, at 128 threads.
trying 6,8,24 nodes backfired and something causing such thing to exhibit similar to thrashing and run much much slower (may actually not run to produce usable output?)




main output of CMAQ/CCTM is in 
/global/scratch/tin

drwxrwxr-x 14 tin  itd       4096 Aug 11 14:03 adj_OLD_ERASEABLE
drwxr-xr-x  2 tin  itd      12288 Aug 11 14:00 adj_kzF_O3_GE66_Popdens_258_20368176.4xLR6_cancelled
drwxr-xr-x  2 tin  itd      20480 Aug 11 14:26 adj_kzF_O3_GE66_Popdens_258_20369139.8xLR6_maybeSwampped_cancelled
drwxr-xr-x  2 tin  itd      20480 Aug 11 14:42 adj_kzF_O3_GE66_Popdens_258_20369822.8xLR6_noGoodForReal
drwxr-xr-x  2 tin  itd      12288 Aug 11 14:51 adj_kzF_O3_GE66_Popdens_258_20370160.6xLR6_noGoodEither
drwxr-xr-x  2 tin  itd      12288 Aug 11 15:07 adj_kzF_O3_GE66_Popdens_258_20370779


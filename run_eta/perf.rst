
cmaq run performance (and nodes, crash log)

summary 2019.08.21 (also see email to Ling with lr6 as subject)

LR5 4x16 seems to run reliable, and would be faster than LR3.
LR5 4x28 might run, need more testing.   (112 domains)
LR6 doesn't run in any config :(
LR3, larter than 4x16, doesn't work either.  


~~~~~


8x8 = 64 maybe the largest stable domains.
tried 128 but had been crashing.


node x task    domains
----           -------
4x32 = 128 LR6      | Step 1: 0.618170E+03 |
4x32 = 128 LR6 16*8 | Step 1: 0.486613E+03 Step  25: 0.423033E+03 | crashed adj_kzF_O3_GE66_Popdens_258_2037817  2019.08  | crashed
2x32 =  64 LR6  8*8 | Step 1: 0.782988E+03 Step  18: 0.767757E+03 | crashed adj_kzF_O3_GE66_Popdens_258_20433307 2019.0813 8:20-13:29  | n0048.lr6,n0049.lr6
2x32 =  64 LR6  8*8 | Step 1: n/a | doa | XFIRST_BWD T  crashed at start.  ADJ258Sn_n0048_job_20441080.out_2x32_lr6_xfirst_bwd_T       n0048.lr6,n0049.lr6.
4x16 =  64 LR3  8*8 | Step 1: n/a | doa | XFIRST_BWD T (mostly stopped trying to use T version)   job 20441123  died on startup.
4x16 =  64 LR6  8*8 | Step 1: 0.731426E+03 Step   3: 0.107037E+04 | crashed cmaq_run2 20519295 2019.0818 1239 | n0024.lr6,n0025.lr6,n0055.lr6,n0070.lr6 |  try see if lr6 can do very basic stable lr3 run
				Primary job  terminated normally, but 1 process returned
				a non-zero exit code. Per user-direction, the job has been aborted.
				mpirun noticed that process rank 30 with PID 242626 on node n0025.lr6 exited on signal 11 (Segmentation fault).

4x16 =  64 LR3 Huy  | Step 1: 0.228843E+04 Step 167: 0.876607E+03 | adj_kzF_O3_GE66_Popdens_258_20443754 job ended.  SARMAP_258_2012_ALL_HYBRID.AL5CHK.nc but no other nc file
4x16 =  64 LR3  8*8 | Step 1: 0.948587E+03 Step 167: 0.876607E+03 | XFIRST_BWD F   job 20443754  2019.0813.1830  n0023.lr3,n0160.lr3,n0161.lr3,n0163.lr3 completed, no error.  so this is replicating Huy's job.
8x16 = 128 LR3 16*8 | Step 1: 0.167341E+04 Step 130: 0.207027E+04 | crashed, maybe cuz overwrote input.  rank 104 on n0194 seg faulted | 20485796 may have been overwritten by bad submit xx20485796xx :( | n0021.lr3,n0067.lr3,n0083.lr3,n0101.lr3,n0148.lr3,n0176.lr3,n0194.lr3,n0237.lr3 |  see if lr3 can run with 128 domains.   | 13 min, nc still at 28k, dont know how long it end up taking.  Step 1 is also kind of slow
8x16 = 128 LR3 16*8 | Step 1: 0.117466E+04 Step  19: 0.109833E+04 | crashed | 20534636 | n0016.lr3,n0054.lr3,n0107.lr3,n0175.lr3,n0196.lr3,n0201.lr3,n0233.lr3,n0253.lr3 | bleh... maybe got jobid mixed and moved slurm output capture file.  No idea why crash now.
8x16 = 128 LR3 16*8 | Step  1: 0.137640E+04 Step 66: 0.127617E+04 | crashed | 20541391 2019.0819T1800 | n0048.lr3,n0070.lr3,n0082.lr3,n0094.lr3,n0106.lr3,n0135.lr3,n0149.lr3,n0163.lr3  | luster had previous hung, but don't think affected this process.


4x28 = 112 LR5 14*8 |  Step 1: 0.526518E+03 Step 167: 0.420713E+03 | completed adj_kzF_O3_GE66_Popdens_258_20470913 | n0031.lr5,n0032.lr5,n0033.lr5,n0036.lr5  only 1 nc file.
4x16 =  64 LR5  8*8 |  Step 1: 0.714234E+03 Step  23: 0.599467E+03 | cancelled ADJ258S2_n0049_job_20452797.out 2019.0814 Sn2 | n0049.lr5,n0053.lr5,n0055.lr5,n0063.lr5  cancelled after 5h46 cuz doesnt look like it would crash on lr5, next test with more nodes.
		took 9 min to get SARMAP*nc to 3.4 G, then more time before it got to 14G
4x16 =  64 LR5  8*8 |  Step 1: 0.808601E+03 Step 167: 0.787851E+03  | completed! | 20522412 2018.0818 1543 | n0158.lr5,n0170.lr5,n0176.lr5,n0177.lr5 | repeat to let it run to completion, expect to work. | Luster partially hung during this run, but did not affect the job.
4x28 = 112 LR5 14*8 |  Step 1: ... crashed | 20593748 | n0073.lr5,n0075.lr5,n0079.lr5,n0080.lr5,n0084.lr5,n0086.lr5,n0088.lr5,n0090.lr5
mpirun noticed that process rank 24 with PID 95063 on node n0075.lr5 exited on signal 11 (Segmentation fault).
--------------------------------------------------------------------------
288075.183u 9671.816s 5:38:15.34 1467.0%        0+0k 2585680+786744io 365pf+0w
-----reverse-eng-com_CCTM-----------------------------------
	{DIR_CMAQ_W} is /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB/built_gcc_gfortran_parallel_O3_default-eddy
	{EXECPATH}   is /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB/built_gcc_gfortran_parallel_O3_default-eddy/bin/CCTM
	cctm: Command not found.


4x28 = 112 LR6 14*8 |  Step 1: 0.745274E+03 Step  45: 0.731829E+03 | crashed job 20494087 | 112 domain worked in lr5, will it work in lr6 ?  as cmaq_run2  n0052.lr6,n0053.lr6,n0055.lr6,n0057.lr6
		Primary job  terminated normally, but 1 process returned
		a non-zero exit code. Per user-direction, the job has been aborted.
		mpirun noticed that process rank 6 with PID 0 on node n0052.lr6 exited on signal 11 (Segmentation fault).
		Script: ../../com_CCTM_inout.csh


8x16 = 128 LR5 16*8 |  Step 1: 0.551518E+03 Step  66: 0.452921E+03 | crashed ADJ258Sn2_n0026_job_20456849.8x16_lr5.out | n0026.lr5,n0028.lr5,n0038.lr5,n0049.lr5,n0053.lr5,n0055.lr5,n0063.lr5,n0116.lr5.   
		Program received signal SIGSEGV: Segmentation fault - invalid memory reference.
		Primary job  terminated normally, but 1 process returned
		a non-zero exit code. Per user-direction, the job has been aborted.
		mpirun noticed that process rank 122 with PID 11273 on node n0116.lr5 exited on signal 11 (Segmentation fault).
		563272.618u 14551.239s 10:57:05.64 1465.6%      0+0k 5347440+1594312io 319pf+0w
		Script: ../../com_CCTM_inout.csh
		none of the nodes were rebooted, other jobs ran afterward.





~~~~~

crash logs:
4*32 = 128 domains.   ADJ258Sn_n0024_job_20370779.slurm_info  n0024.lr6,n0026.lr6,n0027.lr6,n0028.lr6   completed 3 steps only

diff nodes than above.  likely is the backward simulation problem Ling pointed out.

~~~~

Luster performance

KNL node wrote to 
/global/scratch/tin/adj_kzF_O3_GE66_Popdens_258_20443249


lfs getstripe SARMAP_258_2012_ALL_HYBRID.AL5CHK.nc
SARMAP_258_2012_ALL_HYBRID.AL5CHK.nc
lmm_stripe_count:   1
lmm_stripe_size:    1048576
lmm_pattern:        1
lmm_layout_gen:     0
lmm_stripe_offset:  6
        obdidx           objid           objid           group
             6        68505973      0x4155175                0



diff obdidx means they are on diff ost server (for diff file)
large file may have multiple obdidx number, which means stripping w/in a file.

setstrip command to change stripe char of a file.
multiple file in a dir already stripped to diff OST by default.

time -p dd if=/dev/zero of=dummy.dd bs=1024k count=1024
	viz:       (1.1 GB) copied, 4.54665 s, 236 MB/s
	n0071.cf1: (1.1 GB) copied, 3.97407 s, 270 MB/s  # load of  3, should be idle but load higher than expected.
	n0035.cf1: (1.1 GB) copied, 7.10826 s, 151 MB/s  # load of 64 ran cmaq...  (crashed)
		scancel 20443249, took 52+ in and have the SARMAP_258_2012_ALL_HYBRID.AL5CHK.nc at 28K instead of 14G.
		cf1 not likely good for CMAQ
	n0035.cf1: (1.1 GB) copied, 4.25691 s, 252 MB/s  # after killing cmaq job.  may actually be writing to diff ost anyway.  load avg <1



~~~~~~~~~

perf info prev in /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/CCTM/SARMAP_KZMIN_F_O3/ADJ_RUN/run_CCTM_258_7day.tin*csh



## timing info is printed into the output file when a step is completed, 

## pghuy on lr3, 16 cores, likely asked for 4 nodes: adj_kzF_O3_GE66_Popdens_258_20253866 # maybe out of time by step 29?
## Walltime for backward step     1 (out of   167): 0.228843E+04
## Walltime for backward step    16 (out of   167): 0.360874E+04
## Walltime for backward step    29 (out of   167): 0.321298E+04
## lr3 1 step takes ~38 min, 106 hours, which is why pghuy asked to get longer run time.  16c*4n= 64 threads.


## on lr6, 32cores, 16 nodes, but uptime indicate only 2 nodes in use, cuz just have 64 threads of jobs:
## Walltime for backward step     1 (out of   167): 0.784240E+03
## Walltime for backward step    16 (out of   167): 0.113043E+04
## Walltime for backward step    29 (out of   167): 0.102657E+04
## Walltime for backward step    37 (out of   167): 0.958917E+03
## 2 active nodes on lr6, 32cores, so still 64 threads. step 1 took 13 min
## so maybe 2x-3x faster on lr6?

## but became much slower in lr6 32*24 ??   Eventually cancelled after 3+ hours of no walltime output report

## lr6 32c * 4 nodes.  timing is in seconds, so ~10 min for step 1 in this run, after maybe ~4 min to get 14G SARMAP_258_2012_ALL_HYBRID.AL5CHK.nc in place
## 4 nodes vs 2 LR6 nodes was only just marginally faster than the 2 actual node used in 8/10 run
## Walltime for backward step     1 (out of   167): 0.618170E+03
## Walltime for backward step     2 (out of   167): 0.660169E+03
## if take ~10 min / step, 167 steps would take 28 hours.

## lr6 32c * 8 nodes, try 1: 
## swamped again?  13+ min  SARMAP_258_2012_ALL_HYBRID.AL5CHK.nc still 28k in size.  cancelled.

## lr6 32c * 8 nodes, try 2: 
## seems really no good. 5+ min  SARMAP_258_2012_ALL_HYBRID.AL5CHK.nc still 28k in size.  cancelled.

## lr6 32c * 6 nodes
## maybe when number of cores exceed steps requirement then it is bad performing?
## no, the 167 steps are sequential... not sure if other things limit to 128 threads.  but leave as that for now.

## back to lr6 32c * 4 nodes
## Walltime for backward step     1 (out of   167): 0.480253E+03
## Walltime for backward step     2 (out of   167): 0.501883E+03


# vim:  noexpandtab nosmarttab noautoindent nosmartindent tabstop=4 shiftwidth=4 paste formatoptions-=cro 

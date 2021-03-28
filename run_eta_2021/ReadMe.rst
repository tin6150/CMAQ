dir contain input and script to run Ling's CMAQ workflow
which works in lr3
but tend to crash in lr5 nodes.

resuming testing 2021.03
Yuhan may have found that it was a memory contention issue.


This ReadMe.rst location: /global/scratch/tin/SARMAP/CCTM/SARMAP_209_1LEMIS_35ling3.3_ICv2/ADJ_AVE_FRE_NO2/run_CCTM.tin.csh
backup: /global/scratch/tin/tin-gh/CMAQ/run_eta_2021


~~~~

info on getting inputs:


https://mail.google.com/mail/u/1/?zx=3hzpqh39ltzm#inbox/FMfcgxwLtGlccpgxQbSMlFgkkZwXdGSB
Yuhan: Yes. So if you 
"cd /global/scratch/ljin/SARMAP/CCTM/SARMAP_209_1LEMIS_35ling3.3_ICv2", 
there are 6 new folders with naming convention 
"ADJ_AVE_", 
associated with 6 new adjoint runs. 
Five of the six 
(except "ADJ_AVE_FRE_NO2") 
successfully done with 4core*20 = 80task setting. 

For "ADJ_AVE_FRE_NO2", it is still running with the 5core*16=80task setting. 

There is a "archive" subfolder under 
"ADJ_AVE_FRE_NO2", 
where you can find the iolog, 
run script ( run_CCTM.csh ) 
and slurm of the failed run. Basically, there is nothing changed in the script, except the 
--ncore and --task-per-core parameters. 


~~~~
but which one failed with lr5 run?
i guess most of them would have failed without the extra ram from added node in lr5?

actually, see
https://mail.google.com/mail/u/1/?zx=216yogvn7kzl#search/yuhan/FMfcgxwLtGkSHbvScFnWLMfvFBQRqJGc
/global/scratch/ljin/SARMAP/CCTM/SARMAP_209_1LEMIS_35ling3.3_ICv2/ADJ_AVE_FRE_NO2/slurm-29676739.out: 

so copying ADJ_AVE_FRE_NO2 ~37G
global/scratch/ljin/SARMAP/CCTM/SARMAP_209_1LEMIS_35ling3.3_ICv2 ^**>  cp -pr ADJ_AVE_FRE_NO2 /global/scratch/tin/bench_cmaq 


~~~~
xref: /global/scratch/tin/tin-gh/CMAQ/run_eta 2019 pghuy


~~~~

decided to do similar thing that Yuhan did.
/global/scratch/yuhan_wang/SARMAP_209_S2S has mostly links, except for a handful of dirs.  
so, i am doing:
cd /global/scratch/tin
mkdir SARMAP && cd SARMAP

ln -s /global/scratch/ljin//SARMAP/BCON .
ln -s /global/scratch/ljin//SARMAP/EMISSIONS .
ln -s /global/scratch/ljin//SARMAP/ICON .
ln -s /global/scratch/ljin//SARMAP/JPROC .
ln -s /global/scratch/ljin//SARMAP/MCIP .
ln -s /global/scratch/ljin//SARMAP/OCEAN .
ln -s /global/scratch/ljin//SARMAP/RECEPTORS .
cp -p /global/scratch/ljin/SARMAP/com_global.csh .	# yuhan didn't change this file, probably could be link as well 

# dirs that are not links:
mkdir ADJPOST		# this dir was not a link for Yuhan, but it was empty

mkdir CCTM 
cd    CCTM
cp -pi /global/scratch/ljin/SARMAP/CCTM/com_CCTM.csh .                 # yuhan made not changes to these 3 files
cp -pi /global/scratch/ljin/SARMAP/CCTM/com_CCTM_inout.csh .
cp -pi /global/scratch/ljin/SARMAP/CCTM/lawrencium-modules.csh .
cd ..

mkdir SARMAP_209_1LEMIS_35ling3.3_ICv2
mkdir SARMAP_209_1LEMIS_35ling3.3_ICv2/ADJ_AVE_FRE_NO2
cd    SARMAP_209_1LEMIS_35ling3.3_ICv2/ADJ_AVE_FRE_NO2

## previously did cp  global/scratch/ljin/SARMAP/CCTM/SARMAP_209_1LEMIS_35ling3.3_ICv2/ADJ_AVE_FRE_NO2
## and run_CCTM.tin.csh is there now





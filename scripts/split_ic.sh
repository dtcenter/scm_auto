#!/bin/bash -x
###############################################################
## Abstract:
## 1.Split ICON IC to each grid points and convert to DEPHY format
## 2. Run scm at each grid point in parallel
## 3. Add lat and lon dimension to CCPP SCM output and move to &
## another directory for future concatenate
## CDATE  : current date (YYYYMMDDHH)
## ICON_IC : /full/path/to/ICON/IC
## COMBINE_IC : /full/path/to/combined/IC
## cyc    : current cycle (HH)
## SCRIPTS: /full/path/to/job/scripts
###############################################################

ulimit -u unlimited
ulimit -s unlimited
ulimit -a unlimited
module purge
module use /work2/noaa/gmtb/mumip/scm_build/ccpp-scm-v7/ccpp-scm/scm/etc/modules
module load orion_intel
module load nco
export PATH="/work/noaa/gmtb/xiasun/MU-MIP/tools/gnu_parallel/bin:$PATH"
yyyy=$(echo $CDATE | cut -c1-4)
mm=$(echo $CDATE | cut -c5-6)
dd=$(echo $CDATE | cut -c7-8)
cyc=${cyc:-$(echo $CDATE | cut -c9-10)}

yyyy3=$(echo $CDATE_3 | cut -c1-4)
mm3=$(echo $CDATE_3 | cut -c5-6)
dd3=$(echo $CDATE_3 | cut -c7-8)
cyc3=$(echo $CDATE_3 | cut -c9-10)

yyyy6=$(echo $CDATE_6 | cut -c1-4)
mm6=$(echo $CDATE_6 | cut -c5-6)
dd6=$(echo $CDATE_6 | cut -c7-8)
cyc6=$(echo $CDATE_6 | cut -c9-10)

yyyy9=$(echo $CDATE_9 | cut -c1-4)
mm9=$(echo $CDATE_9 | cut -c5-6)
dd9=$(echo $CDATE_9 | cut -c7-8)
cyc9=$(echo $CDATE_9 | cut -c9-10)

export yyyy
export mm
export dd
export cyc
export yyyy9
export mm9
export dd9
export cyc9

suite1=SCM_RAP
suite2=SCM_GFS_v17_HR3

export suite1
export suite2

minsize=50000

# make dirs for IC
mkdir ${SPLIT_IC}/${mm}_${dd}_${cyc}

split_ic (){
	minsize=50000
	yyyy=$(echo $CDATE | cut -c1-4)
	mm=$(echo $CDATE | cut -c5-6)
	dd=$(echo $CDATE | cut -c7-8)
	cyc=${cyc:-$(echo $CDATE | cut -c9-10)}
	cyc9=$(echo $CDATE_9 | cut -c9-10)
	yyyy9=$(echo $CDATE_9 | cut -c1-4)
	mm9=$(echo $CDATE_9 | cut -c5-6)
	dd9=$(echo $CDATE_9 | cut -c7-8)
	cyc9=$(echo $CDATE_9 | cut -c9-10)

	######## Retrieve IC at lat and lon ##########
	mkdir ${SPLIT_IC}/${mm}_${dd}_${cyc}/lat_$1
	cd ${SPLIT_IC}/${mm}_${dd}_${cyc}/lat_$1
    rm -r mumip_${EXP}_${GRID}_IO_0.2_$yyyy$mm$dd.${cyc}_combined_lat$1_lon$2.nc
    ncks -h -d lat,$1 -d lon,$2 ${COMBINE_IC}/mumip_${EXP}_${GRID}_IO_0.2_$yyyy$mm$dd.${cyc}_combined.nc mumip_${EXP}_${GRID}_IO_0.2_$yyyy$mm$dd.${cyc}_combined_lat$1_lon$2.nc
	ncwa -h -a lon,lat mumip_${EXP}_${GRID}_IO_0.2_$yyyy$mm$dd.${cyc}_combined_lat$1_lon$2.nc -O mumip_${EXP}_${GRID}_IO_0.2_$yyyy$mm$dd.${cyc}_combined_lat$1_lon$2.nc
	###   global attributes   ###
	z0=`ncdump -v z0 mumip_${EXP}_${GRID}_IO_0.2_$yyyy$mm$dd.${cyc}_combined_lat$1_lon$2.nc | tail -n 2 | head -n 1 | cut -d ';' -f 1`
	zorog=`ncdump -v orog mumip_${EXP}_${GRID}_IO_0.2_$yyyy$mm$dd.${cyc}_combined_lat$1_lon$2.nc | tail -n 2 | head -n 1 | cut -d ';' -f 1`
	# zorog=$(($zorog))
	z0=`echo ${z0} | xargs`
	zorog=`echo ${zorog} | xargs`

	ncatted -h -a zorog,global,c,f,0.0 -a z0,global,c,f,0.0 \
	mumip_${EXP}_${GRID}_IO_0.2_$yyyy$mm$dd.${cyc}_combined_lat$1_lon$2.nc -O mumip_${EXP}_${GRID}_IO_0.2_$yyyy$mm$dd.${cyc}_combined_lat$1_lon$2.nc

	
	actsize=`wc -c <"mumip_${EXP}_${GRID}_IO_0.2_$yyyy$mm$dd.${cyc}_combined_lat${1}_lon${2}.nc"`  # check if python work properly
	echo $actsize
	echo $minsize

	if [[ $actsize -lt $minsize ]]; then
    	echo "lat$1 lon$2 Fail"
	else
	 	echo "finish split_ic for lat$1 lon$2"
	fi

 	unset z0
	unset zorog
	unset actsize

 	echo "finish split_ic for $1 $2"

}
export -f split_ic

time parallel -j 40 -u split_ic ::: {0..199} ::: {0..219}


#!/bin/bash -x
###############################################################
## Abstract:
## Combine ICON ic datafiles for a consecutive of 9 hours
## CDATE  : current date (YYYYMMDDHH)
## ICON_IC : /full/path/to/ICON/IC
## COMBINE_IC : /full/path/to/combined/IC
## cyc    : current cycle (HH)
###############################################################
ulimit -u 9000
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

module load nco
cd $ICON_IC
ncrcat mumip_${EXP}_${GRID}_IO.0.2_$yyyy$mm$dd.${cyc}.nc mumip_${EXP}_${GRID}_IO.0.2_$yyyy3$mm3$dd3.${cyc3}.nc mumip_${EXP}_${GRID}_IO.0.2_$yyyy6$mm6$dd6.${cyc6}.nc mumip_${EXP}_${GRID}_IO.0.2_$yyyy9$mm9$dd9.${cyc9}.nc mumip_${EXP}_${GRID}_IO_0.2_$yyyy$mm$dd.${cyc}_${cyc9}_combined.nc 
mv mumip_${EXP}_${GRID}_IO_0.2_$yyyy$mm$dd.${cyc}_${cyc9}_combined.nc ${COMBINE_IC}/mumip_${EXP}_${GRID}_IO_0.2_$yyyy$mm$dd.${cyc}_combined.nc 

cd ${COMBINE_IC}
cp -r ${SCRIPTS}/to_dephy_from_mumip_ufs_combined.bash to_dephy_from_mumip_ufs_combined_$yyyy$mm$dd.${cyc}.bash
chmod u+x to_dephy_from_mumip_ufs_combined_$yyyy$mm$dd.${cyc}.bash
./to_dephy_from_mumip_ufs_combined_$yyyy$mm$dd.${cyc}.bash mumip_${EXP}_${GRID}_IO_0.2_$yyyy$mm$dd.${cyc}_combined.nc $yyyy$mm$dd${cyc}0000 $yyyy9$mm9$dd9${cyc9}0000

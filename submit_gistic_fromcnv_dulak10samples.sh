#!/usr/bin/env bash

#based on freec cnv results
windowsize=1000
if [[ $windowsize -eq 1000 ]]
then
  markerfile=/fh/fast/dai_j/CancerGenomics/Tools/GISTIC/wgs_w1000_markers.txt
fi
if [[ $windowsize -eq 2000 ]]
then
  markerfile=/fh/fast/dai_j/CancerGenomics/Tools/GISTIC/wgs_w2000_markers.txt
fi

echo $markerfile

freecdir=/fh/scratch/delete30/dai_j/freec
wgstumors1=(SRR1001842 SRR1002713 SRR999423 SRR1001466 SRR1002670 SRR1001823 SRR999489 SRR1002343 SRR1002722 SRR1002656 SRR1002929 SRR999438 SRR1001915 SRR999594 SRR1001868 SRR1001635)

for ((i=0;i<3;i++))
do
   if [[ $i -eq 0 ]]
   then
     wgstumors=(SRR1001466 SRR1002670 SRR1001823 SRR999489 SRR1002343 SRR1002722 SRR1002656 SRR1002929 SRR999438 SRR1001915)
   fi
   if [[ $i -eq 1 ]]
   then
     wgstumors=(SRR1001842 SRR1002713 SRR999423 SRR1001466 SRR1002670 SRR1001823 SRR999489 SRR1002343 SRR1002722 SRR1002656)
   fi
   if [[ $i -eq 2 ]]
   then
     wgstumors=(SRR999489 SRR1002343 SRR1002722 SRR1002656 SRR1002929 SRR999438 SRR1001915 SRR999594 SRR1001868 SRR1001635)
   fi
   preface=dulak_ploid2degree3force0_cnv_10samples_$i
   combindfreecsegfile=${preface}.combinedfreecseg.txt
   echo $preface
   echo $combindfreecsegfile
   sleep 10

   echo "combine segs and run gistic"
   cat ${wgstumors[0]}.cnv.freecseg > $combindfreecsegfile
   for ((j=1;j<${#wgstumors[@]};j++))
   do
     cat ${wgstumors[$j]}.cnv.freecseg >> $combindfreecsegfile
   done
   echo "/fh/fast/dai_j/CancerGenomics/Tools/wang/gistic/gistic.sh $preface $combindfreecsegfile $markerfile"
   /fh/fast/dai_j/CancerGenomics/Tools/wang/gistic/gistic.sh $preface $combindfreecsegfile $markerfile
done


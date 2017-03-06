#!/usr/bin/env bash

#based on freec cnv results
windowsize=1000
#data="henan"
data="dulak_henan"
#data="escc"
echo $data
step=2
echo step=$step
#freecdir=/fh/scratch/delete30/dai_j/escc/freec
#wgstumors=("T1" "T2" "T3" "T4" "T5" "T6" "T8" "T9" "T10" "T11" "T12" "T13" "T14" "T15" "T16" "T17" "T18")
##preface=escc_w1000
#preface=escc_ploid2degree3force0

preface=dulak_henan_ploid2degree3force0_cnv
freecdir1=/fh/scratch/delete30/dai_j/freec
wgstumors1=(SRR1001842 SRR1002713 SRR999423 SRR1001466 SRR1002670 SRR1001823 SRR999489 SRR1002343 SRR1002722 SRR1002656 SRR1002929 SRR999438 SRR1001915 SRR999594 SRR1001868 SRR1001635)
freecdir2=/fh/scratch/delete30/dai_j/henan/freec
wgstumors2=("3A" "11A" "13A" "15A" "17A" "25A" "29A" "33A" "37A" "41A")

freecdirs=()
wgstumors=()
for ((i=0;i<${#wgstumors1[@]};i++))
do
  freecdirs[$i]=$freecdir1
  wgstumors[$i]=${wgstumors1[$i]}
done
for ((i=${#wgstumors1[@]};i<${#wgstumors1[@]}+${#wgstumors2[@]};i++))
do
  freecdirs[$i]=$freecdir2
  wgstumors[$i]=${wgstumors2[$i-${#wgstumors1[@]}]}
done 

if [[ $windowsize -eq 1000 ]]
then
  markerfile=/fh/fast/dai_j/CancerGenomics/Tools/GISTIC/wgs_w1000_markers.txt
fi
if [[ $windowsize -eq 2000 ]]
then
  markerfile=/fh/fast/dai_j/CancerGenomics/Tools/GISTIC/wgs_w2000_markers.txt
fi
combindfreecsegfile=${preface}.combinedfreecseg.txt
echo $preface
echo $markerfile
echo $combindfreecsegfile


sleep 10
for ((i=0;i<${#wgstumors[@]};i++))
do
  freecdirs[$i]=${freecdirs[$i]}/${wgstumors[$i]}/ploid2degree3force0
done


if [[ $step -eq 1 ]]
then
  echo "form frecc seg files..."
  for ((i=0;i<${#wgstumors[@]};i++))
  do
    echo "sbatch /fh/fast/dai_j/CancerGenomics/Tools/wang/gistic/form_gistic_fromcnv.R ${freecdirs[$i]} ${wgstumors[$i]} $windowsize"
    sbatch /fh/fast/dai_j/CancerGenomics/Tools/wang/gistic/form_gistic_fromcnv.R ${freecdirs[$i]} ${wgstumors[$i]} $windowsize
    sleep 1
  done
fi


if [[ $step -eq 2 ]]
then
  echo "combine segs and run gistic"
  cat ${wgstumors[0]}.cnv.freecseg > $combindfreecsegfile
  for ((i=1;i<${#wgstumors[@]};i++))
  do
    cat ${wgstumors[$i]}.cnv.freecseg >> $combindfreecsegfile
  done
  echo "/fh/fast/dai_j/CancerGenomics/Tools/wang/gistic/gistic.sh $preface $combindfreecsegfile $markerfile"
  /fh/fast/dai_j/CancerGenomics/Tools/wang/gistic/gistic.sh $preface $combindfreecsegfile $markerfile
fi

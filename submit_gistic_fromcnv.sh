#!/usr/bin/env bash

#based on freec cnv results
windowsize=1000
#data="henan"
data="dulak"
#data="escc"
echo $data
step=2
echo step=$step
if [[ $data == "escc" ]]
then
  freecdir=/fh/scratch/delete30/dai_j/escc/freec
  wgstumors=("T1" "T2" "T3" "T4" "T5" "T6" "T8" "T9" "T10" "T11" "T12" "T13" "T14" "T15" "T16" "T17" "T18")
  #preface=escc_w1000
  preface=escc_ploid2degree3force0
fi
if [[ $data == "henan" ]]
then
  freecdir=/fh/scratch/delete30/dai_j/henan/freec
  wgstumors=("3A" "11A" "13A" "15A" "17A" "25A" "29A" "33A" "37A" "41A")
  #preface=henan_w1000
  preface=henan_ploid2degree3force0
fi

if [[ $data == "dulak" ]]
then
  freecdir=/fh/scratch/delete30/dai_j/freec
  wgstumors=(SRR1001842 SRR1002713 SRR999423 SRR1001466 SRR1002670 SRR1001823 SRR999489 SRR1002343 SRR1002722 SRR1002656 SRR1002929 SRR999438 SRR1001915 SRR999594 SRR1001868 SRR1001635)
  preface=dulak_ploid2degree3force0
fi


preface=${preface}_cnv
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
declare -a freecdirs
freecdirs=()
for ((i=0;i<${#wgstumors[@]};i++))
do
  freecdirs[$i]=$freecdir/${wgstumors[$i]}/ploid2degree3force0
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

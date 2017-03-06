#!/usr/bin/env bash

data="henan"
if [[ $data=="escc" ]]
then
  freecdir=/fh/scratch/delete30/dai_j/escc/freec
  wgstumors=("T1" "T2" "T3" "T4" "T5" "T6" "T8" "T9" "T10" "T11" "T12" "T13" "T14" "T15" "T16" "T17" "T18")
  #preface=escc_w1000
  preface=escc_ploid2degree3force0
fi
if [[ $data=="henan" ]]
then
  freecdir=/fh/scratch/delete30/dai_j/henan/freec
  wgstumors=("3A" "11A" "13A" "15A" "17A" "25A" "29A" "33A" "37A" "41A")
  #preface=henan_w1000
  preface=henan_ploid2degree3force0
fi


markerfile=${preface}_markers.txt
combindfreecesegfile=${preface}.combinedfreecseg.txt
declare -a freecfiles
declare -a freecprocessedfiles
declare -a freecsegfiles
for ((i=0;i<${#wgstumors[@]};i++))
do
  #freecfiles[$i]=$freecdir/${wgstumors[$i]}/w1000/${wgstumors[$i]}.pileup.gz_ratio.txt
  freecfiles[$i]=$freecdir/${wgstumors[$i]}/ploid2degree3force0/${wgstumors[$i]}.pileup.gz_ratio.txt
  freecprocessedfiles[$i]=${preface}_${wgstumors[$i]}.pileup.gz_ratio.processed.txt
  freecsegfiles[$i]=${preface}_${wgstumors[$i]}.pileup.gz_ratio.processed.freecseg.txt
done

step=4
if [[ $step -eq 1 ]]
then
  echo "process freecfile"
  for ((i=0;i<${#wgstumors[@]};i++))
  do
    echo "sbatch /fh/fast/dai_j/CancerGenomics/Tools/wang/gistic/process_segdata.R ${freecfiles[$i]} ${freecprocessedfiles[$i]}"
    /fh/fast/dai_j/CancerGenomics/Tools/wang/gistic/process_segdata.R ${freecfiles[$i]} ${freecprocessedfiles[$i]}
    sleep 1
  done
fi

if [[ $step -eq 2 ]]
then
  echo "generate markerfile"
  /fh/fast/dai_j/CancerGenomics/Tools/wang/gistic/form_gisticmarkers.R ${freecprocessedfiles[0]} $markerfile
fi

if [[ $step -eq 3 ]]
then
  echo "generate freec segs"
  for ((i=0;i<${#wgstumors[@]};i++))
  do
    echo "sbatch /fh/fast/dai_j/CancerGenomics/Tools/wang/gistic/form_gisticsegs.R ${freecprocessedfiles[$i]} ${wgstumors[$i]} ${freecsegfiles[$i]}"
    sbatch /fh/fast/dai_j/CancerGenomics/Tools/wang/gistic/form_gisticsegs.R ${freecprocessedfiles[$i]} ${wgstumors[$i]} ${freecsegfiles[$i]}
    sleep 1
  done
fi

if [[ $step -eq 4 ]]
then
  echo "combine segs and run gistic"
  /fh/fast/dai_j/CancerGenomics/Tools/wang/gistic/form_combinedfreecseg.R $combindfreecesegfile ${freecsegfiles[@]}
  echo "/fh/fast/dai_j/CancerGenomics/Tools/wang/gistic/gistic.sh $preface $combindfreecesegfile $markerfile"
  /fh/fast/dai_j/CancerGenomics/Tools/wang/gistic/gistic.sh $preface $combindfreecesegfile $markerfile
fi



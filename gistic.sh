#!/usr/bin/env bash


gisticdir=/fh/fast/dai_j/CancerGenomics/Tools/GISTIC
cnvfile=/fh/fast/dai_j/CancerGenomics/Tools/GISTIC/examplefiles/SNP6.merged.151117.hg19.CNV.txt

preface=${1?"preface of outputfolder"}
segfile=${2?"combindedfreecsegfile"}
markersfile=${3?"markerfile"}

maxseg=5000
conf=0.95

for rx in {0,1}
	do
	#for armpeel in {0,1}
        for armpeel in 0
	do
		#for brlen in {0.7,0.98}
                for brlen in 0.98 
		do
			broad=1			
			#for broad in {0,1}
			#do
				sbatch $gisticdir/gistic_example.sh $rx $maxseg $conf $armpeel $brlen $broad $preface $segfile $markersfile $cnvfile
				sleep 1
			#done
		done
	done
done





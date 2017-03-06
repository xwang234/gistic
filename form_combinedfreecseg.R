#! /usr/bin/env Rscript
# setwd('/fh/scratch/delete30/dai_j/freec/GISTIC')
# 
# wessrrfile='/fh/fast/dai_j/CancerGenomics/EAC/Exome/Dulak/Dulak_exomeinfo.txt'
# wessrr=read.table(wessrrfile,header=T)
# wessrr[,1]=as.character(wessrr[,1])
# wessrr[,4]=as.character(wessrr[,4])
# wesnormals=wessrr[,1]
# westumors=wessrr[,4]
# res=data.frame(matrix(NA,nrow=0,ncol=6))
# 
# for (i in 1:length(westumors))
# {
#   tumorname=westumors[i]
#   filename=paste0(tumorname,'.freecseg.txt')
#   segtable=read.table(filename,header=TRUE,sep="\t")
#   res=rbind(res,segtable)
# }
# write.table(res,file='combined.freecseg.txt',sep="\t",quote=FALSE,col.names=FALSE,row.names=FALSE)


#for wgs:
args <- commandArgs(trailingOnly = TRUE)
output=as.character(args[1])
gisticsegfiles=c()
print(output)

for (i in 2:length(args))
{
  gisticsegfiles[i-1]=as.character(args[i])
}

print(gisticsegfiles)

res=data.frame(matrix(NA,nrow=0,ncol=6))
for (i in 1:length(gisticsegfiles))
{
  segtable=read.table(gisticsegfiles[i],header=TRUE,sep="\t")
  res=rbind(res,segtable)
}

write.table(res,file=output,sep="\t",quote=FALSE,col.names=FALSE,row.names=FALSE)

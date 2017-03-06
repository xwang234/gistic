#! /usr/bin/env Rscript
#used to form marker file to run GISTIC

# setwd('/fh/scratch/delete30/dai_j/freec/GISTIC')
# wessrrfile='/fh/fast/dai_j/CancerGenomics/EAC/Exome/Dulak/Dulak_exomeinfo.txt'
# wessrr=read.table(wessrrfile,header=T)
# wessrr[,1]=as.character(wessrr[,1])
# wessrr[,4]=as.character(wessrr[,4])
# wesnormals=wessrr[,1]
# westumors=wessrr[,4]
# normalname=wesnormals[1]
# tumorname=westumors[1]
# freecdir='/fh/scratch/delete30/dai_j/freec/wes'
# gz_ratio_cmds_file=paste0(freecdir,'/',normalname,'/',tumorname,'.pileup.gz_ratio.cmds.txt')
# 
# extable=read.table(gz_ratio_cmds_file,header=T)
# extable[,1]=as.character(extable[,1])
# res=data.frame(matrix(NA,nrow=nrow(extable),ncol=3))
# colnames(res)=c('unitName','chromosome','position')
# res[,1]=paste0(extable[,1],extable[,2])
# res[,2:3]=extable[,1:2]
# if (grepl('chr',res[1,2]))
# {
#   res[,2]=gsub('chr','',res[,2])
# }
# output='freecwes.markers.txt'
# write.table(res,file=output,row.names=F,col.names=T,sep="\t",quote=F)

#for wgs:
args <- commandArgs(trailingOnly = TRUE)
gz_ratio_cmds_file=as.character(args[1])
output=as.character(args[2])

#gz_ratio_cmds_file=paste0(freecdir,'/',tumorname,'/',tumorname,'.pileup.gz_ratio.cmds.txt')
extable=read.table(gz_ratio_cmds_file,header=T)
extable[,1]=as.character(extable[,1])
res=data.frame(matrix(NA,nrow=nrow(extable),ncol=3))
colnames(res)=c('unitName','chromosome','position')
res[,1]=paste0(extable[,1],extable[,2])
res[,2:3]=extable[,1:2]
if (grepl('chr',res[1,2]))
{
  res[,2]=gsub('chr','',res[,2])
}
#output='henanfreec.markers.txt'
#output='henanfreecw2000.markers.txt'

write.table(res,file=output,row.names=F,col.names=T,sep="\t",quote=F)

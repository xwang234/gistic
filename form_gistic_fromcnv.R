#!/usr/bin/env Rscript
#SBATCH -t 0-1
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=xwang234@fhcrc.org

args <- commandArgs(trailingOnly = TRUE)
freecdir=as.character(args[1])
tumorname=as.character(args[2])
windowsize=as.integer(args[3]) #stepsize=1000
output=paste0(tumorname,".cnv.freecseg")
print(freecdir)
print(tumorname)
print(windowsize)
#freecdir="/fh/scratch/delete30/dai_j/henan/freec/3A/ploid2degree3force0"
#tumorname="3A"
library(GenomicRanges)
cnvtable=read.table(file=paste0(freecdir,"/",tumorname,".pileup.gz_CNVs"),header=F,sep="\t",quote="",stringsAsFactors=F,fill=T)
#somatictable=cnvtable[cnvtable[,5] !="normal" & cnvtable[,8]=="somatic",]
somatictable=cnvtable
ratiotable=read.table(file=paste0(freecdir,"/",tumorname,".pileup.gz_ratio.txt"),header=T,sep="\t",quote="",stringsAsFactors=F,fill=T)
ratiotable=ratiotable[ratiotable$Ratio != -1 & ratiotable$MedianRatio != -1, ]
gr_ratio=GRanges(seqnames=ratiotable[,1],ranges=IRanges(start=ratiotable[,2],width=windowsize),medratio=ratiotable[,4])
res=data.frame(matrix(NA,nrow=nrow(somatictable),ncol=6))
res[,1]=tumorname
res[,2]=somatictable[,1]
res[,3]=ceiling(somatictable[,2]/1000)*1000+1
#res[,4]=ceiling(somatictable[,3]/1000)*1000+1
#colnames: tumorname,start,end,numofpobes,ratio
for (i in 1:nrow(somatictable))
{
  if ((somatictable[i,4]-999) %% 1000 !=0 ) #reach end of chromosome
  {
    res[i,4]=as.integer(somatictable[i,3]/1000)*1000+1
  }else
  {
    res[i,4]=ceiling(somatictable[,3]/1000)*1000+1
  }
  res[i,5]=as.integer((res[i,4]-res[i,3])/windowsize)
  gr_cnv=GRanges(seqnames=res[i,2],ranges=IRanges(start=res[i,3],end=res[i,4]))
  olap=subsetByOverlaps(gr_ratio,gr_cnv)
  cnratio=mean(mcols(olap)$medratio)
  res[i,6]=log2(2*cnratio)-1
  
}
res=res[res[,5]>0,]
#remove overlaps
res1=res
oldseg=GRanges(seqnames=res[1,2],ranges=IRanges(start=res[1,3],end=res[1,4]))
for (i in 2:nrow(res))
{
  nowseg=GRanges(seqnames=res[i,2],ranges=IRanges(start=res[i,3],end=res[i,4]))
  olap=subsetByOverlaps(oldseg,nowseg)
  
  if (length(olap)>0)
  {
    res1[i,3]=res[i-1,4]
    res1[i,5]=as.integer((res1[i,4]-res1[i,3])/windowsize)
  }
  oldseg=nowseg
}
res1=res1[res1[,5]>0,]

#add gaps ratio as 1
res2=NULL
res2=rbind.data.frame(res2,res1[1,])
oldchromosome=res1[1,2]
for (i in 2:nrow(res1))
{
  newchromosome=res1[i,2]
  if (res1[i,3]>res2[nrow(res2),4] & oldchromosome==newchromosome)
  {
    tmpchr=res1[i,2]
    tmpstart=as.integer(res2[nrow(res2),4])
    tmpend=as.integer(res1[i,3])
    tmpnumseg=as.integer((tmpend-tmpstart)/windowsize)
    tmpsegcn=0
    tmp=data.frame(matrix(c(tumorname,tmpchr,tmpstart,tmpend,tmpnumseg,tmpsegcn),nrow=1))
    res2=rbind.data.frame(res2,tmp)
    res2=rbind.data.frame(res2,res1[i,])
  }else
  {
    res2=rbind.data.frame(res2,res1[i,])
  }
  oldchromosome=newchromosome
}

write.table(res2,output,row.names=F,col.names =F,sep="\t",quote=F)

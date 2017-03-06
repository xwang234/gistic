#!/usr/bin/env Rscript
#SBATCH -t 0-1
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=xwang234@fhcrc.org
#modified from g_freecdata1.R

args <- commandArgs(trailingOnly = TRUE)
freecfile=as.character(args[1]) #.pileup.gz_ratio.txt
output=as.character(args[2]) #pileup.gz_ratio.processed.txt
print(freecfile)

readsegtable=function(segfile)
{
  #colcr=3:ratio,4:medianratio
  segtable=read.table(segfile,header=T)
  windowsize=segtable[2,2]-segtable[1,2]
  res=data.frame(matrix(NA,nrow=nrow(segtable),ncol=5))
  colnames(res)=c('chr','start','end','segcopyratio','rawcopyratio')
  segtable[,1]=as.character(segtable[,1])
  if (!grepl('chr',segtable[1,1]))
  {
    segtable[,1]=paste0('chr',segtable[,1])
  }
  res[,1:2]=segtable[,1:2]
  res[,3]=segtable[,2]+windowsize-1
  res[,4]=segtable[,4]
  res[,5]=segtable[,3]
  res[res[,4]<0,4]=NA
  res[res[,5]<0,5]=NA
  #normalization
  #meancr4=mean(res[,4],na.rm=T)
  #meancr5=mean(res[,5],na.rm=T)
  #res[,4]=res[,4]+(1-meancr4)
  #res[,5]=res[,5]+(1-meancr5)
  chrs=c(1:22,'X',"Y")
  chrs=paste0('chr',chrs)
  res1=c()
  for (i in 1:length(chrs)) #sort table
  {
    chr=chrs[i]
    tmpseg=res[res[,1]==chr,]
    if (nrow(tmpseg)>0)
    {
      tmpidx=order(tmpseg[,2])
      res1=rbind(res1,tmpseg[tmpidx,])
    }
  }
  if (nrow(res1)>0) rownames(res1)=1:nrow(res1)
  res=res1
  return(res)
}

res=readsegtable(freecfile)
write.table(res,file=output,col.names=TRUE,row.names=FALSE,quote=FALSE,sep="\t")

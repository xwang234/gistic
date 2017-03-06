#!/usr/bin/env Rscript
#SBATCH -t 0-3
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=xwang234@fhcrc.org

args <- commandArgs(trailingOnly = TRUE)
freecfile=as.character(args[1])
numpair=as.integer(args[1])

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
#wessrrfile='/fh/fast/dai_j/CancerGenomics/EAC/Exome/Dulak/Dulak_exomeinfo.txt'
#wessrr=read.table(wessrrfile,header=T)
#wessrr[,1]=as.character(wessrr[,1])
#wessrr[,4]=as.character(wessrr[,4])
#normals=c('2A','4A','6A','8A','10A','12A')
#tumors=c('1A','3A','5A','7A','9A','11A')
tumors=c(3,11,13,15,17,25,29,33,37,41)
normals=tumors+1
normals=paste0(normals,"A")
tumors=paste0(tumors,"A")

freecfromdir='/fh/scratch/delete30/dai_j/henan/freec'
templatenormal=normals[1]
templatetumor=tumors[1]
#templatefile=paste0(freecfromdir,'/',templatenormal,'/ploid2degree3force0/',templatetumor,'.pileup.gz_ratio.txt')
#templatefile=paste0(freecfromdir,'/',templatenormal,'/w2000/',templatetumor,'.pileup.gz_ratio.txt')
templatefile=paste0(freecfromdir,'/',templatetumor,'/',templatetumor,'.pileup.gz_ratio.txt')
templatetable=readsegtable(templatefile)
if (numpair==1)
{
  normalsample=templatenormal
  tumorsample=templatetumor
  res=templatetable
}else
{
  res=data.frame(matrix(NA,nrow=nrow(templatetable),ncol=ncol(templatetable)))
  colnames(res)=colnames(templatetable)
  res[,1:3]=templatetable[,1:3]
  normalsample=normals[numpair]
  tumorsample=tumors[numpair]
  #freecfile=paste0(freecfromdir,'/',normalsample,'/ploid2degree3force0/',tumorsample,'.pileup.gz_ratio.txt')
  #freecfile=paste0(freecfromdir,'/',normalsample,'/w2000/',tumorsample,'.pileup.gz_ratio.txt')
  freecfile=paste0(freecfromdir,'/',tumorsample,'/',tumorsample,'.pileup.gz_ratio.txt')
  dif=0
  if (dif==0)
  {
    res=readsegtable(freecfile)
  }else
  {
    #the following works for the case if different samples have different region configurations
    rawtable=readsegtable(freecfile)
    chrtable=rawtable[rawtable[,1]=='chr1',]
    oldchr='chr1'
    for (i in 1:nrow(templatetable))
    {
      chr=templatetable[i,1]
      if (chr !=oldchr)
      {
        chrtable=rawtable[rawtable[,1]==chr,]
        oldchr=chr
      }
      start=templatetable[i,2]
      idx=which(chrtable[,2]==start)
      if (length(idx)>0)
      {
        res[i,4:5]=chrtable[idx,4:5]
      }else
      {
        res[i,4:5]=NA
      }
    }
  }
}

#output=paste0(freecfromdir,'/',normalsample,'/ploid2degree3force0/',tumorsample,'.pileup.gz_ratio.cmds.txt')
#output=paste0(freecfromdir,'/',normalsample,'/w2000/',tumorsample,'.pileup.gz_ratio.cmds.txt')
output=paste0(freecfromdir,'/',tumorsample,'/',tumorsample,'.pileup.gz_ratio.cmds.txt')
write.table(res,file=output,col.names=TRUE,row.names=FALSE,quote=FALSE,sep="\t")

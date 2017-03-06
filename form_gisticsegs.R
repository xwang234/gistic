#! /usr/bin/env Rscript
#SBATCH -t 0-1
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=xwang234@fhcrc.org

#run process-segdata.R before this
#form the segment file for GISTIC
args <- commandArgs(trailingOnly = TRUE)
processedfile=as.character(args[1]) #.pileup.gz_ratio.processed.txt
tumorname=as.character(args[2])
output=as.character(args[3]) #freecsegw

print(processedfile)
rawtable=read.table(processedfile,header=T)
idxNA=!is.na(rawtable[,4]) & rawtable[,4]<=0
rawtable[idxNA,4]=NA
rawtable[,1]=as.character(rawtable[,1])
idx_start_end=matrix(0,ncol=2,nrow=nrow(rawtable))
oldchr=rawtable[1,1]
oldr=rawtable[1,4]
n=1
idx_start_end[1,1]=1
for (i in 2:nrow(rawtable))
{
  chr=rawtable[i,1]
  r=rawtable[i,4]
  if (chr!=oldchr)
  {
    oldchr=chr
    oldr=r
    if (!is.na(r))
      idx_start_end[n,1]=i
    #idx_start_end[n,2]=i-1
    #n=n+1
    #idx_start_end[n,1]=i
  }
  if (is.na(oldr))
  {
    if (! is.na(r)) idx_start_end[n,1]=i
    oldr=r
    oldchr=chr
  }else
  {
    if ((chr!=oldchr | r!=oldr) & !is.na(r))
    {
      oldchr=chr
      oldr=r
      idx_start_end[n,2]=i-1
      n=n+1
      idx_start_end[n,1]=i
    }
    if (is.na(r)) ##Number+(NA)
    {
      oldr=r
      oldchr=chr
      idx_start_end[n,2]=i-1
      n=n+1
    }
  }
}
if (is.na(r)) 
  {
    idx_start_end=idx_start_end[1:(n-1),]
}else
{
  idx_start_end[n,2]=nrow(rawtable)
  idx_start_end=idx_start_end[1:n,]
}

res=data.frame(matrix(NA,ncol=6,nrow=nrow(idx_start_end)))
colnames(res)=c('ID','chrom','loc.start','loc.end','num.mark','seg.mean')
res[,1]=tumorname
for (i in 1:nrow(idx_start_end))
{
  start=idx_start_end[i,1]
  end=idx_start_end[i,2]
  chr=rawtable[start,1]
  if (grepl('chr',chr))
    chr=gsub('chr','',chr)
  locstart=rawtable[start,2]
  locend=rawtable[end,2]
  nummark=end-start+1
  segmean=rawtable[start,4]
  if (is.na(segmean))
    segmean=rawtable[end,4]
  if (segmean==0) segmean=1e-5
  segmean=log2(segmean)
  res[i,2:6]=c(chr,locstart,locend,nummark,segmean)
}
idxNA=is.na(res[,6])
res=res[!idxNA,]
write.table(res,file=output,row.names=F,col.names=T,sep="\t", quote=F)

#!/usr/bin/env Rscript

#Takes as input a rate parameter csv file where the columns are
#Gene name, codon position, alpha parameter, A->C, A->G, A->T, C->G, C->T, and G->T transition
#parameters, and clusters the codon positions into 8 partitions
cluster<-function(rate_parameter_file,output_file) {
  data<-read.csv(rate_parameter_file,sep=",");
  data$codon<-factor(data$codon,levels=c(1,2))
  pcaf<-princomp(scale(data[,c('alpha','ac','ag','at','cg','ct')]))
  pca<-data.frame(pcaf$scores[,c(1,2)])    
  pca$codon<-data$codon    

  res<-kmeans(pcaf$scores[,c(1,2)],8,nstart=25)
  df<-data.frame(data$gene,data$codon,res$cluster)
  names(df)<-c('gene','codon','class')
  write.csv(df,file=output_file,quote = F,row.names = F)
}
args = commandArgs(trailingOnly=TRUE)
cluster(args[1], args[2])
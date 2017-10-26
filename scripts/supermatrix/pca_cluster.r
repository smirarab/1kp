#!/usr/bin/env Rscript

#Takes as input a rate parameter csv file where the columns are
#Gene name, codon position, alpha parameter, A->C, A->G, A->T, C->G, C->T, and G->T transition
#parameters
histogram<-function(rate_parameter_file,output_file) {
  data<-read.csv(rate_parameter_file,sep=",",header=F);
  names(data)<-c('gene','codon','alpha','ac','ag','at','cg','ct','gt')
  data$codon<-factor(data$codon,levels=c(1,2,3))
  pcaf<-princomp(scale(data[,c('alpha','ac','ag','at','cg','ct')]))
  pca<-data.frame(pcaf$scores[,c(1,2)])    
  pca$codon<-data$codon    


  res<-kmeans(pcaf$scores[,c(1,2)],8,nstart=25)
  df<-data.frame(data$gene,data$codon,res$cluster)
  names(df)<-c('gene','codon','class')
  write.csv(df,file=output_file,quote = F,row.names = F)
}

histogram(args[1], args[2])
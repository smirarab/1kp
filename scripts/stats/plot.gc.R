require(ggplot2)
require(reshape2)

f = read.csv("gc.stat",sep=" ")
fall=f[,c(1,2,3,4,9,10,11,12)]
fall$GC<-fall[,6]+fall[,7]
fdall = melt(fall,id=c("DATASET","GENE","SEQUENCE","TAXON"))
levels(fdall$variable)<-c("A","C","G","T","GC")

pdf("allgenes_nucfreq.pdf")
qplot(variable,value,data=fdall,geom="boxplot", color=variable)+facet_grid(DATASET~., scales = "free")
dev.off()

pdf("pT_ACGT_point.pdf",width=16,height=8)
qplot(reorder(SEQUENCE,value),value,data=fdall,geom="point",stat="summary", fun.y = "mean", color=variable,xlab="")+ opts(axis.text.x = theme_text(angle = 90))+facet_grid(DATASET~., scales = "free")
dev.off()


fcg=melt(fall[,c(1,2,3,4,9)],id=c("DATASET","GENE","SEQUENCE","TAXON"))
fcg<-f[,c(1,2,3,4)]
fcg$ALL<-f[,10]+f[,11]
fcg$C1<-f[,18]+f[,19]
fcg$C2<-f[,26]+f[,27]
fcg$C3<-f[,34]+f[,35]
fcg=melt(fcg,id=c("DATASET","GENE","SEQUENCE","TAXON"))


#pdf("pGpP_CG_box.pdf",width=16,height=8)
#qplot(variable,value,data=fcg,geom="boxplot",color=variable,ylab="CG Content",outlier.size=0.2)+
#		facet_wrap(~GENE, ncol=25)+ 
#		opts(axis.ticks = theme_blank(), axis.text.x = theme_blank(),axis.title.x = theme_blank(),
#				strip.text.x = theme_text(angle=90))
#dev.off()

pdf("perposition_GC_content.pdf",width=16,height=8)
qplot(variable,value,data=fcg,geom="boxplot", color=variable,ylab="GC Content")		
dev.off()

pdf("pTpP_GC_point.pdf",width=24,height=8)
qplot(reorder(SEQUENCE,value),value,data=fcg,geom="point",stat="summary", fun.y = "mean", color=variable,xlab="")+ opts(axis.text.x = theme_text(angle = 90))+facet_grid(DATASET~., scales = "free")+theme_classic()
dev.off()

pdf("pTpP_GC_box.pdf",width=24,height=12)
qplot(reorder(SEQUENCE,value),value,data=fcg,geom="boxplot",xlab="",ylab="GC content",outlier.size=0.4)+ opts(axis.text.x = theme_text(angle = 90))+facet_grid(variable~., scales = "free")+theme_classic()
dev.off()

quit()


pdf("pTpP_p_stddev_box.pdf",width=25,height=10); ggplot(aes(x=reorder(SEQUENCE,value),y=value),data=fcg)+stat_summary(fun.data=mean_sdl,size=.1)+xlab("")+ylab("GC content")+ theme_classic() + theme(axis.text.x = element_text(angle=90,size=1.5))+facet_grid(variable~., scales = "free")+scale_x_discrete(labels=function(x) which(levels(reorder(fcg$SEQUENCE,fcg$value))==x)); dev.off()

pdf("pTpP_GC_box.pdf",width=25,height=10); qplot(reorder(SEQUENCE,value),value,data=fcg,geom="boxplot",xlab="",ylab="GC content",outlier.size=0.4,outlier.alpha=0.1,coef=3)+ theme_classic() + theme(axis.text.x = element_text(angle=90,size=1.5))+facet_grid(variable~., scales = "free")+scale_x_discrete(labels=function(x) which(levels(reorder(fcg$SEQUENCE,fcg$value))==x)); dev.off()

write.csv(file="names.csv",levels(reorder(fcg$SEQUENCE,fcg$value)))


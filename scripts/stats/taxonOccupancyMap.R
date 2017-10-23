require(ggplot2)
require(reshape)
require(plyr)

oc <- read.csv('occupancy',header=T,sep=' ')
if (length(names(oc)) == 4) {
	oc <- cast(oc,GENE_ID+Taxon~.,fun.aggregate=sum,value="Len")
}
names(oc) <- c("ID","Taxon", "Len")
oc$ID<-paste(oc$ID,"",sep="")

ocs <- ddply(oc, .(ID), transform, rescale= scale(Len,center=F))
ocs$Taxon <- with(ocs, reorder(Taxon, Len, FUN = function(x) {return(length(which(x>0)))}))
ocs$ID <- with(ocs, reorder(ID, Len,FUN = length))

png("taxon.occupancy.heatmap.2.png", width=12000, height=6000,res=600)
ggplot(ocs2, aes(taxa,ID)) + geom_tile(aes(fill = rescale),colour = "white",size=0,linetype=0) + scale_fill_gradient(low = "white",high = "black")+scale_x_discrete(expand = c(0, 0)) +scale_y_discrete(expand = c(0, 0) )+theme(legend.position = "none",axis.ticks = element_blank(),axis.text.x = element_text(size=2,angle = 90, hjust = 0, colour = "grey50"),axis.text.y = element_text(size=2,colour = "grey50"))
dev.off()

pdf("taxon-ooc.pdf",width=1760, height=980)
ggplot(ocs2, aes(taxa,ID)) + geom_tile(aes(fill = rescale),colour = "white",size=0,linetype=0) + scale_fill_gradient(low = "white",high = "black")+scale_x_discrete(expand = c(0, 0)) +scale_y_discrete(expand = c(0, 0) )+theme(legend.position = "none",axis.ticks = element_blank(),axis.text.x = element_text(size=4,angle = 90, hjust = 0, colour = "grey50"),axis.text.y = element_text(size=3,colour = "grey50"))
dev.off()

png("taxon.occupancy.heatmap.png", width=1760, height=680,res=125)
ggplot(ocs2, aes(classification,ID)) + geom_tile(aes(fill = rescale),colour = "white",size=0,linetype=0) + scale_fill_gradient(low = "white",high = "black")+scale_x_discrete(expand = c(0, 0)) +scale_y_discrete(expand = c(0, 0) )+theme(legend.position = "none",axis.ticks = element_blank(),axis.text.x = element_text(size=4,angle = 90, hjust = 0, colour = "grey50"),axis.text.y = element_text(size=3,colour = "grey50"))
dev.off()

png("taxon.occupancy.heatmap.2.png", 
		width=1760,
		height=1680,res=125)

ggplot(ocs, aes(ID,Taxon)) + geom_tile(aes(fill = rescale),colour = "white") + 
		scale_fill_gradient(low = "white",high = "darkgreen")+
		scale_x_discrete(expand = c(0, 0)) +
		scale_y_discrete(expand = c(0, 0) )+
		theme(legend.position = "none",axis.ticks = element_blank(),
				axis.text.x = element_text(size=4,angle = 90, hjust = 0, colour = "grey50"))

dev.off()

png("taxon.occupancy.heatmap.png", 
		width=6*length(levels(ocs$ID))+220,
		height=10*length(levels(ocs$Taxon))+200,res=125)

ggplot(ocs, aes(ID,Taxon)) + geom_tile(aes(fill = rescale),colour = "white") + 
		scale_fill_gradient(low = "white",high = "steelblue")+
		scale_x_discrete(expand = c(0, 0)) +
		scale_y_discrete(expand = c(0, 0)) +
		theme(legend.position = "none",axis.ticks = element_blank(),
				axis.text.x = element_text(size=4,angle = 90, hjust = 0, colour = "grey50"))

dev.off()

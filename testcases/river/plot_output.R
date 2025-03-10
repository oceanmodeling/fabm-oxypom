# SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

library(ncdf4)
library(scales)

conv.fact = 12
is.oxypom_ = T

setwd('/home/og/tools/dobgcp/testcases/river/')

par(las=1,family='carlito')

nc_data = nc_open('output.nc')

Get.Year = function(...) format(as.Date(..., format="%d/%m/%Y"),"%Y")

plot.contour  = function(my.data,title=NA,cs='Vir',.rev=F,norm=F){
  x = 1:length(my.data[,1])
  y = 1:length(my.data[1,])
  xrange=range(x)
  n=0
  xrange=c(n*365,(n+1)*366)
  
  plot(1,type='n',xlim=xrange,ylim=c(0,max(y)),
       xlab='month',
       ylab='depth, m',
       yaxt='n',xaxt='n', 
       main='')
  title(main=title,adj=0)
  axis(side=2,at=c(0,0.5,1)*max(y),label=abs(c(0,150,300)-300),las=1)
  axis.Date(side=1,at=as.Date(paste0('1970-',1:12,'-01')),labels = NA)
  axis.Date(side=1,at=as.Date(paste0('1971-',1:12,'-01')),labels = NA)
  
  the.levels=pretty(my.data,n=200)
  if(norm) the.levels = seq(0,1,length.out=200)
  my.cols= hcl.colors((length(the.levels)-1), cs, rev = .rev)
  #my.cols = cmocean(cs)(length(the.levels)-1)
  #if(.rev) my.cols = rev(my.cols)
  #.filled.contour(-0.5+x,-0.5+y,my.data,levels=the.levels,col=my.cols)
  image(-0.5+x,-0.5+y,my.data,col=my.cols,add=T,use.raster=T)
}

####################

temp.w.1 = read.delim("./data/FGG_Elbe_012!Wassertemperatur.txt", header=FALSE, comment.char="#")
temp.w.2 = read.delim("./data/FGG_Elbe_013!Wassertemperatur.txt", header=FALSE, comment.char="#")

temp.w.1$V1 = as.POSIXct(temp.w.1$V1)
temp.w.2$V1 = as.POSIXct(temp.w.2$V1)

temp.w.1 = subset(temp.w.1, Get.Year(V1)>=2004)
temp.w.2 = subset(temp.w.2, Get.Year(V1)>=2004)

oxy.w.1 = read.delim("./data/FGG_Elbe_012!Sauerstoffgehalt_(Einzelmessung).txt", header=FALSE, comment.char="#")
oxy.w.2 = read.delim("./data/FGG_Elbe_013!Sauerstoffgehalt_(Einzelmessung).txt", header=FALSE, comment.char="#")

oxy.w.1$V1 = as.POSIXct(oxy.w.1$V1)
oxy.w.2$V1 = as.POSIXct(oxy.w.2$V1)

oxy.w.1 = subset(oxy.w.1, Get.Year(V1)>=2004)
oxy.w.2 = subset(oxy.w.2, Get.Year(V1)>=2004)

###############



par(mfrow=c(2,2))
if(F) for(i in 1:nc_data$nvars){
  v1 = nc_data$var[[i]]
  data1 = ncvar_get(nc_data, v1)	# by default, reads ALL the data
  print(paste("Data for var ",v1$name,":",sep=""))
  if(substr(v1$name, start = 1, stop = 2)!='nn') next
  nn =  t(ncvar_get(nc_data, v1$name))
  plot.contour(nn,title=v1$name,cs='thermal')
}


#ncvar_get(nc_data, "h")


#stop-here
salt =  t(ncvar_get(nc_data, "salt"))
temp =  t(ncvar_get(nc_data, "temp"))

if(is.oxypom_){
  nut =  t(ncvar_get(nc_data, "oxypom_PO4"))
  phy =  t(ncvar_get(nc_data, "oxypom_ALG2"))
  zoo =  t(ncvar_get(nc_data, "oxypom_DOC"))
  det =  t(ncvar_get(nc_data, "oxypom_POC1"))
  par =  t(ncvar_get(nc_data, "oxypom_PAR"))
  oxy =  t(ncvar_get(nc_data, "oxypom_DOxy"))
}else{
  phy =  t(ncvar_get(nc_data, "diamo_PHY"))
  det =  t(ncvar_get(nc_data, "diamo_DET"))
  par =  t(ncvar_get(nc_data, "diamo_PAR"))
  oxy =  t(ncvar_get(nc_data, "diamo_OXY"))
}


if(T){
  par(mfrow=c(2,3),mai=c(0.2,0.2,0.1,0.1),oma=2*c(1,1,0.5,0.5))
  plot.contour(temp,title='Temperature ()',cs='plasma')
  plot.contour(par,title='PAR',cs='turku')
  #plot.contour(log10(nut),title='Nutrient',cs='dense',.rev=T)
  plot.contour((phy),title='Phytoplankton',cs='DarkMint',.rev=T)
  #plot.contour(zoo,title = 'Zooplankton',cs='matter',.rev=F)
  plot.contour((det),title = 'Detritus',cs='Lajolla')
  plot.contour(oxy,title = 'Oxygen',cs='RdBu')
  plot.contour(salt,title = 'salinity',cs='viridis')
  
}

x = 1:length(temp[,1])#%%12+1
x = as.Date(x,origin='2006-01-01')

surface=length(par[1,])-1
bottom = 1

col.sim='tomato'
col.obs='black'
col.obs2='darkblue'

par(mfrow=c(2,1),mai=c(0.42,0.42,0.21,0.21),oma=2*c(1,1,0.5,0.5))

plot(x,rowMeans(temp[,bottom:surface]),type='n',
     col=alpha(col.obs,0.5),ylim=c(-5,25),log='',lwd=0.5,
     ylab='',
     xlab='days'
)
title('temperature at the surface degC',adj=0,line=0.1,cex=0.5,font.main=1)
#lines(x,temp[,bottom],lty=3,col='red')
lines(x,temp[,surface],lty=1,col=alpha(col.sim,1),lwd=2)
lines(as.Date(temp.w.1$V1),temp.w.1$V2,col=alpha(col.obs,0.5),pch=20,cex=1.)
#points(as.Date(temp.w.2$V1),temp.w.2$V2,col=alpha(col.obs2,0.5),pch=20,cex=1.)

plot(x,rowMeans(oxy[,1:2]),type='n',
     col=alpha(col.obs),ylim=c(00,500),log='',lwd=0.5,
     ylab='',
     xlab='days',
)
title('dissolved oxygen concentration mmol-O2 L-1',adj=0,line=0.1,cex=0.5,font.main=1)
#lines(x,oxy[,bottom],lty=3,col='red')
lines(x,oxy[,surface],lty=1,col=alpha(col.sim,1),lwd=2)
lines(as.Date(oxy.w.1$V1),(1000/32)*oxy.w.1$V2,col=alpha(col.obs,0.5),pch=20,cex=1.)
#points(as.Date(oxy.w.2$V1),(1000/32)*oxy.w.2$V2,col=alpha(col.obs2,0.5),pch=20,cex=1.)

################################
sdfasd

date.range=c('2012-06-01','2012-08-01')

plot(temp.w.3$V1,temp.w.3$V2,type='l',
     ylim=c(0,25),
     xlim= as.POSIXct(date.range)
)
lines(as.POSIXct(x),temp[,surface],lty=1,col=alpha(col.sim,1),lwd=2)


plot(oxy.w.1$V1,(1000/32)*oxy.w.1$V2,type='p',
     pch=20,cex=1.,
     ylim=c(0,500),
     xlim= as.POSIXct(date.range)
)
points(oxy.w.2$V1,(1000/32)*oxy.w.2$V2,col=alpha(col.obs2,0.5),pch=20,cex=1.)
lines(as.POSIXct(x),oxy[,surface],lty=1,col=alpha(col.sim,1),lwd=2)




fsedafsdf

plot(x,rowMeans(nut),type='l',col='black',ylim=c(1,50),log='y',
     ylab='',
     xlab='days',
     main='mean DIN')
lines(x,nut[,70],type='l',col='black',lwd=1,lty=2)

plot(x,conv.fact*rowSums(phy),type='l',col='black',ylim=c(0.1,5e4),log='y')
title(main='diatoms')

plot(x,conv.fact*rowSums(det),type='l',col='black',ylim=c(.0002,20000),log='y')
title(main='copepods')




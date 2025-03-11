# SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

if (!require("ncdf4")) install.packages("ncdf4")
is.oxypom_ = T # True if OxyPOM is validated False if DiaMo is validated

################################################################################
## definition of local functions

Get.Year = function(...) format(as.Date(..., format="%d/%m/%Y"),"%Y")
as.POSIXct = function(...) base::as.POSIXct(...,,format="%Y-%m-%d %H:%M:%S")

################################################################################
## loading the results of gotm
nc_data = nc_open('output.nc')

temp =  t(ncvar_get(nc_data, "temp"))

if(is.oxypom_){
  oxy =  t(ncvar_get(nc_data, "oxypom_DOxy"))
}else{
  oxy =  t(ncvar_get(nc_data, "diamo_OXY"))
}

################################################################################
## loading observed values for temperature (temp) and dissolved oxygen (DO)

temp.obs.1 = read.delim("./data/FGG_Elbe_008!Wassertemperatur.txt", header=FALSE, comment.char="#")
temp.obs.2 = read.delim("./data/FGG_Elbe_009!Wassertemperatur.txt", header=FALSE, comment.char="#")
temp.obs.3 = read.delim("./data/LZ_AL!Wassertemperatur.txt", header=FALSE, comment.char="#")

temp.obs.1$V1 = as.POSIXct(temp.obs.1$V1)
temp.obs.2$V1 = as.POSIXct(temp.obs.2$V1)
temp.obs.3$V1 = as.POSIXct(temp.obs.3$V1)

temp.obs.1 = subset(temp.obs.1, Get.Year(V1)>=2004)
temp.obs.2 = subset(temp.obs.2, Get.Year(V1)>=2004)
temp.obs.3 = subset(temp.obs.3, Get.Year(V1)>=2004)

DO.obs.1 = read.delim("./data/FGG_Elbe_008!Sauerstoffgehalt_(Einzelmessung).txt", header=FALSE, comment.char="#")
DO.obs.2 = read.delim("./data/FGG_Elbe_009!Sauerstoffgehalt_(Einzelmessung).txt", header=FALSE, comment.char="#")

DO.obs.1$V1 = as.POSIXct(DO.obs.1$V1)
DO.obs.2$V1 = as.POSIXct(DO.obs.2$V1)

DO.obs.1 = subset(DO.obs.1, Get.Year(V1)>=2004)
DO.obs.2 = subset(DO.obs.2, Get.Year(V1)>=2004)

################################################################################
## plotting the data

x = 1:length(temp[,1])
x = as.Date(x,origin='2006-01-01')

surface = length(temp[1,])-1 # layer number of the surface
bottom = 1 # layer number of the bottom

col.sim='tomato'
col.sim.bottom = 'pink'
col.obs='black'
col.obs2='gray50'
col.obs3='gray50'


png(filename="./estuary_validation.png",
    width = 800, height = 400)

par(mfrow=c(2,1),mai=c(0.42,0.42,0.21,0.21),oma=2*c(1,1,0.5,0.5),las=1)

plot(x,rowMeans(temp[,bottom:surface]),type='n',
     col=NA,ylim=c(-5,25),log='',lwd=0.5,
     ylab='',
     xlab='days'
     )
title('temperature at the surface degC',adj=0,line=0.1,cex=0.5,font.main=1)
points(as.Date(temp.obs.2$V1),temp.obs.2$V2,col=col.obs2,pch=0,cex=.5)
lines(as.Date(temp.obs.3$V1),temp.obs.3$V2,col=col.obs3,pch=20,cex=1)
points(as.Date(temp.obs.1$V1),temp.obs.1$V2,col=col.obs,pch=20,cex=1)
lines(x,temp[,bottom],lty=1,col=col.sim.bottom)
lines(x,temp[,surface],lty=1,col=col.sim,lwd=2)

cf = 1000/32 # conversion factor of mg L-1 to mmol-O2 L

plot(x,rowMeans(oxy[,1:2]),type='n',
     col=NA,ylim=c(100,500),log='',lwd=0.5,
     ylab='',
     xlab='days',
     )
title('dissolved oxygen concentration mmol-O2 L-1',adj=0,line=0.1,cex=0.5,font.main=1)
points(as.Date(DO.obs.2$V1),(1000/32)*DO.obs.2$V2,col=col.obs2,pch=0,cex=.5)
points(as.Date(DO.obs.1$V1),cf*DO.obs.1$V2,col=col.obs,pch=20,cex=1)
lines(x,oxy[,bottom],lty=1,col=col.sim.bottom)
lines(x,oxy[,surface],lty=1,col=col.sim,lwd=2)

legend('bottomleft',
       cex=1,
       legend=c('E9-obs','E8-obs','AL-obs','surface-sim', 'bottom-sim'),
       bty = 'n',
       horiz = T,
       border=NA,
       pt.cex=c(.5,1,NA,NA,NA),
       col=c(col.obs2,col.obs,col.obs3,col.sim,col.sim.bottom),
       pch=c(0,20,0,0,0),
       pt.lwd=c(1,1,1,1,1),
       lwd=c(0,0,1,2,1)
       )

dev.off()
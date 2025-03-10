# SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

setwd('./data/')

Get.Year = function(...) format(as.Date(..., format="%d/%m/%Y"),"%Y")

temp = read.delim("Cuxhaven_DWD!Lufttemperatur.txt", header=FALSE, comment.char="#")
wind = read.delim("Cuxhaven_DWD!Windgeschwindigkeit.txt", header=FALSE, comment.char="#")
dirw = read.delim("Cuxhaven_DWD!Windrichtung.txt", header=FALSE, comment.char="#")

temp$V1 = as.POSIXct(temp$V1)
wind$V1 = as.POSIXct(wind$V1)
dirw$V1 = as.POSIXct(dirw$V1)

## transforming temperatures at 9m above ground to 2 meter values
## assuming linear profile
h.station = 9
h.model = 2
T.gradient = -0.0065
temp$temp = temp$V2+(h.model-h.station)*T.gradient+5

## transforming wind speed at 9m above ground to 10 meter values
## assuming logarithmic profile
h.station = 9
h.model = 10
w.exponent = 0.14
wind$V3 = wind$V2*(h.model/h.station)**w.exponent

## merging wind files
wind = merge(wind,dirw,by='V1',suffixes = c('.vel','.dir'))
  
## calculating wind components
wind$u10 = wind$V3*cos(pi*wind$V2.dir/180)
wind$v10 = wind$V3*sin(pi*wind$V2.dir/180)

meteofile = merge(temp,wind)
meteofile = subset(meteofile, 
                   Get.Year(V1)>=2004 & !is.na(temp) & !is.na(v10) & !is.na(u10),
                   select=c(V1,temp,u10,v10)
                   )

meteofile$V1 = meteofile$V1 + 1 #adding 1 sec to avoid a bug with gotm
colnames(meteofile) = paste0("#", colnames(meteofile))

write.csv(meteofile,'meteofile.csv',row.names=F,quote=F)

############

temp.w.1 = read.delim("FGG_Elbe_008!Wassertemperatur.txt", header=FALSE, comment.char="#")
temp.w.2 = read.delim("FGG_Elbe_009!Wassertemperatur.txt", header=FALSE, comment.char="#")
temp.w.3 = read.delim("LZ_AL!Wassertemperatur.txt", header=FALSE, comment.char="#")

temp.w.1$V1 = as.POSIXct(temp.w.1$V1)
temp.w.2$V1 = as.POSIXct(temp.w.2$V1)
temp.w.3$V1 = as.POSIXct(temp.w.3$V1)

temp.w.1 = subset(temp.w.1, Get.Year(V1)>=2004)
temp.w.2 = subset(temp.w.2, Get.Year(V1)>=2004)
temp.w.3 = subset(temp.w.3, Get.Year(V1)>=2004)

oxy.w.1 = read.delim("FGG_Elbe_008!Sauerstoffgehalt_(Einzelmessung).txt", header=FALSE, comment.char="#")
oxy.w.2 = read.delim("FGG_Elbe_009!Sauerstoffgehalt_(Einzelmessung).txt", header=FALSE, comment.char="#")

oxy.w.1$V1 = as.POSIXct(oxy.w.1$V1)
oxy.w.2$V1 = as.POSIXct(oxy.w.2$V1)

oxy.w.1 = subset(oxy.w.1, Get.Year(V1)>=2004)
oxy.w.2 = subset(oxy.w.2, Get.Year(V1)>=2004)

plot(meteofile$`#V1`,meteofile$`#temp`,type='l',
     ylim=c(0,25),
     xlim= as.POSIXct(c('2012-08-01','2013-12-01'))
     )
abline(h=0)

plot(temp.w.3$V1,temp.w.3$V2,type='l',
     ylim=c(0,25),
     xlim= as.POSIXct(c('2012-08-01','2013-12-01'))
)
abline(h=0)

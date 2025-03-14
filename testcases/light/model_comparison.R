# SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

if (!require("ncdf4")) install.packages("ncdf4")

################################################################################
## definition of local functions

Get.Year = function(...) format(as.Date(..., format="%d/%m/%Y"),"%Y")

################################################################################
## loading the results of gotm

system('ln -f fabm.new.yaml fabm.yaml')
system('./gotm')
nc_data = nc_open('output.nc')
bpar =  t(ncvar_get(nc_data, "light_par"))
bswr =  t(ncvar_get(nc_data, "light_swr"))
bphy = t(ncvar_get(nc_data, "oxypom_ALG1"))

system('ln -f fabm.ref.yaml fabm.yaml')
system('./gotm')
nc_data = nc_open('output.nc')
rpar =  t(ncvar_get(nc_data, "light_par"))
rswr =  t(ncvar_get(nc_data, "light_swr"))
rphy = t(ncvar_get(nc_data, "oxypom_ALG1"))

################################################################################
## plotting the data

col.sim='tomato'
col.ref='black'

N = length(rpar[1,])

png(filename="./light_validation.png",
    width = 600, height = 600)

par(mfrow=c(3,2),mai=2*c(0.42,0.42,0.21,0.21),oma=2*c(1,1,0.5,0.5),las=1)
hist(100*(bpar-rpar)/(rpar+bpar),
     main='difference in par relatiave to reference (%)',
     xlim=c(-100,100),
     xlab='',
     freq = F,
     border=NA,
     n=50)

  hist(100*(bphy-rphy)/(rphy+bphy),
       xlim=c(-100,100),
       xlab='',
       main='difference in ALG1 relatiave to reference (%)',
       freq=F,
       border=NA,
       n=50)

  plot(rpar,bpar,col='lightgray',pch=20,
       xlab='reference ALG1',
       ylab='dobgc_light ALG1')
  abline(a=0,b=1)
  
  
  plot(rphy,bphy,col='lightgray',pch=20,
       xlab='reference ALG1',
       ylab='dobgc_light ALG1')
  abline(a=0,b=1)

  plot(rowMeans(rpar[,1:(N/2+1)]),type='l',col=col.ref,
       main='par in the surface',
       xlab='',
       ylab='W m-2')
  lines(rowMeans(bpar[,1:(N/2+1)]),type='l',col=col.sim)
  

  plot(rowMeans(rphy[,1:(N/2+1)]),type='l',col=col.ref,
       main='ALG1 in the surface',
       xlab='',
       ylab='mmol-C m-3')
  lines(rowMeans(bphy[,1:(N/2+1)]),type='l',col=col.sim)
dev.off()



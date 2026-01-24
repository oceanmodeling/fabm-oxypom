# SPDX-FileCopyrightText: 2026 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

if (!require("ncdf4")) install.packages("ncdf4")
if (!require("lubridate")) install.packages("lubridate")
if (!require("TeachingDemos")) install.packages("TeachingDemos")
if (!require("MASS")) install.packages("MASS")
if (!require("scales")) install.packages("scales")
if (!require("latex2exp")) install.packages("latex2exp")

################################################################################
## definition of local functions

plot.xaxis = function(x=0){
    if(x==0){
      axis(side=1,at=as.Date(paste0('2020-',c(1,4,7,10),'-01')),labels=c('Jan','Apr','Jul','Oct'),lwd=-1,lwd.ticks = 1,padj=0,hadj=0)
      abline(v=as.Date(c(paste0('2020-',c(1,4,7,10),'-01'),'2021-01-01')),lty=3,col='#444444',lwd=0.5)
    }
    if(x==1){
      axis(side=1,at=yday(as.Date(paste0('2020-',c(1,4,7,10),'-01'))),labels=c('Jan','Apr','Jul','Oct'),lwd=-1,lwd.ticks = 1,padj=0,hadj=0)
      abline(v=c(yday(as.Date(paste0('2020-',c(1,4,7,10),'-01'))),366),lty=3,col='#444444',lwd=0.5)
    }
  }

color.bar.h = function(lut, min, max=-min, nticks=2, title='',...) {
  scale = (length(lut)-0)/(max-min)
  ticks = pretty(seq(min, max, len=nticks),n=4,min.n=2)
  #if(max==-min) ticks = c(-max(abs(ticks)),0,max(abs(ticks)))

  plot( c(min,max*1.),c(-.1,.1), type='n', bty='n', xaxt='n', ylab='', yaxt='n', xlab='', main=NA,...)

  rect(min,.1,max,0, col=NA, border='black', lwd=1, useRaster = TRUE)
  for (i in 1:(length(lut)-0)) {
    y = (i-1)/scale + min
    rect(y,.1,y+1/scale,0, col=lut[i], border=NA, useRaster = TRUE)
  }
  text(sum(c(min,max*1.))/2,0.,title,adj=c(0.5,1.25),col='black',cex=0.75)
  axis(3, ticks, las=1,cex=0.95,cex.axis=0.75,line=-0.2,tick=F,col.axis='black')
  if(min<=0)lines(c(0,0),c(-0,.1),lwd=0.5)
  print(ticks)
}

units.to.latex = function(x) {
  parts = strsplit(x, "\\s+")[[1]]
  
  out = vapply(parts, function(p) {
    m = regexec("^([A-Za-z]+)([-+]?[0-9]+)?$", p)
    r = regmatches(p, m)[[1]]
    
    if (length(r) == 3 && nzchar(r[3])) {
      paste0(r[2], "^{", r[3], "}")
    } else {
      r[2]
    }
  }, character(1))
  out = gsub("O\\^", "O_", out)
  paste(out, collapse = "\\,")
}


col.scale = colorRampPalette(c('white','gold','darkorange'))(100) #hcl.colors(100,'Lightg',rev=T)[1:75]
col.scale.diff = hcl.colors(50,'blue-Red3')
col.scale.den = hcl.colors(100,'Lightg',rev=T)[1:75]
temp.color='#C2A2A8'
col.air = '#1e61a3ff'
col.npp = '#33c026ff'
col.nit = '#ab5cb3ff'
col.res = '#c0a926ff'
col.min = '#c02626ff'


options(digits = 2)
################################################################################
## loading the results of gotm

# ---- USER INPUT ----
nc_uniform = "output_uniform.nc"   # path to NetCDF file
nc_sensitive = "output_sensitive.nc"   # path to NetCDF file
# --------------------

# Open NetCDF file
ncu = nc_open(nc_uniform)
ncs = nc_open(nc_sensitive)

# Get variable names
var_names = names(ncu$var)
var_names = var_names[grepl("^oxypom_", var_names)]  
var_names = var_names[grepl("^oxypom_x", var_names)|(var_names%in%paste0('oxypom_',c('DOxy','NH4','NO3','PO4','ALG','POC','DOC','VIR1')))]
var_names = sort(var_names)
var_names = var_names[c(c(3,1,2,7,4:6,8:13))]

temperature = colMeans(ncvar_get(ncu, 'temp')) 

x = 1:length(ncvar_get(ncu, 'temp')[1,])
x = as.Date(x, origin = "2020-01-01")

print(var_names)


pdf("./comparison.pdf",
    width = 8, height = 1.5
)

# Set plotting layout
par(mfrow = c(1,3), mai=0.1*c(2,4,1,1),oma=c(1,3,1,1),las=1,cex=0.5)
par(mgp = c(2, 0.25, 0), tcl = 0.3)
n = 1 # counter for subfigure 1 label
m = 1 # counter for subfigure 2 label
# Loop over variables
for (v in var_names) {
  print(v)
  data = (ncvar_get(ncu, v))
  dims = dim(data)
  
  data2 = (ncvar_get(ncs, v))

  x.bar.uni = colMeans(data)
  x.bar.ref = colMeans(data2)
  
  zlim = max(abs(data-data2))
  
  max.z = max(c(data,data2))
  min.z = min(c(data,data2))
  
  lnn = strsplit(ncu$var[[v]]$longname,' ')[[1]]
  unit = ncu$var[[v]]$unit
  unit = ifelse(unit=='--','',unit)
  
  unit = TeX(paste0('$',units.to.latex(unit),'$'))
  
  # Skip empty or non-numeric variables
  if (!is.numeric(data) || is.null(dims)) {
    next
  }
  
  nd = length(dims)
  
  if (nd == 1) { next
    # 1D variable
    plot(x,data, type = "l",
         main = v,
         xlab = "Index",
         ylab = v,
         xaxt='n',
         yaxt='n'
         )
    lines(x,data2, type = "l",
          #main = v,
          col='brown',
          xlab = "Index",
          ylab = v,
          xaxt='n',
          yaxt='n')
    
  } else if (nd == 2) {
    # 2D variable
    image(1:length(x),
          1:nrow(data),
          t(data),
          main = NA,
          zlim = c(min.z, max.z),
          col = col.scale,
          useRaster = T,
          xlab=NA,
          ylab='depth, m',
          xaxt='n',
          yaxt='n')
    axis(side=2,c(0,5,10,15,20),labels=c(20,15,10,5,0))
    plot.xaxis(1)
    title(main=paste0(c(lnn[2:length(lnn)], ' (uni)'), collapse = " "),adj=0,cex.main=1.)
    title(main=letters[n],adj=0.05,cex.main=1.5,line=-1.5)
    subplot(color.bar.h(col.scale,min.z,max.z,nticks = 2,title=unit,cex.axis=0.5),
            100.,3,size=c(0.66,.2))
    
    image(1:length(x),
          1:nrow(data),
          t(data2),
          main = NA,
          zlim = c(min.z, max.z),
          col = col.scale,
          useRaster = T,
          xlab=NA,
          ylab=NA,
          xaxt='n',
          yaxt='n'
          )
    axis(side=2,c(0,5,10,15,20),labels=c(20,15,10,5,0))
    title(main=paste0(c(lnn[2:length(lnn)], ' (ref)'), collapse = " "),adj=0,cex.main=1.)
    title(main=letters[n+1],adj=0.05,cex.main=1.5,line=-1.5)
    plot.xaxis(1)
    
    image(1:length(x),
          1:nrow(data),
          t(data-data2),
          main = NA,
          zlim = c(-zlim, zlim),
          col = col.scale.diff,
          useRaster = T,
          xlab=NA,
          ylab=NA,
          xaxt='n',
          yaxt='n'
          )
    axis(side=2,c(0,5,10,15,20),labels=c(20,15,10,5,0))
    plot.xaxis(1)
    subplot(color.bar.h(col.scale.diff,-zlim,zlim,nticks = 2,title=unit,cex.axis=0.5),
            100.,3,size=c(0.66,.2))
    title(main=paste0(c(lnn[2:length(lnn)], ' (uni - ref)'), collapse = " "),adj=0,cex.main=1.)
    title(main=letters[n+2],adj=0.05,cex.main=1.5,line=-1.5)
    print(zlim)

    # 2D variable mean value
    lims = range(c(x.bar.uni,x.bar.ref))
    plot(x,x.bar.uni, 
         type = "l",
         lwd=2,
         col='gray',
         ylim=lims,
         xlab = NA,
         ylab = unit,
         xaxt='n',
         yaxt='l'
         )
    lines(x,lims[1]+(temperature-range(temperature)[1])/(range(temperature)[2]-range(temperature)[1])*(lims[2]-lims[1]),
          col=alpha(temp.color,0.75),lwd=1,lty='91',lab.cex=0.5,
          )
    mtext(side=2,'Temperature, ºC',col=temp.color,las=0,line=5,cex=0.5)
    title(main=letters[m],adj=0.95,cex.main=1.5,line=-1.5)
    plot.xaxis(0)
    lines(x,x.bar.ref, 
          type = "l"
         )
    title(main=paste0(c(lnn[2:length(lnn)], ' (uni & ref)'), collapse = " "),adj=0,cex.main=1.)
    ptl = pretty(temperature)
    axis(side=2,at=lims[1]+(ptl-range(temperature)[1])/(range(temperature)[2]-range(temperature)[1])*(lims[2]-lims[1]),
         labels=ptl,
         line=3.8,
         col=temp.color,
         col.axis=temp.color
         )
    legend(ifelse(any(x.bar.uni[1:50]<0.8*diff(lims)) | any(x.bar.ref[1:50]<0.7*diff(lims)),'topleft','left'),
           bty='n',
           legend=c('uniform','reference','temperature'),
           lwd=c(2,1,1),
           lty=c('solid','solid','91'),
           col=c('gray','black',alpha(temp.color,0.75))
           )
    
    E = 50*(x.bar.ref-x.bar.uni)/(x.bar.ref+x.bar.uni+1e-9)
    lims = range(E)
    plot(x,E, type = "l",
         xlab = NA,
         ylab = '%',
         xaxt='n',
         yaxt='l'
    )
    lines(x,lims[1]+(temperature-range(temperature)[1])/(range(temperature)[2]-range(temperature)[1])*(lims[2]-lims[1]),
          col=alpha(temp.color,0.75),lwd=1,lty='91'
    )
    abline(h=0,lty=1,lwd=0.5)
    plot.xaxis(0)
    title(main=paste0(c(lnn[2:length(lnn)], ' (E)'), collapse = " "),adj=0,cex.main=1.)
    title(main=letters[m+1],adj=0.95,cex.main=1.5,line=-1.5)
    

    xx = c(temperature)
    .h = c(bandwidth.nrd(xx), pmax(1e-6,bandwidth.nrd(E)))
    zz = kde2d(xx, E,n=100,h=.h)
    image(zz,
          col=col.scale.den,
          useRaster=T,
          xlab=NA,#'Temperature, ºC',
          ylab='E, %'
          )
    mtext(side=1,line=1.5,'Temperature, ºC',cex=0.5)
    contour(zz,add=T,col='white',levels=quantile(zz$z,prob=c(0.75,0.5)),drawlabels = F,lwd=c(2,0.5))
    abline(h=0,lwd=0.15,col='black')
    subplot(color.bar.h(col.scale.den,0,1,nticks = 2,title='',cex.axis=0.5),
            4.5,min(E)+0.1*(max(E)-min(E)),size=c(0.66,.2))
    title(main=paste0(c(lnn[2:pmin(length(lnn),3)], 'T-E density'), collapse = " "),adj=0,cex.main=1.)
    title(main=letters[m+2],adj=0.95,cex.main=1.5,line=-1.5)
    
    n = n + 3
    m = m + 3
    
    n = ifelse(n>20,1,n)
    m = ifelse(m>20,1,m)
  } 
}



dev.off()

pdf("./flux.pdf",
    width = 6, height = 3
)


layout(matrix(c(1,3,2,4),ncol=2),heights = c(2,1))
par(mai=0.1*c(2,4,1,1),oma=c(1,1,1,1),las=1,cex=0.5)
par(mgp = c(2, 0.25, 0), tcl = 0.3)
temp.range =as.Date(c('2020-06-01','2020-09-30'))
n=1
for(k in list(ncu,ncs)){

  nc = k

  h = ncvar_get(nc, 'h')
  air = (ncvar_get(nc, 'oxypom_AIR'))
  air_p = pmax(air,0)
  air_n = pmin(air,0)
  npp = colSums(ncvar_get(nc, 'oxypom_x_npp')*h)
  min = colSums(ncvar_get(nc, 'oxypom_x_min')*h)
  nit = colSums(ncvar_get(nc, 'oxypom_x_nit')*h)
  res = colSums(ncvar_get(nc, 'oxypom_x_npp')*h)
  
  
  xx= c(x,rev(x))
  
  plot(x,0*as.numeric(x),ylim=c(-75,40),xlim=temp.range,type='n',xlab='n',ylab= TeX(paste0('$',units.to.latex('mmol O2 m-2 d-1'),'$')))
  title(main=c('Oxygen flux (uni)','Oxygen flux (ref)')[n],adj=0,cex.main=1.)
  title(main=letters[n],adj=0.05,cex.main=1.5,line=-1.5)
  
  polygon(xx,c(air_n,rev(air_p)),col=col.air,border=NA)
  polygon(xx,c(air_p,rev(air_p+npp)),col=col.npp,border=NA)
  polygon(xx,c(air_n,rev(air_n-min)),col=col.min,border=NA)
  polygon(xx,c(air_n-min,rev(air_n-min-nit)),col=col.nit,border=NA)
  polygon(xx,c(air_n-min-nit,rev(air_n-min-nit-res)),col=col.res,border=NA)
  
  sum_oxy = (air+npp-min-nit-res)
  lines(x,sum_oxy,lwd=1,col='black')
  lines(x,sum_oxy,lwd=0.7,col='white')

  if(n == 1){
    legend('bottomright',
           legend=c('re-aeration', 'primary production', 'mineralization', 'nitrification', 'respiration '),
            pch = 15,
            cex=1,
           pt.cex = 1.7,
            col=c(col.air, col.npp, col.min, col.nit, col.res),
            bty='n'
           )
  }
  
  n = n + 1
}

for(k in list(ncu,ncs)){
  
  nc = k
  
  h = ncvar_get(nc, 'h')
  air = (ncvar_get(nc, 'oxypom_AIR'))
  air_p = pmax(air,0)
  air_n = pmin(air,0)
  npp = colSums(ncvar_get(nc, 'oxypom_x_npp')*h)
  min = colSums(ncvar_get(nc, 'oxypom_x_min')*h)
  nit = colSums(ncvar_get(nc, 'oxypom_x_nit')*h)
  res = colSums(ncvar_get(nc, 'oxypom_x_npp')*h)
  
  total_oxy = air_p + npp
  total_deoxy = -air_n + min + nit + res
  
  air_p = air_p/total_oxy*100
  air_n = air_n/total_deoxy*100
  npp = npp/total_oxy*100
  min =  min/total_deoxy*100
  nit =  nit/total_deoxy*100
  res =  res/total_deoxy*100
  
  xx= c(x,rev(x))
  
  plot(x,0*as.numeric(x),ylim=c(-100,100),xlim=temp.range,type='n',xlab='n',ylab='%',yaxs='i')
  title(main=c('Relative oxygen flux (uni)','Relative oxygen flux (ref)')[n-2],adj=0,cex.main=1.)
  
  polygon(xx,c(air_n,rev(air_p)),col=col.air,border=NA)
  polygon(xx,c(air_p,rev(air_p+npp)),col=col.npp,border=NA)
  polygon(xx,c(air_n,rev(air_n-min)),col=col.min,border=NA)
  polygon(xx,c(air_n-min,rev(air_n-min-nit)),col=col.nit,border=NA)
  polygon(xx,c(air_n-min-nit,rev(air_n-min-nit-res)),col=col.res,border=NA)
  #abline(h=0,lwd=0.5,col='white')
  title(main=letters[n],adj=0.05,cex.main=1.5,line=-1.5)
  
  n = n + 1
}

dev.off()

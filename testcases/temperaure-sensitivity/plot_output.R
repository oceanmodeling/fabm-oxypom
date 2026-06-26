# SPDX-FileCopyrightText: 2026 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

if (!require("ncdf4")) install.packages("ncdf4")
if (!require("lubridate")) install.packages("lubridate")
if (!require("TeachingDemos")) install.packages("TeachingDemos")
if (!require("MASS")) install.packages("MASS")
if (!require("scales")) install.packages("scales")
if (!require("latex2exp")) install.packages("latex2exp")

Sys.setlocale("LC_TIME", "en_US.UTF-8")

################################################################################
## definition of local functions

plot.xaxis = function(x=0){
    if(x==0){
      axis(side=1,at=as.Date(paste0('2020-',c(1,4,7,10),'-01')),labels=NA,lwd=-1,lwd.ticks = 1,padj=0,hadj=0)
      #abline(v=as.Date(c(paste0('2020-',c(1,4,7,10),'-01'),'2021-01-01')),lty=3,col='#444444',lwd=0.5)
    }
    if(x==1){
      axis(side=1,at=yday(as.Date(paste0('2020-',c(1,4,7,10),'-01'))),labels=NA,lwd=-1,lwd.ticks = 1,padj=0,hadj=0)
      #abline(v=c(yday(as.Date(paste0('2020-',c(1,4,7,10),'-01'))),366),lty=3,col='#444444',lwd=0.5)
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


col.scale = colorRampPalette(c('white','lightgray','gray60'))(30) #hcl.colors(100,'Lightg',rev=T)[1:75]
col.scale.diff = hcl.colors(50,'blue-Red2')
col.scale.den = hcl.colors(80,'lightg',rev=T)[1:75]
temp.color='#C2A2A8'
col.air = '#1e61a3ff'
col.npp = '#33c026ff'
col.nit = '#ab5cb3ff'
col.res = '#c0a926ff'
col.min = '#c02626ff'


options(digits = 1)
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

pdf("./headers.pdf",
    width = 8/1.5, height = .33/1.5
)
par(mfrow = c(1,3), mai=0.1*c(1.,1,.1,0.1),oma=c(0,4,0,0),las=1,cex=0.5)
plot.new()
mtext('Uniform',line=-1.5,cex=1.,font=2)
plot.new()
mtext('Reference',line=-1.5,cex=1.,font=2)
plot.new()
mtext('Difference',line=-1.5,cex=1.,font=2)

par(mfrow = c(1,3), mai=0.1*c(1.5,1,.5,0.1),oma=c(0,5,0,3),las=1,cex=0.5)
layout(t(c(1,2,3)),widths = c(1,1.13,.8))

plot.new()
mtext('Vertical average',line=-1.,cex=.66,font=2)
par(mai=0.1*c(1.5,3,.5,0.1))
plot.new()
mtext('Difference',line=-1.,cex=.66,font=2)
par(mai=0.1*c(1.5,1,.5,0.1))
plot.new()
mtext('Temperature vs. Difference',line=-1.,cex=.66,font=2,adj=0.33)

dev.off()

pdf("./comparison.pdf",
    width = 8/1.5, height = 1.5/1.5
)

# Set plotting layout
par(mfrow = c(1,3), mai=0.1*c(1.5,4,1,1),oma=c(1,2,0,0),las=1,cex=0.5)
par(mgp = c(2, 0.25, 0), tcl = 0.3)
n = 1 # counter for subfigure 1 label
m = 1 # counter for subfigure 2 label
kk = 0 # counter for additional figures
# Loop over variables
for (v in var_names) {
  print(v)
  print(kk)
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
  par(mfrow = c(1,3), mai=0.1*c(1.,1,.1,0.1),oma=c(0,4,0,0),las=1,cex=0.5)
  
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
          ylab='',
          xaxt='n',
          yaxt='n')
    axis(side=2,c(0,5,10,15,20),labels=c(20,15,10,5,0))
    plot.xaxis(1)
    #title(main=paste0(c(lnn[2:length(lnn)], ' (uni)'), collapse = " "),adj=0,cex.main=1.)
    title(main=letters[n],adj=0.05,cex.main=1.5/1.3,line=-1.5)
    if(n == 1) title(main='Uniform sensitivity',adj=0.5,cex.main=1.,line=0.33,font.main=2)
    
    lbl = paste(lnn[2:length(lnn)], collapse = " ")
    if(lbl=='Oxygen produced by phytoplankton') lbl='Photosynthesis'
    lbl = gsub("\\b(Total|Dissolved|Oxygen-equivalent|Oxygen\\s+consumed|Oxygen\\s+produced|for\\s+diatom|rate|by)\\b", "", lbl, ignore.case = TRUE, perl = TRUE)
    lbl = gsub("\\s+", " ", trimws(lbl), perl = TRUE)
    i = regexpr("[[:alpha:]]", lbl)[1]
    if (i > 0) substr(lbl, i, i) = toupper(substr(lbl, i, i))
    lbl = gsub("\\s+(by|denitrification)\\b", "\n\1", lbl, perl = TRUE)

    mtext(side = 2,lbl,las = 0, line = 2, cex = .75, outer = TRUE, font = 2)
    mtext(side = 2,'depth, m',las = 0, line = 1.25, cex = .5, outer = FALSE, font = 1)
    if(kk==0)if(letters[(n)] %in% c('s','t','u')) axis(side=1,at=yday(as.Date(paste0('2020-',c(1,4,7,10),'-01'))),labels=c('Jan','Apr','Jul','Oct'),lwd=-1,lwd.ticks = 1,padj=0,hadj=0,tck=0,line=-.3)
    if(kk==1)if(letters[(n)] %in% c('p','q','r')) axis(side=1,at=yday(as.Date(paste0('2020-',c(1,4,7,10),'-01'))),labels=c('Jan','Apr','Jul','Oct'),lwd=-1,lwd.ticks = 1,padj=0,hadj=0,tck=0,line=-.3)
    
    subplot(color.bar.h(col.scale,min.z,max.z,nticks = 2,title=unit,cex.axis=0.5),
            100.,4,size=c(0.66,.2))
    
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
    axis(side=2,c(0,5,10,15,20),labels=NA)
    #title(main=paste0(c(lnn[2:length(lnn)], ' (ref)'), collapse = " "),adj=0,cex.main=1.)
    if(n == 1) title(main='Reference sensitivity',adj=0.5,cex.main=1.,line=0.33,font.main=2)
    title(main=letters[n+1],adj=0.05,cex.main=1.5/1.3,line=-1.5)
    plot.xaxis(1)
    if(kk==0)if(letters[(n+1)] %in% c('s','t','u')) axis(side=1,at=yday(as.Date(paste0('2020-',c(1,4,7,10),'-01'))),labels=c('Jan','Apr','Jul','Oct'),lwd=-1,lwd.ticks = 1,padj=0,hadj=0,tck=0,line=-.3)
    if(kk==1)if(letters[(n+1)] %in% c('p','q','r')) axis(side=1,at=yday(as.Date(paste0('2020-',c(1,4,7,10),'-01'))),labels=c('Jan','Apr','Jul','Oct'),lwd=-1,lwd.ticks = 1,padj=0,hadj=0,tck=0,line=-.3)
    
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
    
    if(F)contour(1:length(x),
            1:nrow(data),
            t(data-data2),add=T,levels = 0,drawlabels = F,lwd=0.5,col='#44444444',lty=2)
    
    axis(side=2,c(0,5,10,15,20),labels=NA)
    plot.xaxis(1)
    subplot(color.bar.h(col.scale.diff,-zlim,zlim,nticks = 2,title=unit,cex.axis=0.5),
            100.,4,size=c(0.66,.2))
    #title(main=paste0(c(lnn[2:length(lnn)], ' (uni - ref)'), collapse = " "),adj=0,cex.main=1.)
    if(n == 1) title(main='Uniform - Reference',adj=0.5,cex.main=1.,line=0.33,font.main=2)
    title(main=letters[n+2],adj=0.05,cex.main=1.5/1.3,line=-1.5)
    print(zlim)
    if(kk==0)if(letters[(n+2)] %in% c('s','t','u')) axis(side=1,at=yday(as.Date(paste0('2020-',c(1,4,7,10),'-01'))),labels=c('Jan','Apr','Jul','Oct'),lwd=-1,lwd.ticks = 1,padj=0,hadj=0,tck=0,line=-.3)
    if(kk==1)if(letters[(n+2)] %in% c('p','q','r')) axis(side=1,at=yday(as.Date(paste0('2020-',c(1,4,7,10),'-01'))),labels=c('Jan','Apr','Jul','Oct'),lwd=-1,lwd.ticks = 1,padj=0,hadj=0,tck=0,line=-.3)
    

   
    
    par(mfrow = c(1,3), mai=0.1*c(1.5,1,.5,0.1),oma=c(0,5,0,3),las=1,cex=0.5)
    layout(t(c(1,2,3)),widths = c(1,1.13,.8))
    par(cex=0.5)
    # 2D variable mean value
    lims = range(c(x.bar.uni,x.bar.ref))
    plot(x,x.bar.uni, 
         type = "l",
         lwd=2,
         col='gray',
         ylim=lims,
         xlab = NA,
         ylab = NA,
         xaxt='n',
         yaxt='l'
         )
    lines(x,lims[1]+(temperature-range(temperature)[1])/(range(temperature)[2]-range(temperature)[1])*(lims[2]-lims[1]),
          col=alpha(temp.color,0.75),lwd=1,lty='91',lab.cex=0.5,
          )
    title(main=letters[m],adj=0.95,cex.main=1.5/1.3,line=-1.5)
    plot.xaxis(0)
    lines(x,x.bar.ref, 
          type = "l"
         )
    #title(main=paste0(c(lnn[2:length(lnn)], ' (uni & ref)'), collapse = " "),adj=0,cex.main=1.)
    #if(m == 1) title(main='Reference and uniform sensitivities',adj=0.5,cex.main=1.,line=0.33,font.main=2)
    #lbl = paste(lnn[2:length(lnn)], collapse = " ")
    #lbl = gsub("\\s+(by|denitrification)\\b", "\n\\1", lbl, perl = TRUE)
    mtext(side = 2,lbl,las = 0, line = 3., cex = .75, outer = T, font = 2)
    mtext(side = 2,unit,las = 0, line = 2.5, cex = .5, outer = FALSE, font = 1)
    
    if(kk==1)if(letters[(m)] %in% c('p','q','r')) axis(side=1,at=as.Date(paste0('2020-',c(1,4,7,10),'-01')),labels=c('Jan','Apr','Jul','Oct'),lwd=-1,lwd.ticks = 0,tck=0,padj=0,hadj=0,line=-0.25)
    if(kk==0)if(letters[(m)] %in% c('s','t','u')) axis(side=1,at=as.Date(paste0('2020-',c(1,4,7,10),'-01')),labels=c('Jan','Apr','Jul','Oct'),lwd=-1,lwd.ticks = 0,tck=0,padj=0,hadj=0,line=-0.25)
    
    ptl = pretty(temperature)
    axis(side=4,at=lims[1]+(ptl-range(temperature)[1])/(range(temperature)[2]-range(temperature)[1])*(lims[2]-lims[1]),
         labels=ptl,
         line=0,
         col=temp.color,
         col.axis=temp.color
         )
    mtext(side=4,'Temp, ºC',col=temp.color,las=0,line=1,cex=0.5)

    if(m == 1) legend(ifelse(any(x.bar.uni[1:50]<0.8*diff(lims)) | any(x.bar.ref[1:50]<0.7*diff(lims)),'topleft','left'),
           bty='n',
           legend=c('Uni.','Ref.','Temp.'),
           lwd=c(2,1,1),
           lty=c('solid','solid','91'),
           col=c('gray','black',alpha(temp.color,0.75)),
           cex=0.75
           )
    
    E = 200*(x.bar.ref-x.bar.uni)/(x.bar.ref+x.bar.uni+1e-9)
    lims = range(E)
    
    par(mai=0.1*c(1.5,3,.5,0.1))
    
    plot(x,E, type = "l",
         xlab = NA,
         ylab = '',
         xaxt='n',
         yaxt='n',
         yaxs='i'
    )
    axis(side=4,labels=F)
    lines(x,lims[1]+(temperature-range(temperature)[1])/(range(temperature)[2]-range(temperature)[1])*(lims[2]-lims[1]),
          col=alpha(temp.color,0.75),lwd=1,lty='91'
    )
    abline(h=0,lty=1,lwd=0.5)
    plot.xaxis(0)
    #title(main=paste0(c(lnn[2:length(lnn)], ' (E)'), collapse = " "),adj=0,cex.main=1.)
    title(main=letters[m+1],adj=0.95,cex.main=1.5/1.3,line=-1.5)
    #if(m == 1) title(main='Relative error (D, %)',adj=0.5,cex.main=1.,line=0.33,font.main=2)
    if(kk==1)if(letters[(m+1)] %in% c('p','q','r')) axis(side=1,at=as.Date(paste0('2020-',c(1,4,7,10),'-01')),labels=c('Jan','Apr','Jul','Oct'),lwd=-1,lwd.ticks = 0,tck=0,padj=0,hadj=0,line=-0.25)
    if(kk==0)if(letters[(m+1)] %in% c('s','t','u')) axis(side=1,at=as.Date(paste0('2020-',c(1,4,7,10),'-01')),labels=c('Jan','Apr','Jul','Oct'),lwd=-1,lwd.ticks = 0,tck=0,padj=0,hadj=0,line=-0.25)
    

    xx = c(temperature)
    .h = c(bandwidth.nrd(xx), pmax(1e-6,bandwidth.nrd(E)))
    zz = kde2d(xx, E,n=100,h=.h)
    
    par(mai=0.1*c(1.5,1,.5,0.1))
  
    image(zz,
          col=col.scale.den,
          useRaster=T,
          xlab=NA,#'Temperature, ºC',
          ylab='',
          xaxt='n',
          yaxt='n',
          yaxs='i',
          xaxs='i'
          #bty='l'
          )
    #axis(side=1,labels=F)

    if(kk==1 & letters[(m+2)] %in% c('p','q','r') | kk==0 & letters[(m+2)] %in% c('s','t','u')){
      mtext(side=1,line=1.5,'temperature, ºC',cex=0.5)
      axis(side=1,lwd=0,line=-0.25,at=seq(2,14,by=2),labels=c('Temp, ºC',seq(4,14,by=2)))
    } 
    contour(zz,add=T,col='white',levels=quantile(zz$z,prob=c(0.75,0.5)),drawlabels = F,lwd=c(2,0.5))
    abline(h=0,lwd=0.15,col='black')

    # title(main=paste0(c(lnn[2:pmin(length(lnn),3)], 'T-E density'), collapse = " "),adj=0,cex.main=1.)
    title(main=letters[m+2],adj=0.95,cex.main=1.5/1.3,line=-1.5)
    #if(m == 1) title(main='Temperature vs. Relative error',adj=0.5,cex.main=1.,line=0.33,font.main=2)
    if(letters[(m+2)] %in% c('p','q','r')) axis(side=1,at=as.Date(paste0('2020-',c(1,4,7,10),'-01')),labels=c('Jan','Apr','Jul','Oct'),lwd=-1,lwd.ticks = 0,tck=0,padj=0,hadj=0)
    
    
    axis(side=4,lwd=0,lwd.ticks = 1,tck=0.02)
    axis(side=1,lwd=0,lwd.ticks = 1,tck=0.02,labels=F)

    mtext(side=4,'Difference %',las=0,cex=0.5,line=2)
    
    if(letters[(m+2)]=='c'){
      subplot(color.bar.h(col.scale.den,0,1,nticks = 2,title='',cex.axis=0.5),
              5.5,min(E)+0.1*(max(E)-min(E)),size=c(0.66,.2))
    }
    
    n = n + 3
    m = m + 3

    if(n>20)if(kk==0)kk =1   
    n = ifelse(n>20,1,n)
    m = ifelse(m>20,1,m)

  } 
}



dev.off()

pdf("./flux.pdf",
    width = 6/1.3, height = 3/1.3
)


layout(matrix(c(1,3,2,4),ncol=2),heights = c(2,1))
par(mai=0.1*c(.5,1,0,0.),oma=c(1,4,2,0.5),las=1,cex=0.5)
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
  
  plot(x,0*as.numeric(x),ylim=c(-75,40),
       xlim=temp.range,type='n',xlab='n',
       yaxt='n',xaxt='n',
       ylab= '')
  axis.Date(side=1,labels=F)
  if(n==1){
    mtext(side=2,TeX(paste0('$',units.to.latex('mmol O2 m-2 d-1'),'$')),outer=F,las=0,cex=0.5,line=1.75) 
    mtext(side=2,'Oxygen flux',outer=T,las=0,cex=.75,line=2.5,font=2) 
    axis(side=2)
  }else{
    axis(side=2,labels=F)
  }
  mtext(side=3,c('Uniform','Reference')[n],cex=.75,adj=0.5,font=2,line=0.25)
  title(main=letters[n],adj=0.05,cex.main=1.5/1.3,line=-1.5)
  
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
           legend=c('re-aeration', 'photosynthesis', 'mineralization', 'nitrification', 'respiration '),
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
  
  plot(x,0*as.numeric(x),ylim=c(-100,100),
       xlim=temp.range,type='n',xlab='n',ylab='',yaxs='i',yaxt='n')

  #title(main=c('Relative oxygen flux (uni)','Relative oxygen flux (ref)')[n-2],adj=0,cex.main=1.)
  polygon(xx,c(air_n,rev(air_p)),col=col.air,border=NA)
  polygon(xx,c(air_p,rev(air_p+npp)),col=col.npp,border=NA)
  polygon(xx,c(air_n,rev(air_n-min)),col=col.min,border=NA)
  polygon(xx,c(air_n-min,rev(air_n-min-nit)),col=col.nit,border=NA)
  polygon(xx,c(air_n-min-nit,rev(air_n-min-nit-res)),col=col.res,border=NA)
  #abline(h=0,lwd=0.5,col='white')
  title(main=letters[n],adj=0.05,cex.main=1.5/1.3,line=-1.5)
  if(n==3){
    mtext(side=2,'%',outer=F,las=0,cex=0.5,line=2) 
    axis(side=2)
  }else{
    axis(side=2,labels=F)  
  }
  n = n + 1
}

dev.off()


temp = seq(0,30,by=.1)

pdf("./photo_sensitivity.pdf",
    width = 6/1, height = 6/1
)
par(mai=0.3*c(2,2,1,1),oma=0*c(1,1,1,1),las=1,cex=0.5)
par(mgp = c(2, 0.25, 0), tcl = 0.3,lend=1,mfrow=c(2,2)) 
plot(temp,0*temp,type='n',xlab='temperature, ºC',ylab=TeX('phytoplankton growth rate, d$^{-1}$'),ylim=c(-0.,1.2))
the.sd = 0.05
text(0,1.2,'a',adj=c(0,1),cex=1.3,font=2)

all.fr = NULL
for(i in 1:200){
  Io = 150*(1+rnorm(1,mean=0,sd=the.sd))
  Istar = 30*(1+rnorm(1,mean=0,sd=the.sd))
  mustar = 1.84*(1+rnorm(1,mean=0,sd=the.sd))
  mstar = 0.45*(1+rnorm(1,mean=0,sd=the.sd))
  rstar = 0.036*(1+rnorm(1,mean=0,sd=the.sd))
  pi = 0.065*(1+rnorm(1,mean=0,sd=the.sd))
  lambda = 0.3*(1+rnorm(1,mean=0,sd=the.sd))
  Tref = 20*(1+rnorm(1,mean=0,sd=the.sd))
  
  Q10_I = 1.04
  Q10_phy = 1.20
  Q10_m = 4.40
  Q10_res = 1.10

  tau_I = Q10_I^(0.1*(temp-Tref))
  tau_phy = Q10_phy^(0.1*(temp-Tref))
  tau_res = Q10_res^(0.1*(temp-Tref))
  tau_mort = Q10_m^(0.1*(temp-Tref))

  Iprime = Istar * tau_I
  f_light = 1-exp(-Io/Iprime)

  rho = tau_phy * f_light * mustar

  mort = mstar*ifelse(temp<Tref,ifelse(temp<5, 1, 1),tau_mort)
  resp = pi*rho + (1-pi)*rstar*tau_res

  fr =  rho - mort - resp - lambda 
  all.fr = rbind(all.fr,fr)
  #lines(temp,fr,col=alpha('#7375f7',0.05),lwd=0.5)
}

all.sd = apply(all.fr,2,sd)
all.mean = colMeans(all.fr)
polygon(c(temp,rev(temp)),c(all.mean+all.sd,rev(all.mean-all.sd)),lwd=NULL,col=alpha('black',0.25),border=NA)
lines(temp,all.mean,lwd=2,col='black')

lines(temp,tau_I,col=alpha('tomato',0.75),lwd=1,lty='31')
lines(temp,tau_phy,col=alpha('dodgerblue',0.75),lwd=1,lty='22')
lines(temp,tau_res,col=alpha('yellow3',0.75),lwd=1,lty='42')
lines(temp,tau_mort,col=alpha('purple',0.75),lwd=1,lty='33')

plot(temp,0*temp,type='n',xlab='temperature, ºC',ylab=TeX('phytoplankton growth rate, d$^{-1}$'),ylim=c(-0.,1.2))
the.sd = 0.05
text(0,1.2,'b',adj=c(0,1),cex=1.3,font=2)

all.fr = NULL
for(i in 1:200){
  Io = 150*(1+rnorm(1,mean=0,sd=the.sd))
  Istar = 30*(1+rnorm(1,mean=0,sd=the.sd))
  mustar = 1.84*(1+rnorm(1,mean=0,sd=the.sd))
  mstar = 0.45*(1+rnorm(1,mean=0,sd=the.sd))
  rstar = 0.036*(1+rnorm(1,mean=0,sd=the.sd))
  pi = 0.065*(1+rnorm(1,mean=0,sd=the.sd))
  lambda = 0.5*(1+rnorm(1,mean=0,sd=the.sd))
  Tref = 20*(1+rnorm(1,mean=0,sd=the.sd))
  
  Q10_I = 1.04
  Q10_phy = 1.30
  Q10_m = 1.0
  Q10_res = 1.10 

  tau_I = Q10_I^(0.1*(temp-Tref))
  tau_phy = Q10_phy^(0.1*(temp-Tref))
  tau_res = Q10_res^(0.1*(temp-Tref))
  tau_mort = Q10_m^(0.1*(temp-Tref))

  Iprime = Istar * tau_I
  f_light = 1-exp(-Io/Iprime)

  rho = tau_phy * f_light * mustar

  mort = mstar*ifelse(temp<Tref,ifelse(temp<5, 1, 1),tau_mort)
  resp = pi*rho + (1-pi)*rstar*tau_res

  fr =  rho - mort - resp - lambda 
  all.fr = rbind(all.fr,fr)
}

all.sd = apply(all.fr,2,sd)
all.mean = colMeans(all.fr)
polygon(c(temp,rev(temp)),c(all.mean+all.sd,rev(all.mean-all.sd)),lwd=NULL,col=alpha('black',0.25),border=NA)
lines(temp,all.mean,lwd=2,col='black')

lines(temp,tau_I,col=alpha('tomato',0.75),lwd=1,lty='31')
lines(temp,tau_phy,col=alpha('dodgerblue',0.75),lwd=1,lty='22')
lines(temp,tau_res,col=alpha('yellow3',0.75),lwd=1,lty='42')
lines(temp,tau_mort,col=alpha('purple',0.75),lwd=1,lty='33')


plot(temp,0*temp,type='n',xlab='temperature, ºC',ylab=TeX('phytoplankton growth rate, d$^{-1}$'),ylim=c(-0.,1.2))
the.sd = 0.05
text(0,1.2,'c',adj=c(0,1),cex=1.3,font=2)

all.fr = NULL
for(i in 1:200){
  Io = 150*(1+rnorm(1,mean=0,sd=the.sd))
  Istar = 30*(1+rnorm(1,mean=0,sd=the.sd))
  mustar = 2.33*(1+rnorm(1,mean=0,sd=the.sd))
  mstar = 1.330*(1+rnorm(1,mean=0,sd=the.sd))
  rstar = 0.08*(1+rnorm(1,mean=0,sd=the.sd))
  pi = 0.02*(1+rnorm(1,mean=0,sd=the.sd))
  lambda = .0*(1+rnorm(1,mean=0,sd=the.sd))
  Tref = 20*(1+rnorm(1,mean=0,sd=the.sd))
  
  Q10_I = 1.
  Q10_phy = 1.30
  Q10_m = 1.50
  Q10_res = 1.10

  tau_I = Q10_I^(0.1*(temp-Tref))
  tau_phy = Q10_phy^(0.1*(temp-Tref))
  tau_res = Q10_res^(0.1*(temp-Tref))
  tau_mort = Q10_m^(0.1*(temp-Tref))

  Iprime = Istar * tau_I
  f_light = 1-exp(-Io/Iprime)

  rho = tau_phy * f_light * mustar

  mort = mstar*ifelse(temp<Tref,ifelse(temp<5, 1, 1),tau_mort)
  
  resp = pi*rho + (1-pi)*rstar*tau_res

  fr =  rho - mort - resp - lambda 
  all.fr = rbind(all.fr,fr)
  #lines(temp,fr,col=alpha('#7375f7',0.05),lwd=0.5)
}

all.sd = apply(all.fr,2,sd)
all.mean = colMeans(all.fr)

lines(temp,tau_I,col=alpha('tomato',0.75),lwd=1,lty='31')
lines(temp,tau_phy,col=alpha('dodgerblue',0.75),lwd=1,lty='22')
lines(temp,tau_res,col=alpha('yellow3',0.75),lwd=1,lty='42')
lines(temp,tau_mort,col=alpha('purple',0.75),lwd=1,lty='33')

polygon(c(temp,rev(temp)),c(all.mean+all.sd,rev(all.mean-all.sd)),lwd=NULL,col=alpha('black',0.25),border=NA)
lines(temp,all.mean,lwd=2,col='black')

labl = c('Total growth rate',
  'Optimal light ($\\tau_{I^*}$)',
  'Phytoplankton ($\\tau_{Phy}$)',
  'Respiration ($\\tau_{Res}$)',
  'Mortality ($\\tau_{m}$)'
  )

legend('bottomright',
       legend= TeX(sprintf(r'(%s)', labl)),
       lwd=c(2,1,1,1,1),
       lty=c('solid','31','22','42','33'),
       col=c('black',alpha('tomato',0.75),alpha('dodgerblue',0.75),alpha('yellow3',0.75),alpha('purple',0.75)),
       cex=0.75,
       bty='n'
)



plot(temp,0*temp,type='n',xlab='temperature, ºC',ylab=TeX('phytoplankton growth rate, d$^{-1}$'),ylim=c(-0.,1.2))
the.sd = 0.05
text(0,1.2,'d ',adj=c(0,1),cex=1.3,font=2)

all.fr = NULL
for(i in 1:200){
  Io = 150*(1+rnorm(1,mean=0,sd=the.sd))
  Istar = 30*(1+rnorm(1,mean=0,sd=the.sd))
  mustar = 1.733*(1+rnorm(1,mean=0,sd=the.sd))
  mstar = .33*(1+rnorm(1,mean=0,sd=the.sd))
  rstar = .368*(1+rnorm(1,mean=0,sd=the.sd))
  pi = 0.02*(1+rnorm(1,mean=0,sd=the.sd))
  lambda = .0*(1+rnorm(1,mean=0,sd=the.sd))
  Tref = 20*(1+rnorm(1,mean=0,sd=the.sd))
  
  Q10_I = 1.3
  Q10_phy = 1.020
  Q10_m = 1.0
  Q10_res = 1.0
  
  tau_I = Q10_I^(0.1*(temp-Tref))
  tau_phy = Q10_phy^(0.1*(temp-Tref))
  tau_res = Q10_res^(0.1*(temp-Tref))
  tau_mort = Q10_m^(0.1*(temp-Tref))
  
  Iprime = Istar * tau_I
  f_light = 1-exp(-Io/Iprime)
  
  rho = tau_phy * f_light * mustar
  
  mort = mstar*ifelse(temp<Tref,ifelse(temp<Tref, 3.5, 1),tau_mort)
  
  resp = pi*rho + (1-pi)*rstar*tau_res
  
  fr =  rho - mort - resp - lambda 
  all.fr = rbind(all.fr,fr)
  #lines(temp,fr,col=alpha('#7375f7',0.05),lwd=0.5)
}

all.sd = apply(all.fr,2,sd)
all.mean = colMeans(all.fr)

lines(temp,tau_I,col=alpha('tomato',0.75),lwd=1,lty='31')
lines(temp,tau_phy,col=alpha('dodgerblue',0.75),lwd=1,lty='22')
lines(temp,tau_res,col=alpha('yellow3',0.75),lwd=1,lty='42')
lines(temp,tau_mort,col=alpha('purple',0.75),lwd=1,lty='33')

polygon(c(temp,rev(temp)),c(all.mean+all.sd,rev(all.mean-all.sd)),lwd=NULL,col=alpha('black',0.25),border=NA)
lines(temp,all.mean,lwd=2,col='black')

dev.off()

############################
#############################
options(digits = 3)

pdf("./Q10_simple plot.pdf",
    width = 3.5/1, height = 3.5/1
)
par(mai=0.3*c(2,2.2,1,1),oma=0*c(1,1,1,1),las=1,cex=0.5)
par(mgp = c(2, 0.25, 0), tcl = 0.3,lend=1,mfrow=c(1,1)) 
plot(temp,1.12^((temp-20)/10),type='n',xlab='temperature, ºC',ylab=TeX('$\\tau_{K}(t)$'),ylim=c(-0.,1.2),col='dodgerblue',lwd=3)

q10_values = c(1.04, 1.12, 1.2, 1.48, 4.4)
q10_colors = hcl.colors(length(q10_values), palette = "Sunset", rev = F)

for (i in length(q10_values):1) {
  lines(temp, q10_values[i]^((temp-20)/10), type='l', lwd=1+0.5*i, col=q10_colors[i])
}

legend('right',
       title = TeX('$Q_{10}$'),
       legend=  q10_values,
       lwd=1+0.5*(1:length(q10_values)),
       col=q10_colors,
       cex=0.75,
       bty='n'
)

abline(v=20,lty=3,lwd=0.5,col='gray')
text(20,.1,TeX('$T^*=20 ^{o} C$'),adj=c(0,1),cex=1.,col='gray')
text(0,1.2,'a ',adj=c(0,1),cex=1.3,font=2)



temp=seq(0,40,by=0.1)
the.sd = 0.1
all.fr = NULL
for(i in 1:200){
  Io = 150*(1+rnorm(1,mean=0,sd=the.sd))
  Istar = 50*(1+rnorm(1,mean=0,sd=the.sd))
  mustar = 1.2*(1+rnorm(1,mean=0,sd=the.sd))
  mstar = 0.5*(1+rnorm(1,mean=0,sd=the.sd))
  rstar = .036*(1+rnorm(1,mean=0,sd=the.sd))
  pi = 0.065*(1+rnorm(1,mean=0,sd=the.sd))
  lambda = .01*(1+rnorm(1,mean=0,sd=the.sd))
  Tref = 26*(1+rnorm(1,mean=0,sd=the.sd))
  
  Q10_I = 1.04
  Q10_phy = 1.20
  Q10_m = 4.40
  Q10_res = 1.10
  
  tau_I = Q10_I^(0.1*(temp-Tref))
  tau_phy = Q10_phy^(0.1*(temp-Tref))
  tau_res = Q10_res^(0.1*(temp-Tref))
  tau_mort = Q10_m^(0.1*(temp-Tref))
  
  Iprime = Istar * tau_I
  f_light = 1-exp(-Io/Iprime)
  
  rho = tau_phy * f_light * mustar
  
  mort = mstar*ifelse(temp<Tref,ifelse(temp<5, 1, 1),tau_mort)
  
  resp = pi*rho + (1-pi)*rstar*tau_res
  
  fr =  rho - mort - resp - lambda 
  all.fr = rbind(all.fr,fr)
  #lines(temp,fr,col=alpha('#7375f7',0.05),lwd=0.5)
}

all.sd = apply(all.fr,2,sd)
all.mean = colMeans(all.fr)

plot(temp,1.12^((temp-20)/10),type='n',xlab='temperature, ºC',ylab=TeX('phytoplankton growth rate $d^{-1}$'),
     ylim=c(-0.,.7),col='dodgerblue',lwd=3)

data = read.csv("~/tools/dobgcp/testcases/temperaure-sensitivity/data/source2.csv",comment.char = '#')
data = subset(data,group=='Dinoflagellates')
#data = subset(data,name=='Prorocentrum minimum')
data = aggregate(data,by=list(data$temperature),mean)
text(0,.7,'b ',adj=c(0,1),cex=1.3,font=2)
polygon(c(temp,rev(temp)),c(all.mean+all.sd,rev(all.mean-all.sd)),
        lwd=NULL,col=alpha('black',0.125),border=NA)
lines(temp, all.mean,lwd=3,col='white')
points(data$temperature,data$r,col='black',cex=0.5,pch=15)

dev.off()
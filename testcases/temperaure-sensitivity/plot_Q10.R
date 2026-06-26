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

  rect(min,.1,max,0, col=NA, border='black', lwd=1)
  for (i in 1:(length(lut)-0)) {
    y = (i-1)/scale + min
    rect(y,.1,y+1/scale,0, col=lut[i], border=NA)
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
temp_dir = "temp"
baseline_file = file.path(temp_dir, "output_baseline.nc")
pattern_q10 = "^output_Q10_([A-Za-z0-9]+)_x(0p8|1p2)\\.nc$"
out_pdf = "Q10_difference_comparison.pdf"
out_pdf_heatmap = "Q10_difference_annual_mean_heatmap.pdf"
# --------------------

target_vars = c(
  "oxypom_DOxy",
  "oxypom_AIR",
  "oxypom_x_min",
  "oxypom_x_nit",
  "oxypom_x_denit",
  "oxypom_x_res",
  "oxypom_x_npp"
)

target_labels = c(
  oxypom_DOxy = "Oxygen",
  oxypom_AIR = "Re-aeration",
  oxypom_x_min = "Mineralization",
  oxypom_x_nit = "Nitrification",
  oxypom_x_denit = "Denitrification",
  oxypom_x_res = "Respiration",
  oxypom_x_npp = "Photosynthesis"
)

target_units = c(
  oxypom_DOxy = "mmol O2 m-3",
  oxypom_AIR = "mmol O2 m-2 d-1",
  oxypom_x_min = "mmol O2 m-2 d-1",
  oxypom_x_nit = "mmol O2 m-2 d-1",
  oxypom_x_denit = "mmol O2 m-2 d-1",
  oxypom_x_res = "mmol O2 m-2 d-1",
  oxypom_x_npp = "mmol O2 m-2 d-1"
)

# Load one variable and return a time series with consistent units.
extract_series = function(nc, var_name, h = NULL) {
  x = ncvar_get(nc, var_name)

  if (var_name == "oxypom_AIR") {
    return(as.numeric(x))
  }

  if (is.null(dim(x))) {
    return(as.numeric(x))
  }

  if (length(dim(x)) == 2) {
    if (var_name == "oxypom_DOxy") {
      return(colMeans(x))
    }
    if (startsWith(var_name, "oxypom_x_")) {
      if (is.null(h)) stop("Layer thickness 'h' is required for depth-integrated fluxes.")
      return(colSums(x * h))
    }
    return(colMeans(x))
  }

  # Fallback for unexpected dimensions.
  apply(x, MARGIN = length(dim(x)), FUN = mean)
}

safe_delta = function(scenario, baseline) {
  n = min(length(scenario), length(baseline))
  # 100*c((scenario[1:n] - baseline[1:n])/(baseline[1:n] + 1e-6))
  #c(scenario[1:n] - baseline[1:n])
  200*c((scenario[1:n] - baseline[1:n])/(scenario[1:n] + baseline[1:n]))
}

if (!file.exists(baseline_file)) {
  stop(paste0("Baseline file not found: ", baseline_file))
}

all_nc = list.files(temp_dir, pattern = "^output_.*\\.nc$", full.names = TRUE)
q10_files = all_nc[grepl(pattern_q10, basename(all_nc))]

if (length(q10_files) == 0) {
  stop("No Q10 scenario files were found in temp/.")
}

meta = regmatches(basename(q10_files), regexec(pattern_q10, basename(q10_files)))
param = vapply(meta, function(m) m[2], character(1))
factor_label = vapply(meta, function(m) m[3], character(1))
# "het" "het" "Ioi" "Ioi" "min" "min" "mno" "mno" "pri" "pri" "res" "res" "vbs" "vbs" "vin" "vin"
param = c( "m","m","I^*","I^*","\\textrm{Min}", "\\textrm{Min}", "\\textrm{Nit}", "\\textrm{Nit}", "\\textrm{Phy}", "\\textrm{Phy}", "\\textrm{Res}","\\textrm{Res}","n","n","B","B")
param = paste0("$Q_{10,", param, "}$")

ord = order(param, factor_label)
q10_files = q10_files[ord]
param = param[ord]
factor_label = factor_label[ord]

ncb = nc_open(baseline_file)
h_base = ncvar_get(ncb, "h")

baseline_series = lapply(target_vars, function(v) extract_series(ncb, v, h_base))
names(baseline_series) = target_vars

temperature = colMeans(ncvar_get(ncb, "temp"))
ntime = length(temperature)
x = as.Date(seq_len(ntime), origin = "2020-01-01")

scenario_ids = paste0(param, "_", factor_label)
scenario_order = unique(scenario_ids)
# scenario_colors = setNames(hcl.colors(length(unique(param)), "spec"), unique(param))

scenario_colors = setNames(colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))(length(unique(param))), unique(param)) 


delta_data = list()
for (i in seq_along(q10_files)) {
  ncs = nc_open(q10_files[i])
  hs = ncvar_get(ncs, "h")

  sid = scenario_ids[i]
  delta_data[[sid]] = list()
  delta_data[[sid]]$param = param[i]
  delta_data[[sid]]$factor = factor_label[i]

  for (v in target_vars) {
    s = extract_series(ncs, v, hs)
    b = baseline_series[[v]]
    delta_data[[sid]][[v]] = safe_delta(s, b)
  }

  nc_close(ncs)
}

facets = c("0p8", "1p2")
pdf(out_pdf, width = 12, height = 8)
par(mfrow = c((1+length(target_vars))%/%2, 2*length(facets)))

par(mai = 0.1 * c(2.3, 5.2, 1.6, 0.9), oma = c(2, 1, 2, 0.5), las = 1, cex = 0.62)
par(mgp = c(2, 0.35, 0), tcl = 0.3)

for (v in target_vars) {
  for (f in facets) {
    ids = scenario_order[grepl(paste0("_", f, "$"), scenario_order)]
    if (length(ids) == 0) {
      plot.new()
      title(main = paste0("No scenarios found for x", f), cex.main = 0.9)
      next
    }

    ys = lapply(ids, function(id) delta_data[[id]][[v]])
    y_all = unlist(ys)
    yl = pretty(range(y_all, finite = TRUE))
    if (length(yl) > 1) {
      ylim = c(min(yl), max(yl))
    } else {
      ylim = c(-1, 1)
    }

    plot(x, rep(NA_real_, length(x)),
         type = "n",
         ylim = ylim,
         xlab = NA,
         ylab = TeX(paste0('$', units.to.latex(target_units[[v]]), '$')),
         xaxt = "n")

    for (id in ids) {
      p = delta_data[[id]]$param
      lines(x, delta_data[[id]][[v]], col = alpha(scenario_colors[[p]], 0.9), lwd = 2)
    }

    abline(h = 0, lwd = 0.7, lty = 2, col = "#555555")
    plot.xaxis(0)
    title(main = paste0(target_labels[[v]], "  (x",  100*as.numeric(gsub("p", ".", f)), "% - baseline)"), adj = 0, cex.main = 1)

    # Overlay normalized temperature to facilitate interpretation against seasonality.
    # t_scaled = (temperature - min(temperature)) / (max(temperature) - min(temperature) + 1e-9)
    # t_plot = ylim[1] + t_scaled * diff(ylim)
    # lines(x, t_plot, col = alpha(temp.color, 0.75), lwd = 0.9, lty = "91")
  }
}

plot.new()
legend("topleft",
  bty = "n",
  ncol = 1,
  legend = TeX(sprintf(r'(%s)', unique(param))),
  lwd = rep(3/1.33, length(unique(param))),
  lty = rep(1, length(unique(param))),
  col = scenario_colors[unique(param)],
  cex = 1.33)


#mtext("Q10 sensitivity: scenario minus baseline", side = 3, outer = TRUE, line = 0.5, cex = 1.1)
dev.off()

# Additional plot (added without changing existing layout):
# one page per affected variable, panels by Q10 parameter, lines by scenario factor.
out_pdf_by_parameter = "Q10_difference_comparison_by_parameter.pdf"
params_by_parameter = unique(param)
facets_by_parameter = c("0p8", "1p2")
scenario_line_colors = c("0p8" = "#1e61a3", "1p2" = "#c02626")
scenario_line_types = c("0p8" = 1, "1p2" = 1)

pdf(out_pdf_by_parameter, width = 12, height = 8)

for (v in target_vars) {
  n_panels = length(params_by_parameter) + 1
  ncols = 3
  nrows = ceiling(n_panels / ncols)

  par(mfrow = c(nrows, ncols))
  par(mai = 0.1 * c(2.3, 5.2, 1.6, 0.9), oma = c(2, 1, 2, 0.5), las = 1, cex = 0.62)
  par(mgp = c(2, 0.35, 0), tcl = 0.3)

  for (p in params_by_parameter) {
    ids = paste0(p, "_", facets_by_parameter)
    ids = ids[ids %in% names(delta_data)]

    if (length(ids) == 0) {
      plot.new()
      title(main = paste0("No scenarios for ", gsub("\\$", "", p)), cex.main = 0.9)
      next
    }

    ys = lapply(ids, function(id) delta_data[[id]][[v]])
    y_all = unlist(ys)
    yl = pretty(range(y_all, finite = TRUE))
    if (length(yl) > 1) {
      ylim = c(min(yl), max(yl))
    } else {
      ylim = c(-1, 1)
    }

    plot(x, rep(NA_real_, length(x)),
         type = "n",
         ylim = ylim,
         xlab = NA,
         ylab = TeX(paste0('$', units.to.latex(target_units[[v]]), '$')),
         xaxt = "n")

    for (id in ids) {
      f = sub("^.*_", "", id)
      lines(x,
            delta_data[[id]][[v]],
            col = alpha(scenario_line_colors[[f]], 0.9),
            lwd = 2,
            lty = scenario_line_types[[f]])
    }

    abline(h = 0, lwd = 0.7, lty = 2, col = "#555555")
    plot.xaxis(0)
    title(main = TeX(paste0(target_labels[[v]], "  -  ", p)), adj = 0, cex.main = 1)
  }

  plot.new()
  legend("topleft",
    bty = "n",
    ncol = 1,
    legend = paste0("x", 100 * as.numeric(gsub("p", ".", facets_by_parameter)), "%"),
    lwd = c(3/1.33, 3/1.33),
    lty = scenario_line_types[facets_by_parameter],
    col = scenario_line_colors[facets_by_parameter],
    cex = 1.33)
}

dev.off()

# Annual-mean summary heatmap per Q10 factor.
params = unique(param)
facets = c("0p8", "1p2")

heat_values = list()
for (f in facets) {
  mat = matrix(NA_real_,
               nrow = length(params),
               ncol = length(target_vars),
               dimnames = list(params, target_vars))

  for (p in params) {
    sid = paste0(p, "_", f)
    if (!is.null(delta_data[[sid]])) {
      for (v in target_vars) {
        mat[p, v] = mean(delta_data[[sid]][[v]], na.rm = TRUE)
      }
    }
  }
  heat_values[[f]] = mat
}

all_heat = unlist(heat_values)
zmax = max(abs(all_heat), na.rm = TRUE)
if (!is.finite(zmax) || zmax <= 0) zmax = 1

zbreaks = seq(-zmax, zmax, length.out = length(col.scale.diff) + 1)

pdf(out_pdf_heatmap, width = 8, height = 4)
layout(matrix(c(1, 2), nrow = 1), widths = c(1, 1))

par(mai = c(1.25, 1., 0.5, 0.5), las = 2, cex = 0.8)
for (f in facets) {
  mat = heat_values[[f]]
  image(x = seq_len(ncol(mat)),
        y = seq_len(nrow(mat)),
        z = t(mat[nrow(mat):1, , drop = FALSE]),
        col = col.scale.diff,
        breaks = zbreaks,
        xaxt = "n",
        yaxt = "n",
        xlab = "",
        ylab = "",
        zlim = c(-zmax, zmax),
        useRaster = TRUE)

  axis(1, at = seq_len(ncol(mat)), labels = target_labels[colnames(mat)], tick = FALSE)
  axis(2, at = seq_len(nrow(mat)), labels = TeX(sprintf(r'(%s)',rev(rownames(mat)))), tick = FALSE)
  title(main = paste0("Annual mean relative difference (% D) \n (", formatC(100*as.numeric(gsub("p", ".", f))-100, flag = "+",format = "f", digits = 0), "% - reference)"), cex.main = 1)

  for (i in seq_len(nrow(mat))) {
    for (j in seq_len(ncol(mat))) {
      val = mat[nrow(mat) - i + 1, j]
      txt_col = ifelse(abs(val) > 0.65 * zmax, "white", "black")
      text(j, i, labels = sprintf("%.2f", val), cex = 0.75, col = txt_col)
    }
  }

  box(col = "#444444", lwd = 0.8)
}

dev.off()

nc_close(ncb)


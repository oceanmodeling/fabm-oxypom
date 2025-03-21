# SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

if (!require("ncdf4")) install.packages("ncdf4")

################################################################################
## definition of local functions

get.year = function(...) format(as.Date(..., format = "%d/%m/%Y"), "%Y")
as.POSIXct = function(...) base::as.POSIXct(..., format = "%Y-%m-%d %H:%M:%S")

################################################################################
## loading the results of gotm
nc_data = nc_open("output.nc")

is_oxypom = TRUE # True if OxyPOM is validated False if DiaMo is validated
if("diamo_PAR"%in%names(nc_data$var)) is_oxypom = FALSE # DiaMo is validated

temp = t(ncvar_get(nc_data, "temp"))

if(is_oxypom){
  oxy = t(ncvar_get(nc_data, "oxypom_DOxy"))
}else{
  oxy = t(ncvar_get(nc_data, "diamo_OXY"))
}

################################################################################
## loading observed values for temperature (temp) and dissolved oxygen (DO)

temp_obs_1 = read.delim("./data/FGG_Elbe_008!Wassertemperatur.txt", header = FALSE, comment.char = "#")
temp_obs_2 = read.delim("./data/FGG_Elbe_009!Wassertemperatur.txt", header = FALSE, comment.char = "#")
temp_obs_3 = read.delim("./data/LZ_AL!Wassertemperatur.txt", header = FALSE, comment.char = "#")

temp_obs_1$V1 = as.POSIXct(temp_obs_1$V1)
temp_obs_2$V1 = as.POSIXct(temp_obs_2$V1)
temp_obs_3$V1 = as.POSIXct(temp_obs_3$V1)

temp_obs_1 = subset(temp_obs_1, get.year(V1) >= 2004)
temp_obs_2 = subset(temp_obs_2, get.year(V1) >= 2004)
temp_obs_3 = subset(temp_obs_3, get.year(V1) >= 2004)

DO_obs_1 = read.delim("./data/FGG_Elbe_008!Sauerstoffgehalt_(Einzelmessung).txt", header = FALSE, comment.char = "#")
DO_obs_2 = read.delim("./data/FGG_Elbe_009!Sauerstoffgehalt_(Einzelmessung).txt", header = FALSE, comment.char = "#")

DO_obs_1$V1 = as.POSIXct(DO_obs_1$V1)
DO_obs_2$V1 = as.POSIXct(DO_obs_2$V1)

DO_obs_1 = subset(DO_obs_1, get.year(V1) >= 2004)
DO_obs_2 = subset(DO_obs_2, get.year(V1) >= 2004)

################################################################################
## plotting the data

x = 1:length(temp[,1])
x = as.Date(x, origin = "2006-01-01")

surface = length(temp[1,]) - 1 # layer number of the surface
bottom = 1 # layer number of the bottom

col_sim = "tomato"
col_sim_bottom = "pink"
col_obs = "black"
col_obs2 = "gray50"
col_obs3 = "gray50"


png(filename = "./estuary_validation.png",
    width = 800, height = 400)

par(mfrow = c(2,1), mai = c(0.42,0.42,0.21,0.21), oma = 2 * c(1, 1, 0.5, 0.5), las = 1)

plot(x, rowMeans(temp[,bottom:surface]), 
     type = "n",
     col = NA, 
     ylim = c(-5, 25), 
     log = "", 
     lwd = 0.5,
     ylab = "",
     xlab = "days"
     )

title("temperature at the surface degC", adj = 0, line = 0.1, cex = 0.5, font.main = 1)
points(as.Date(temp_obs_2$V1), temp_obs_2$V2, col = col_obs2, pch = 0,cex = .5)
lines(as.Date(temp_obs_3$V1), temp_obs_3$V2, col = col_obs3, pch = 20,cex = 1)
points(as.Date(temp_obs_1$V1), temp_obs_1$V2, col = col_obs, pch = 20,cex = 1)
lines(x, temp[,bottom], lty = 1, col = col_sim_bottom)
lines(x, temp[,surface], lty = 1, col = col_sim, lwd=2)

cf = 1000/32 # conversion factor of mg L-1 to mmol-O2 L

plot(x, rowMeans(oxy[,1:2]),
     type = "n",
     col = NA,ylim = c(100, 500),
     log = "", 
     lwd = 0.5,
     ylab = "",
     xlab = "days",
     )

title("dissolved oxygen concentration mmol-O2 L-1", adj = 0, line = 0.1, cex = 0.5, font.main = 1)
points(as.Date(DO_obs_2$V1), (1000 / 32) * DO_obs_2$V2, col = col_obs2, pch = 0, cex = .5)
points(as.Date(DO_obs_1$V1), cf * DO_obs_1$V2, col = col_obs, pch = 20, cex = 1)
lines(x, oxy[,bottom], lty = 1, col = col_sim_bottom)
lines(x, oxy[,surface], lty = 1, col = col_sim, lwd = 2)

legend("bottomleft",
       cex = 1,
       legend = c("E9-obs", "E8-obs", "AL-obs", "surface-sim", "bottom-sim"),
       bty = "n",
       horiz = T,
       border = NA,
       pt.cex = c(.5, 1, NA, NA, NA),
       col=c(col_obs2, col_obs, col_obs3, col_sim, col_sim_bottom),
       pch = c(0, 20, 0, 0,0),
       pt.lwd=c(1, 1, 1, 1, 1),
       lwd=c(0, 0, 1, 2, 1)
       )

dev.off()
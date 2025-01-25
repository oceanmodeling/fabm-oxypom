library(ncdf4)

# Open the existing NetCDF file
nc_file_0 = nc_open("./original.rivers.u_020e-2.nc", write = T)

# Get dimensions from an existing variable
dim1 = ncvar_get(nc_file_0, "reast")
n_dim1 = length(dim1)
time =  list(nc_file_0$dim[[1]])
days = 1+as.integer(time[[1]]$vals/(60*60*24))%%365

# get forcing datafiles
flow = read.csv("./flow.txt", header=FALSE, comment.char="#")
temp = read.csv("./temp.txt", header=FALSE, comment.char="#")
oxygen = read.csv("./oxygen.txt", header=FALSE, comment.char="#")
phyto = read.csv("./alg-carbon.txt", header=FALSE, comment.char="#")
DOC = read.csv("./DOC.txt", header=FALSE, comment.char="#")
POC = read.csv("./POC.txt", header=FALSE, comment.char="#")
NH4 = read.csv("./ammonia.txt", header=FALSE, comment.char="#")
NO3 = read.csv("./nitrate.txt", header=FALSE, comment.char="#")
PON = read.csv("./PON and DON.txt", header=FALSE, comment.char="#")
PO4 = read.csv("./phosphorus.txt", header=FALSE, comment.char="#")
POP = read.csv("./POP and DOP.txt", header=FALSE, comment.char="#")
Si = read.csv("./silicon.txt", header=FALSE, comment.char="#")


# Define a new variable
new_variable = c("reast",
                 "salt",
                 "temp",
                 "DOxy",
                 "ALG1",
                 "ALG2",
                 "DOC",
                 "POC1",
                 "POC2",
                 "NH4",
                 "NO3",
                 "DON",
                 "PON1",
                 "PON2",
                 "PO4",
                 "DOP",
                 "POP1",
                 "POP2",
                 "Si",
                 "OPAL"
  )

units = c("m3 s-1",
          "mg kg-1",
          "degree",
          "mmol O2 m-3",
          "mmol C m-3",
          "mmol C m-3",
          "mmol C m-3",
          "mmol C m-3",
          "mmol C m-3",
          "mmol N m-3",
          "mmol N m-3",
          "mmol N m-3",
          "mmol N m-3",
          "mmol N m-3",
          "mmol P m-3",
          "mmol P m-3",
          "mmol P m-3",
          "mmol P m-3",
          "mmol Si m-3",
          "mmol Si m-3"
          )

values = list(approxfun(flow,rule=2),
              function(x) return(0.5),
              approxfun(temp,rule=2),
              approxfun(oxygen,rule=2),
              approxfun(phyto$V1, 0.8*phyto$V2,rule=2),
              approxfun(phyto$V1, 0.2*phyto$V2,rule=2),
              approxfun(DOC,rule=2),
              approxfun(POC$V1, 0.8*POC$V2,rule=2),
              approxfun(POC$V1, 0.2*POC$V2,rule=2),
              approxfun(NH4,rule=2),
              approxfun(NO3,rule=2),
              approxfun(PON$V1, 0.8*PON$V2,rule=2),
              approxfun(PON$V1, 0.8*0.2*PON$V2,rule=2),
              approxfun(PON$V1, 0.2*0.2*PON$V2,rule=2),
              approxfun(PO4,rule=2),
              approxfun(POP$V1, 0.8*POP$V2,rule=2),
              approxfun(POP$V1, 0.8*0.2*POP$V2,rule=2),
              approxfun(POP$V1, 0.2*0.2*POP$V2,rule=2),
              approxfun(Si,rule=2),
              function(x) return(0.01)
          )

N = length(new_variable)

for(i in 1:N){
  new_var_name = new_variable[i]
  if(new_var_name!='reast') new_var_name = paste0("reast_",new_variable[i])
  units = units[i]
  longname = ""
  new_var = ncvar_def(name = new_var_name, 
                       units = units, 
                       dim = time,  # Use existing dimensions
                       missval = NA, 
                       longname = longname)  
  # Add the new variable to the NetCDF file
  if(new_var_name=='reast') nc_file = nc_create('rivers.u_020e-2.bgc.nc',new_var)
  if(new_var_name!='reast') nc_file = ncvar_add(nc_file, new_var)
  
  # Write data to the new variable
  new_data = values[[i]](days)*(1+0.0*rnorm(n_dim1))  # the data with some jittering
  ncvar_put(nc_file, new_var, new_data)
  print(new_var_name)
}

# Close the NetCDF file
nc_close(nc_file)

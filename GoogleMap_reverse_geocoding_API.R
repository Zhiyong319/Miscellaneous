rm(list = ls())

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(httr)
library(jsonlite)

source('C:/Users/zwu/Programming/R/myRfunctions.R')

# myfile <- '../AMET/PAIRED_MODEL_OBS/sites_PBLH.csv'
# sites <- read.csv(myfile)
# sites$state <- NA
# sites$country <- NA 
load('C:/Users/zwu/Programming/AMET/pblh.Rdata')

# load('C:/Users/zwu/Programming/AMET/meteo.Rdata')

# load('C:/Users/zwu/Programming/AMET/PM25.Rdata')

API_Key <-"AIzaSyDQTtb7jaIlaykM1JfKmctFg8x-ncMw-GA" 

for (id in 1:nrow(sites)) {

  geocoding_url <- paste0("https://maps.googleapis.com/maps/api/geocode/json?latlng=",sites$Latitude[id],",",sites$Longitude[id],'&key=',API_Key)
  response <- GET(geocoding_url, content_type_json())
  
  if (response$status_code==200) {
    print(paste(sites$siteID[id],'GOOD!'))
  } else {
    print(paste(sites$siteID[id],'FAILED!!!'))
  }
  
  # convert raw data to char
  txt <- rawToChar(response$content)
  # txt <- content(response, as="text", encoding="UTF-8")
  
  # convert JSON data to list
  dat = fromJSON(txt,flatten=TRUE,simplifyVector =FALSE)
  
  # parse state and country info
  # compound_code <- strsplit(dat$plus_code$compound_code,",")
  # compound_code <- compound_code[[1]]
  # sites$state[id] <- compound_code[length(compound_code)-1] # the last second item
  # sites$country[id] <- compound_code[length(compound_code)] # the last item
  
  formatted_address <- strsplit(dat$results[[2]]$formatted_address,",")[[1]]
  sites$state[id] <- trimws(formatted_address[length(formatted_address)-1]) # the last second item
  sites$country[id] <- trimws(formatted_address[length(formatted_address)]) # the last item
}

### write data
# write.csv(sites,file=myfile) # over-write the original file

state <- strsplit(sites$state," ")
for (i in 1:length(state)) {
  sites$state[i] <- state[[i]][1]
}
sites$state <- state.name2abb(sites$state)

# assign a Regional Planning Organizations (RGO) region
VISTAS <- c('AL' , 'FL' , 'GA' , 'KY', 'MS', 'NC' , 'SC' , 'TN' , 'VA' , 'WV')
CENRAP <- c('NE' , 'KS' , 'OK' , 'TX' , 'MN' , 'IA' , 'MO' , 'AR' , 'LA')
MANE_VU<- c('CT' , 'DE' , 'DC' , 'ME' , 'MD' , 'MA' , 'NH' , 'NJ' , 'NY' , 'PA' , 'RI' , 'VT')
LADCO  <- c('IL' , 'IN' , 'MI' , 'OH' , 'WI')
WRAP   <- c('AK' , 'CA' , 'OR' , 'WA' , 'AZ' , 'NM' , 'CO' , 'UT' , 'WY' , 'SD' , 'ND' , 'MT' , 'ID' , 'NV')
RPO <- list(VISTAS=VISTAS, CENRAP=CENRAP, MANE_VU=MANE_VU, LADCO=LADCO, WRAP=WRAP)

sites$region <- NA
sites$region[sites$state %in% VISTAS] <- "VISTAS"
sites$region[sites$state %in% CENRAP] <- "CENRAP"
sites$region[sites$state %in% MANE_VU] <- "MANE_VU"
sites$region[sites$state %in% LADCO] <- "LADCO"
sites$region[sites$state %in% WRAP] <- "WRAP"

# 
# save(sites, RPO, meteo_obs_model_paired, meteo_model, meteo_obs, file='C:/Users/zwu/Programming/AMET/meteo.Rdata')

# save(sites, PM25_AQS, PM25_model, file='C:/Users/zwu/Programming/AMET/PM25.Rdata')

save(sites, RPO, pblh_obs, pblh_model,pblh_obs_1d, pblh_model_1d, pblh_obs_daily, pblh_obs_daily_1d,pblh_model_daily,pblh_model_daily_1d,
     file='C:/Users/zwu/Programming/AMET/PBLH.Rdata')
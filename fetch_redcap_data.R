# Based on:
# https://github.com/jenniferthompson/MOSAICProgress/blob/master/datamgmt_progress.R

## -- Import each data set from REDCap ----
## All tokens are stored in .Renviron

library(RCurl)
library(dplyr)

## 1. Function to create postForm() object given a database token
get_pF <- function(rctoken){
  postForm(
    'https://redcap.urmc.rochester.edu/redcap/api/', ## URL for REDCap instance
    token = Sys.getenv(rctoken),                ## token for specific database
    content = "record",                         ## export records
    format = "csv",                             ## export as CSV
    rawOrLabel = "label",                       ## exp. factor labels vs numbers
    exportCheckboxLabel = TRUE,                 ## exp. checkbox labels vs U/C
    exportDataAccessGroups = FALSE              ## don't need data access grps
  )
}

get_csv <- function(pF){
  read.csv(file = textConnection(pF), na.strings = "", stringsAsFactors = FALSE)
}

import_df <- function(rctoken){
  tmp_pF <- get_pF(rctoken)
  tmp_csv <- get_csv(tmp_pF)
  
  ## REDCap loves to use so many underscores; one per instance seems like plenty
  names(tmp_csv) <- gsub("_+", "_", names(tmp_csv))
  
  tmp_csv
}

crossling <- import_df("CROSSLING_KEY") %>% 
  select(record_id, ethnicity, race, sex) %>%
  mutate( # Can I use purrrr to do this to each with no duplication?
    sex = ifelse(is.na(sex), "Unknown or Not Reported", sex),
    race = case_when(
      is.na(race) ~ "Unknown or Not Reported",
      race == "Unknown / Not Reported" ~ "Unknown or Not Reported",
      TRUE ~ race
    ),
    ethnicity = case_when(
      is.na(ethnicity) ~ "Unknown or Not Reported",
      ethnicity == "Unknown / Not Reported" ~ "Unknown or Not Reported",
      TRUE ~ ethnicity),
    record_id = sprintf('lab%05d', record_id)
  )
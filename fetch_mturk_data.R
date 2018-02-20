library(readxl)
library(dplyr)

# This is just temporary as proof of concept. Need to get surveys into database
# and pull the info from that
mturk <- read_xlsx('crosslinguistic_report-2018-02-14.xlsx') %>% 
  select(workerid, Ethnicity, Race, Sex) %>% # want to replace workerid w/ UUID or something
  rename(sex = Sex) %>%
  mutate(
    ethnicity = case_when(
      Ethnicity == "NonHisp" ~ "NOT Hispanic or Latino",
      Ethnicity == "Hisp" ~ "Hispanic or Latino",
      TRUE ~ Ethnicity
    ),
    race = case_when(
      # fixing a typo, which hopefully can be resolved in future
      Race == "Native Hawiiian or Other Pacific Islander" ~ "Native Hawaiian or Other Pacific Islander",
      TRUE ~ Race
    )
  )
  
library(lubridate)
library(dplyr)
library(tidyr)
library(jsonlite)
library(purrr)
corona <- fromJSON("https://raw.githubusercontent.com/mediazona/data-corona-Russia/master/data.json")
data <- corona[[2]]
len <- length(data$confirmed[[1]])
lock_df <- data.frame(day = 1:len, lock = NA, dates = seq(from = mdy(corona[[1]]), by = "day", length.out = len))

data <- 
  data %>%
  mutate(lockdown = map(lockdown, function(x) {
    lock_mdf <- 
      lock_df %>% 
      left_join(x) %>%
      select("type", "dates") %>%
      fill("type", .direction = "down")
    lock_mdf
  })) %>%
  unnest(cols = c(confirmed, recovered, dead, lockdown), keep_empty = TRUE) %>%
  mutate(type = replace_na(type, "no")) %>%
  rename(lockdown = type) %>%
  select(name, dates, everything())

write.csv(data, "corona.csv", row.names = FALSE)
  

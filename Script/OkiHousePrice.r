library(dplyr)
library(ggplot2)
library(ggrepel)
library(tidyverse)

dir <- "E:/Dropbox (OIST)/Ishikawa Unit/Tsunghan/OkiHousePrice"
# dir <- "/Users/Tsunghan/Dropbox (OIST)/Ishikawa Unit/Tsunghan/OkiHousePrice"

raw <- read_csv(file.path(dir,"Raw","47_Okinawa Prefecture_20053_20211.csv"), locale = locale(encoding = "cp932"))

# Change column names to English
new_colnames <- c("No","Type","Land_type","City_code","Prefecture","City_name",
               "District_name","Closet_station","Min_closet_station","Price","Unit_price_pin","Room_numbe?",
               "Area_mm2","Unit_price_mm2","Land_shape","open_length","Building_area_mm2","Year_built",
               "Building_structure","Usage","Future_usage","Front_road_direction","Front_road_type","Front_road_open_length",
               "City_plan","Building_rate","Floor_area_ratio","Year_traded","Remodeled","Note")
colnames(raw) <- new_colnames

# Subsetting apartment for living
apartment <- raw %>%
  filter(Type == "’†ŒÃƒ}ƒ“ƒVƒ‡ƒ““™") %>%
  filter (Usage == "Z‘î") %>%
  separate(Year_traded, c("Year_traded", "Quarter_traded"), sep = "”N") %>%
  separate(Year_built, c("Year_built_Japanese1","Year_built_Japanese2"), sep = 2) %>%
  separate(Year_built_Japanese2, c("Year_built_Japanese2",NA), sep="”N")

# Add a new column for western years
apartment['Year_built_JapanesetoWestern']=0
apartment['Year_built_western']=0


# Japanese era to Western era
index1 <- apartment$Year_built_Japanese1 == "—ß˜a"
index2 <- apartment$Year_built_Japanese1 == "•½¬"
index3 <- apartment$Year_built_Japanese1 == "º˜a"
index4 <- apartment$Year_built_Japanese1 == "<U+6226>‘O" # The apartment built before war will be excluded from the analysis
apartment$Year_built_JapanesetoWestern[index1] <- 2018
apartment$Year_built_JapanesetoWestern[index2] <- 1988
apartment$Year_built_JapanesetoWestern[index3] <- 1925
apartment$Year_built_JapanesetoWestern[index4] <- 1911

apartment$Year_built_western = as.numeric(apartment$Year_built_Japanese2) + as.numeric(apartment$Year_built_JapanesetoWestern)


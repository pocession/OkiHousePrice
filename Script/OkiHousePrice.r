# This script is used for data clean and re-annotation 

library(dplyr)
library(ggrepel)
library(tidyverse)

# Turn off scientific notation
options(scipen = 999)

# dir <- "E:/Dropbox (OIST)/Ishikawa Unit/Tsunghan/OkiHousePrice"
dir <- "/Users/Tsunghan/Dropbox (OIST)/Ishikawa Unit/Tsunghan/OkiHousePrice"

raw <- read_csv(file.path(dir,"Raw","47_Okinawa Prefecture_20053_20211.csv"), locale = locale(encoding = "cp932"))

# Change column names to English
new_colnames <- c("No","Type","Land_type","City_code","Prefecture","City_name",
               "District_name","Closet_station","Min_closet_station","Price","Unit_price_py","Room_number",
               "Area_mm2","Unit_price_mm2","Land_shape","open_length","Building_area_mm2","Year_built",
               "Building_structure","Usage","Future_usage","Front_road_direction","Front_road_type","Front_road_open_length",
               "City_plan","Building_rate","Floor_area_ratio","Year_traded","Remodeled","Note")
colnames(raw) <- new_colnames

# Transform Japanese year to western year
raw2 <- raw %>%
  separate(Year_traded, c("Year_traded", "Quarter_traded"), sep = "年") %>%
  separate(Year_built, c("Year_built_Japanese1","Year_built_Japanese2"), sep = 2) %>%
  separate(Year_built_Japanese2, c("Year_built_Japanese2",NA), sep="年")

raw2['Year_built_JapanesetoWestern']=0
raw2['Year_built_western']=0

# Japanese era to Western era
index1 <- raw2$Year_built_Japanese1 == "令和"
index2 <- raw2$Year_built_Japanese1 == "平成"
index3 <- raw2$Year_built_Japanese1 == "昭和"
index4 <- raw2$Year_built_Japanese1 == "<U+6226>前" # The apartment built before war will be excluded from the analysis
raw2$Year_built_JapanesetoWestern[index1] <- 2018
raw2$Year_built_JapanesetoWestern[index2] <- 1988
raw2$Year_built_JapanesetoWestern[index3] <- 1925
raw2$Year_built_JapanesetoWestern[index4] <- 1911

raw2$Year_built_western = as.numeric(raw2$Year_built_Japanese2) + as.numeric(raw2$Year_built_JapanesetoWestern)

# Calculate age when they are traded
raw2['Age'] = as.numeric(raw2$Year_traded) - as.numeric(raw2$Year_built_western)

# > > 2000 and >5000 m2 will be transformed to 2000 and 5000, respectively
index5 <- raw2$Area_mm2 == "2000\u33a1\u4ee5\u4e0a"
raw2$Area_mm2[index5] <- 2000
index6 <- raw2$Area_mm2 == "5000\u33a1\u4ee5\u4e0a"
raw2$Area_mm2[index6] <- 5000

# Calculate unit price (based on py)
raw2$Unit_price_py = (as.numeric(raw2$Price) / as.numeric(raw2$Area_mm2)) * 3.305785124

# Geo information
geo <- read_csv(file.path(dir,"Raw","City_geo.csv"), locale = locale(encoding = "utf-8"))

# Subsetting used apartment for living
apartment <- raw2 %>%
  filter(Type == "中古マンション等") %>%
  filter (Usage == "住宅")

# Subsetting land + building
land_build <- raw2 %>%
  filter(Type == "宅地(土地と建物)") %>%
  filter(Land_type == "住宅地")

# Save the used apartment data frame
write.csv(apartment,file=file.path(dir,"Wranggled","Apartment_Wranggled.csv"), row.names=FALSE, fileEncoding = "cp932")

# Save the land+building file
write.csv(land_build,file=file.path(dir,"Wranggled","Land_building_Wranggled.csv"), row.names=FALSE, fileEncoding = "cp932")

# Save the raw file
write.csv(raw2,file=file.path(dir,"Wranggled","OkiHousePrice_Wranggled.csv"), row.names=FALSE, fileEncoding = "cp932")


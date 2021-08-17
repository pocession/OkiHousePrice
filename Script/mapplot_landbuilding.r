library(ggmap)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(ggplot2)

# dir <- "/Users/Tsunghan/Dropbox (OIST)/Ishikawa Unit/Tsunghan/OkiHousePrice/"
dir <- "E:/Dropbox (OIST)/Ishikawa Unit/Tsunghan/OkiHousePrice"
raw <- read.csv(file.path(dir,"Wranggled","Land_building_Wranggled.csv"),encoding="cp932")

# Remove outliers
df <- raw %>%
  filter(Unit_price_py/10000 < 250) %>%
  filter(Age > 0 && Age < 60)


df <- raw %>%
  select(City_name_en,Unit_price_py,lon,lat)

result <- df %>%
  group_by(City_name_en,lon,lat) %>%
  summarise(median(Unit_price_py))

colnames(result) <- c("City_name_en","lon","lat","median")

map <- get_map(location = c(lon = 128, lat = 26.45), maptype = "roadmap", zoom = 10)
ggmap(map) + geom_point(aes(x = lon, y = lat, size = median/10000), data = result, colour = "red", alpha = 0.5)
ggsave(file.path(dir,"Result","City_Unit_Price.png"),dpi=300)

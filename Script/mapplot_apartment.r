library(ggmap)
library(ggplot2)
library(dplyr)
library(tidyverse)

dir <- "/Users/Tsunghan/Dropbox (OIST)/Ishikawa Unit/Tsunghan/OkiHousePrice/"
# dir <- "E:/Dropbox (OIST)/Ishikawa Unit/Tsunghan/OkiHousePrice"
raw <- read.csv(file.path(dir,"Raw","apartment.csv"),encoding="cp932")

apartment <- raw %>%
  select(City_name,Year_traded,UnitPricePy_corrected_byHouseAge) %>%
  na.omit()

# Only 4 cities have trade records about old apartment since 2006

# City geo information
geo <- read_csv(file.path(dir,"Raw","City_geo.csv"), locale = locale(encoding = "utf-8"))

traded_count <- apartment %>%
  count(City_name)
traded_count <- left_join(traded_count,geo, by = "City_name")

traded_2007 <- apartment %>%
  filter(Year_traded == 2007) %>%
  group_by(City_name) %>%
  summarise(median(UnitPricePy_corrected_byHouseAge))
traded_2007 <- left_join(traded_2007,geo, by = "City_name")
colnames(traded_2007) <- c("City_name","Median","longitude","lantitude")

traded_2020 <- apartment %>%
  filter(Year_traded == 2020) %>%
  group_by(City_name) %>%
  summarise(median(UnitPricePy_corrected_byHouseAge))
traded_2020 <- left_join(traded_2020,geo, by = "City_name")
colnames(traded_2020) <- c("City_name","Median","longitude","lantitude")
traded_2020$growth_rate <- 100*((traded_2020$Median - traded_2007$Median) / traded_2007$Median)

# Provide the API key to Google
register_google(key = "my_key",write=TRUE)

# okinawa <- c(left = 127.5, bottom = 26, right = 128.5, top = 27)
# get_stamenmap(okinawa, zoom = 11, maptype = "toner-lite") %>% ggmap() 
# qmap("Okinawa")

map <- get_map(location = c(lon = 128, lat = 26.47), maptype = "roadmap", zoom = 10)
ggmap(map) + geom_point(aes(x = longitude, y = lantitude, size = n), data = traded_count)
ggsave(file.path(dir,"Result","Tradednumeber_location.png"),dpi=300)

ggmap(map) + geom_point(aes(x = longitude, y = lantitude, size = (Median / 10000)), data = traded_2020) + labs(title = "age-adjusted unit price, x 10000 yen per py")
ggsave(file.path(dir,"Result","Traded2020_location.png"),dpi=300)

ggmap(map) + geom_point(aes(x = longitude, y = lantitude, size = growth_rate), data = traded_2020) + labs(title = "age-adjusted growth rate, base year = 2007")
ggsave(file.path(dir,"Result","Traded2020_growthrate.png"),dpi=300)

ggmap(map) + geom_point(aes(x = longitude, y = lantitude, size = median(UnitPricePy_corrected_byHouseAge)), data = traded_2020)
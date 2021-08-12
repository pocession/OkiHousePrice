library(ggmap)
library(mapproj)
library(ggplot2)

dir <- "E:/Dropbox (OIST)/Ishikawa Unit/Tsunghan/OkiHousePrice"
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

traded_2020 <- apartment %>%
  filter(Year_traded == 2020) %>%
  group_by(City_name) %>%
  summarise(median(UnitPricePy_corrected_byHouseAge))
traded_2020 <- left_join(traded_2020,geo, by = "City_name")

traded_2007 <- apartment %>%
  filter(Year_traded == 2007) %>%
  group_by(City_name) %>%
  summarise(median(UnitPricePy_corrected_byHouseAge))
traded_2007 <- left_join(traded_2007,geo, by = "City_name")


# Provide the API key to Google
register_google(key = "My_key",write=TRUE)

# okinawa <- c(left = 127.5, bottom = 26, right = 128.5, top = 27)
# get_stamenmap(okinawa, zoom = 11, maptype = "toner-lite") %>% ggmap() 
# qmap("Okinawa")

map <- get_map(location = c(lon = 128, lat = 26.47), maptype = "toner-lines", zoom = 10)
ggmap(map) + geom_point(aes(x = longitude, y = lantitude, size = n), data = traded_count)
ggsave(file.path(dir,"Result","Traded_location.png"))
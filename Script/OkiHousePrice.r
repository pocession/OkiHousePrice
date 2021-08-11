library(ggplot2)
library(dplyr)
library(ggrepel)
library(tidyverse)

# Turn off scientific notation
options(scipen = 999)

dir <- "E:/Dropbox (OIST)/Ishikawa Unit/Tsunghan/OkiHousePrice"
# dir <- "/Users/Tsunghan/Dropbox (OIST)/Ishikawa Unit/Tsunghan/OkiHousePrice"

raw <- read_csv(file.path(dir,"Raw","47_Okinawa Prefecture_20053_20211.csv"), locale = locale(encoding = "cp932"))

# Change column names to English
new_colnames <- c("No","Type","Land_type","City_code","Prefecture","City_name",
               "District_name","Closet_station","Min_closet_station","Price","Unit_price_py","Room_number",
               "Area_mm2","Unit_price_mm2","Land_shape","open_length","Building_area_mm2","Year_built",
               "Building_structure","Usage","Future_usage","Front_road_direction","Front_road_type","Front_road_open_length",
               "City_plan","Building_rate","Floor_area_ratio","Year_traded","Remodeled","Note")
colnames(raw) <- new_colnames

# Subsetting apartment for living
apartment <- raw %>%
  filter(Type == "中古マンション等") %>%
  filter (Usage == "住宅") %>%
  separate(Year_traded, c("Year_traded", "Quarter_traded"), sep = "年") %>%
  separate(Year_built, c("Year_built_Japanese1","Year_built_Japanese2"), sep = 2) %>%
  separate(Year_built_Japanese2, c("Year_built_Japanese2",NA), sep="年")

#?Add a new column for western years
apartment['Year_built_JapanesetoWestern']=0
apartment['Year_built_western']=0


# Japanese era to Western era
index1 <- apartment$Year_built_Japanese1 == "令和"
index2 <- apartment$Year_built_Japanese1 == "平成"
index3 <- apartment$Year_built_Japanese1 == "昭和"
index4 <- apartment$Year_built_Japanese1 == "<U+6226>前" # The apartment built before war will be excluded from the analysis
apartment$Year_built_JapanesetoWestern[index1] <- 2018
apartment$Year_built_JapanesetoWestern[index2] <- 1988
apartment$Year_built_JapanesetoWestern[index3] <- 1925
apartment$Year_built_JapanesetoWestern[index4] <- 1911

apartment$Year_built_western = as.numeric(apartment$Year_built_Japanese2) + as.numeric(apartment$Year_built_JapanesetoWestern)

# Calculate house age when they are traded
apartment['House_age'] = as.numeric(apartment$Year_traded) - as.numeric(apartment$Year_built_western)

# Calculate unit price (based on py)

apartment$Unit_price_py = (as.numeric(apartment$Price) / as.numeric(apartment$Area_mm2)) * 3.305785124

# Check the relationship between Unit_Price_py and year (uncorrected)
lmUnitPricePy0 = lm(as.numeric(apartment$Unit_price_py / 10000)~as.numeric(apartment$Year_traded)) #Create the linear regression
summary(lmUnitPricePy0)

p0 <- ggplot(apartment, aes(x=as.numeric(Year_traded), y=as.numeric(apartment$Unit_price_py / 10000))) + 
  geom_smooth(method=lm , color="red", se=TRUE) + 
  geom_point( color="#69b3a2") + 
  geom_text(x = 2010, y = 400, label = "Fig. 1: Unit price (per 10,000 yen) = 5.4975* (Year) -10976.2874\nR2 = 0.1745") +
  labs(x = "House age", y = "Unit price (per 10,000 yen)")
p0
ggsave(file.path(dir,"Result","Unit_year.png"))

# Check the relationship between House age and Unit_Price_py
lmUnitPricePy1 = lm(as.numeric(apartment$Unit_price_py / 10000)~as.numeric(apartment$House_age)) #Create the linear regression
summary(lmUnitPricePy1)

p1 <- ggplot(apartment, aes(x=as.numeric(House_age), y=as.numeric(apartment$Unit_price_py / 10000))) + 
  geom_smooth(method=lm , color="red", se=TRUE) + 
  geom_point( color="#69b3a2") + 
  geom_text(x = 15, y = 400, label = "Fig2: Unit price (per 10,000 yen) = -3.08182* (House age) + 146.03379\nR2=0.3829") +
  labs(x = "House age", y = "Unit price (per 10,000 yen)")
p1
ggsave(file.path(dir,"Result","Unit_age.png"))

# Check the relationship between Unit price and year
lmUnipricePy2 = lm(as.numeric(apartment$Unit_price_py/10000)~as.numeric(apartment$Year_traded)+as.numeric(apartment$House_age))
summary(lmUnipricePy2)

# Corrected the house price by house age
apartment$UnitPricePy_corrected_byHouseAge <- as.numeric(apartment$Unit_price_py) - 3.40420*as.numeric(apartment$House_age)

p2 <- ggplot(apartment, aes(x=as.numeric(Year_traded), y=as.numeric(apartment$UnitPricePy_corrected_byHouseAge / 10000))) + 
  geom_smooth(method=lm , color="red", se=TRUE) + 
  geom_point( color="#69b3a2") + 
  geom_text(x = 2012, y = 400, label = "Fig3: Unit price (per 10,000 yen) = 6.64967* (Year) - 3.40420*(House Age) - 13240.10350\nR2 = 0.6378") +
  labs(x = "Year", y = "Unit price (per 10,000 yen, controlled by house age)")
p2
ggsave(file.path(dir,"Result","Unit_year_corrected.png"))

# Annual growth rate
year_growth <- apartment %>%
  select(Year_traded,UnitPricePy_corrected_byHouseAge) %>%
  na.omit() %>%
  group_by(Year_traded) %>%
  summarise(median(UnitPricePy_corrected_byHouseAge))

colnames(year_growth) <- c("Year_traded", "Median")
year_growth$previous <- lag(year_growth$Median)
year_growth$annual_growth <- (year_growth$Median - year_growth$previous) / year_growth$previous
year_growth$base <- (year_growth$Median - as.numeric(year_growth[1,2])) / as.numeric(year_growth[1,2])

p3 <- ggplot(year_growth, aes(x=as.numeric(Year_traded), y=100*as.numeric(year_growth$base))) + 
  geom_smooth(method=lm , color="red", se=TRUE) + 
  geom_point( color="#69b3a2") +
  geom_text(x = 2010, y = 400, label = "Growth rate = 418%, anunal: 10.01%, base year = 2006") +
  labs(x = "Year", y = "Growth rate, corrected by house age, base year = 2006)")
p3
ggsave(file.path(dir,"Result","Growth_year.png"))

library(ggplot2)
library(dplyr)
library(ggrepel)
library(tidyverse)

# Turn off scientific notation
options(scipen = 999)

# dir <- "E:/Dropbox (OIST)/Ishikawa Unit/Tsunghan/OkiHousePrice"
dir <- "/Users/Tsunghan/Dropbox (OIST)/Ishikawa Unit/Tsunghan/OkiHousePrice"

apartment <- read_csv(file.path(dir,"Wranggled","Apartment_Wranggled.csv"), locale = locale(encoding = "cp932"))

# Check the relationship between Unit_Price_py and year (uncorrected)
lmUnitPricePy0 = lm(as.numeric(apartment$Unit_price_py / 10000)~as.numeric(apartment$Year_traded)) #Create the linear regression
summary(lmUnitPricePy0)

p0 <- ggplot(apartment, aes(x=as.numeric(Year_traded), y=as.numeric(apartment$Unit_price_py / 10000))) + 
  geom_smooth(method=lm , color="red", se=TRUE) + 
  geom_point( color="#69b3a2") + 
  geom_text(x = 2010, y = 400, label = "Fig. 1: Unit price (per 10,000 yen) = 5.4975* (Year) -10976.2874\nR2 = 0.1745") +
  labs(x = "House age", y = "Unit price, x 10,000 yen per py")
p0
ggsave(file.path(dir,"Result","Unit_year.png"))

# Check the relationship between House age and Unit_Price_py
lmUnitPricePy1 = lm(as.numeric(apartment$Unit_price_py / 10000)~as.numeric(apartment$Age)) #Create the linear regression
summary(lmUnitPricePy1)

p1 <- ggplot(apartment, aes(x=as.numeric(Age), y=as.numeric(apartment$Unit_price_py / 10000))) + 
  geom_smooth(method=lm , color="red", se=TRUE) + 
  geom_point( color="#69b3a2") + 
  geom_text(x = 15, y = 400, label = "Fig2: Unit price (per 10,000 yen) = -3.08182* (House age) + 146.03379\nR2=0.3829") +
  labs(x = "House age", y = "Unit price (x 10,000 yen per py)")
p1
ggsave(file.path(dir,"Result","Unit_age.png"))

# Check the relationship between Unit price and year
lmUnipricePy2 = lm(as.numeric(apartment$Unit_price_py/10000)~as.numeric(apartment$Year_traded)+as.numeric(apartment$Age))
summary(lmUnipricePy2)

# Corrected the house price by house age
apartment$UnitPricePy_corrected_byHouseAge <- as.numeric(apartment$Unit_price_py) - 3.40420*as.numeric(apartment$Age)

p2 <- ggplot(apartment, aes(x=as.numeric(Year_traded), y=as.numeric(apartment$UnitPricePy_corrected_byHouseAge / 10000))) + 
  geom_smooth(method=lm , color="red", se=TRUE) + 
  geom_point( color="#69b3a2") + 
  geom_text(x = 2012, y = 400, label = "Fig3: Unit price (per 10,000 yen) = 6.64967* (Year) - 3.40420*(House Age) - 13240.10350\nR2 = 0.6378") +
  labs(x = "Year", y = "Unit price (x 10,000 yen per py, controlled by house age)")
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
  labs(x = "Year", y = "CAGR, corrected by house age, base year = 2006)")
p3
ggsave(file.path(dir,"Result","Growth_year.png"))

# A little bit complex model but did not improve much
lmUnipricePy3 = lm(as.numeric(apartment$Unit_price_py/10000)~as.numeric(apartment$Year_traded)+as.numeric(apartment$Age)+as.numeric(apartment$Year_traded)*as.numeric(apartment$Age))
summary(lmUnipricePy3)

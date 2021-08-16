library(ggplot2)
library(dplyr)
library(ggrepel)
library(tidyverse)

# Turn off scientific notation
options(scipen = 999)

# dir <- "E:/Dropbox (OIST)/Ishikawa Unit/Tsunghan/OkiHousePrice"
dir <- "/Users/Tsunghan/Dropbox (OIST)/Ishikawa Unit/Tsunghan/OkiHousePrice"

df <- read_csv(file.path(dir,"Wranggled","Land_building_wranggled.csv"), locale = locale(encoding = "cp932"))

# Check the relationship between Unit_Price_py and year (uncorrected)
# There is no correlation between unit price and year
lmUnitPricePy0 = lm(as.numeric(Unit_price_py)/10000~as.numeric(Year_traded), data = df) #Create the linear regression
summary(lmUnitPricePy0)

p0 <- ggplot(df, aes(x=as.numeric(Year_traded), y=as.numeric(Unit_price_py / 10000))) + 
  geom_smooth(method=lm , color="red", se=TRUE) + 
  geom_point( color="#69b3a2") + 
  geom_text(x = 2010, y = 2000, label = "negligible correlation") +
  labs(x = "Year", y = "Unit price, x 10,000 yen per py")
p0
ggsave(file.path(dir,"Result","LandBuilding_Unit_year.png"))

# There are some outliers, the model become sightly significant if we remove them from our dataset
# But the correlation between year and price is still low

# Check the relationship between House age and Unit_Price_py
lmUnitPricePy1 = lm(as.numeric(Unit_price_py / 10000)~as.numeric(Age), data = df) #Create the linear regression
summary(lmUnitPricePy1)

p1 <- ggplot(df, aes(x=as.numeric(Age), y=as.numeric(Unit_price_py / 10000))) + 
  geom_smooth(method=lm , color="red", se=TRUE) + 
  geom_point( color="#69b3a2") + 
  geom_text(x = 20, y = 2000, label = "Fig2: Unit price (per 10,000 yen)\nnegligible correlation") +
  labs(x = "House age", y = "Unit price (x 10,000 yen per py)")
p1
ggsave(file.path(dir,"Result","LandBuilding_Unit_age.png"))

# There are some outliers, the model become sightly significant if we remove them from our dataset
# But the correlation between age and price is still low
# Some building were renewed after traded. Those buildings are removed from the analysis.

df2 <- df %>%
  filter(Unit_price_py/10000 < 250) %>%
  filter(Age >= 0)

# Check the new model using dataframe without outliers
lmUnitPricePy2 = lm(as.numeric(Unit_price_py/10000)~as.numeric(Age) + as.numeric(Year_traded), data = df2) #Create the linear regression
summary(lmUnitPricePy2)

# Not significant
# Hence, the price of house + building is not determined age and years

# Check the correlation between location and unit price
# Factorize the city code
# The model is highly significant
df2$City_code.f <- as.factor(df2$City_code)

lmUnitPricePy3 = lm(as.numeric(Unit_price_py/10000)~as.numeric(Age) + as.numeric(Year_traded) + City_code.f, data = df2) #Create the linear regression
summary(lmUnitPricePy3)


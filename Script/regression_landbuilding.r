library(ggplot2)
library(dplyr)
library(ggrepel)
library(tidyverse)

# Turn off scientific notation
options(scipen = 999)

# dir <- "/Users/Tsunghan/Dropbox (OIST)/Ishikawa Unit/Tsunghan/OkiHousePrice/"
dir <- "E:/Dropbox (OIST)/Ishikawa Unit/Tsunghan/OkiHousePrice"
raw <- read.csv(file.path(dir,"Wranggled","Land_building_Wranggled.csv"),encoding="cp932")

# Remove outliers
df <- raw %>%
  filter(Unit_price_py/10000 < 250) %>%
  filter(Age > 0 && Age < 60)

# Check the relationship between Unit_Price_py and year
lmUnitPricePy0 = lm(as.numeric(Unit_price_py)/10000~as.numeric(Year_traded), data = df)
summary(lmUnitPricePy0)

p0 <- ggplot(df, aes(x=as.numeric(Year_traded), y=as.numeric(Unit_price_py / 10000))) + 
  geom_smooth(method=lm , color="red", se=TRUE) + 
  geom_point( color="#69b3a2") + 
  geom_text(x = 2010, y = 200, label = "negligible correlation") +
  labs(x = "Year", y = "Unit price, x 10,000 yen per py")
p0
ggsave(file.path(dir,"Result","LandBuilding_Unit_year.png"))

# There is no correlation between unit price and year

# Check the relationship between Unit_Price_py and year (uncorrected)
lmUnitPricePy1 = lm(as.numeric(Unit_price_py / 10000)~as.numeric(Age),data=df)
summary(lmUnitPricePy1)

# Check the correlation between price and house age
p1 <- ggplot(df, aes(x=as.numeric(Age), y=as.numeric(Unit_price_py / 10000))) + 
  geom_smooth(method=lm , color="red", se=TRUE) + 
  geom_point( color="#69b3a2") + 
  geom_text(x = 10, y = 200, label = "Price = -0.83325 x House_age + 60.9126\nR-squared = 0.1534\nlow correlation") +
  labs(x = "House age", y = "Unit price, x 10,000 yen per py")
p1
ggsave(file.path(dir,"Result","LandBuilding_Unit_age.png"))

# There are some outliers, the model become sightly significant if we remove them from our dataset
# But the correlation between year and price is still low

# Check the relationship between House age and Unit_Price_py
df$City_code.f <- as.factor(df$City_code)
lmUnitPricePy3 = lm(as.numeric(Unit_price_py / 10000)~as.numeric(Year_traded)+as.numeric(Age)+City_code.f, data = df) #Create the linear regression
summary(lmUnitPricePy3)

# We have a very significant model representing the correlation between price and house location

# Signif. codes:  0 ．***・ 0.001 ．**・ 0.01 ．*・ 0.05 ．.・ 0.1 ． ・ 1
# 
# Residual standard error: 22.67 on 6057 degrees of freedom
# (1088 observations deleted due to missingness)
# Multiple R-squared:  0.5108,	Adjusted R-squared:  0.5076 
# F-statistic: 158.1 on 40 and 6057 DF,  p-value: < 0.00000000000000022

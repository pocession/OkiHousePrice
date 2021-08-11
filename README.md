# OkiHousePrice
A tool for checking whether house price in Okinawa has increased since the past decades.

## Has the house price increaed in Okinawa?
Since I have moved to Okinawa, I always heard about the house price keeps going up. But is it true? Let's check it.

Data source: https://www.land.mlit.go.jp/webland/
(Only "中古マンション等" (Old apartment) is used for this analysis since this type of house is favoured by most people with regular job)

## A glimpse
Since 2006, the old apartment in Okinawa has increased 418%, with the annual growth rate of 10.01%. 
![Alt text](Result/Growth_year.png?raw=true "Growth rate since 2006")

## The increasing rate of house price
Let's see the growth rate. A simple linear regression model shows the the increasing rate per year is aobut 54950 yen per pyeong (1 pyeong ~ 3.14 mm<sup>2</sup>). However, R<sup>2</sup> is only 0.1745, suggesting this model can only explain about 17% of house price.
### Linear model 1: House price ~ Year
![Alt text](Result/Unit_year.png?raw=true "House price since 2006")

## Control the house age
We need to consider the influence of house age. In Japan, it is generally believed that the house price decreases along with its age. What the decreasing rate is? Well, it is about 30818 yen per pyeong per year.
![Alt text](Result/Unit_age.png?raw=true "House price with age")

## The adjusted increasing rate of house
Let's fit our data with the new model. The R<sup>2</sup> of this new model is only 0.6378, suggesting this model can explain about 64% of house price -- much better than the previous model. Now, if we fix the house age, then we can see the adjusted increase rate per year is aobut 664967 yen per pyeong. 
### Linear model 2: House price ~ Year + House_age
![Alt text](Result/Unit_year_corrected.png?raw=true "Corrected house price since 2006")


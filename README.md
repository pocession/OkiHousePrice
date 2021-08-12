# OkiHousePrice
A tool for checking whether house price in Okinawa has increased since the past decades.

## Has the house price increaed in Okinawa?
Since I have moved to Okinawa, I always heard about the house price keeps going up. But is it true? Let's check it.

Data source: https://www.land.mlit.go.jp/webland/
(Only "中古マンション等" (Old apartment) is used for this analysis since this type of house is favoured by most people with regular job)

## A glimpse
Since 2006, the old apartment in Okinawa has increased 418%, with the annual growth rate of 10.01%. 
![alt text](https://github.com/pocession/OkiHousePrice/blob/master/Result/Growth_year.png?raw=true)

## The increasing rate of house price
Let's see the growth rate. A simple linear regression model shows the the increasing rate per year is aobut 54950 yen per pyeong (1 pyeong ~ 3.14 mm<sup>2</sup>). However, R<sup>2</sup> is only 0.1745, suggesting this model can only explain about 17% of house price.
### Linear model 1: House price ~ Year
![alt text](https://github.com/pocession/OkiHousePrice/blob/master/Result/Unit_year.png?raw=true)
## Control the house age
We need to consider the influence of house age. In Japan, it is generally believed that the house price decreases along with its age. What the decreasing rate is? Well, it is about 30818 yen per pyeong per year.
![alt text](https://github.com/pocession/OkiHousePrice/blob/master/Result/Unit_age.png?raw=true)

## The adjusted increasing rate of house
Let's fit our data with the new model. The R<sup>2</sup> of this new model is 0.6378, suggesting this model can explain about 64% of house price -- much better than the previous model. Now, if we fix the house age, then we can see the adjusted increase rate per year is aobut 664967 yen per pyeong. 
### Linear model 2: House price ~ Year + House_age
![alt text](https://github.com/pocession/OkiHousePrice/blob/master/Result/Unit_year_corrected.png?raw=true)

## Old apartments are only traded in four cities
In the last step, let's check whether the price of old apartment varies from city to city. To our  surprisingly, since 2006, old apartments were only traded in four cities: Naha, Uruma, Okinawa, and Urasoe cities. And the trading numbers in Naha is highest. 
![alt text](https://github.com/pocession/OkiHousePrice/blob/master/Result/Tradednumeber_location.png?raw=true)

## Uruma city has the highest growth rate and Okinawa city has the highest price
Where is the highest price felling in and where is the city with the highest potential? Let's plot the both price (house age adjusted, per pyeong) and growth rate (since 2007<sup>1</sup>) on the map. Again, to our  surprisingly, ot Naha city. Uruma city has the highest growth rate and Okinawaa city has the highest price!
![alt text](https://github.com/pocession/OkiHousePrice/blob/master/Result/Traded2020_location.png?raw=true)
![alt text](https://github.com/pocession/OkiHousePrice/blob/master/Result/Traded2020_growthrate.png?raw=true)

1: there is no trading record of old apartment in some cities in 2006. So I set 2007 as base year.


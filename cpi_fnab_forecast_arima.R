# install packages
install.packages("readxl")
install.packages("tseries")
install.packages("urca")
install.packages("forecast")
install.packages("ggplot2")


# prepare the data of CPI of FNAB
# read the dataset
library(readxl)
dataset <- read_excel("C:\\Users\\ASUS\\Downloads\\cpi fnab.xlsx")

# convert "date" column to Date format
dataset$date <- as.Date(dataset$date, format = "%m/%d/%Y")
str(dataset)

# define the variables
library(tseries)
dataset.ts <- ts(dataset$fnab, start = c(2010, 1), end = c(2023, 8), frequency = 12)
str(dataset.ts)

# extract year information from the date column
dataset$year <- format(dataset$date, "%Y")

# create a new vector of labels that includes the month name and year information
labels <- paste(format(dataset$date, "%b"), dataset$year)


# plot time series data of CPI of FNAB
# plot the original series with monthly x-axis labels
plot(dataset$date, dataset$fnab, type = "l", col = "blue", xlab = "Year", ylab = "CPI FNAB Base 2010 = 100", pch = 20, panel.first = grid(), xaxt = "n")
axis(1, at = seq(from = min(dataset$date), to = max(dataset$date), by = "month"), labels = labels)

# plot the ACF and PACF for the original series
par(mfrow = c(2, 1))
acf(dataset$fnab, main = "ACF for CPI FNAB", panel.first = grid())
pacf(dataset$fnab, main = "PACF for CPI FNAB", panel.first = grid())

# test unit root for time series data
# adf test for time series
library(urca)
adf_test <- ur.df(dataset$fnab, type = "drift", selectlags = "AIC")
summary(adf_test)

# retrieve adf prob. statistics
adf_statistic <- adf_test@teststat[1]
p_value <- punitroot(adf_statistic)
print(p_value)

# kpss test for time series
kpss_test <- ur.kpss(dataset$fnab, type = "mu")
summary(kpss_test)


# 1st difference of CPI of FNAB series
# plot acf and pacf for 1st difference
par(mfrow = c(2, 1))
acf(diff(dataset$fnab), 16, main = "ACF for 1st Difference FNAB CPI", panel.first = grid())
pacf(diff(dataset$fnab), 16, main = "PACF for 1st Difference FNAB CPI", panel.first = grid())

# check the length of data for accuracy
length(dataset$date[2:length(dataset$date)])
length(diff(dataset$fnab))

# calculate the first difference of the original data
dataset_diff1 <- diff(dataset$fnab)

# plot the first difference order with monthly x-axis labels
plot(dataset$date[2:length(dataset$date)], dataset_diff1[1:(length(dataset$date)-1)], type = "l", xlab = "Year", ylab = "1st Difference FNAB CPI", pch = 20, panel.first = grid(), xaxt = "n")
axis(1, at = seq(from = min(dataset$date), to = max(dataset$date), by = "month"), labels = labels)

# test unit root for 1st difference order
# adf test for 1st difference
adf_test <- ur.df(dataset_diff1, type = "drift", selectlags = "AIC")
summary(adf_test)

# retrieve adf prob. statistics
adf_statistic <- adf_test@teststat[1]
p_value <- punitroot(adf_statistic)
print(p_value)

# kpss test for 1st difference
kpss_test <- ur.kpss(dataset_diff1, type = "mu")
summary(kpss_test)

library(forecast)
library(ggplot2)
# fit alternatives ARIMA model
# fit ARIMA(3, 1, 2)
arima312 <- arima(dataset.ts, order = c(3, 1, 2), method = "ML")
summary(arima312)

# fit ARIMA(3, 1, 1)
arima311 <- arima(dataset.ts, order = c(3, 1, 1), method = "ML")
summary(arima311)

# fit ARIMA(2, 1, 2)
arima212 <- arima(dataset.ts, order = c(2, 1, 2), method = "ML")
summary(arima212)

# fit ARIMA(2, 1, 1)
arima211 <- arima(dataset.ts, order = c(2, 1, 1), method = "ML")
summary(arima211)

# fit ARIMA(1, 1, 2)
arima112 <- arima(dataset.ts, order = c(1, 1, 2), method = "ML")
summary(arima112)

# compare aic and bic values of ARIMA models
AIC(arima312, arima311, arima212, arima211, arima112)
BIC(arima312, arima311, arima212, arima211, arima112)

# Forecast the model
forecast112 <- forecast(arima112, h = 24)

# Print the forecasted values
print(forecast112)







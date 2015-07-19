setwd("/home/olpc/Desktop/represearch/")

exercise.activity <- read.csv("activity.csv")


str(exercise.activity)
head(exercise.activity)
library(stargazer)
stargazer(exercise.activity, type = "text")
summary(exercise.activity)

exercise.activity$date <- strptime(exercise.activity$date, format= "%Y-%m-%d")
exercise.activity$date <- as.POSIXct(exercise.activity$date)
dayssum <- tapply(exercise.activity$steps, exercise.activity$date, sum)

hist(as.vector(dayssum), breaks = 10, xlab = "Steps per day")

mean(as.vector(dayssum), na.rm = TRUE)
median(as.vector(dayssum), na.rm = TRUE)

str(exercise.activity$interval)
table(exercise.activity$interval)

steps.per.interval <- tapply(exercise.activity$steps, exercise.activity$interval, mean, na.rm = TRUE)
str(steps.per.interval)
intervalstime <- strptime(sprintf("%04d", as.numeric(names(steps.per.interval))), format="%H%M")

str(intervalstime)
df.steps.per.interval <- data.frame(intervalstime, as.vector(steps.per.interval))
colnames(df.steps.per.interval) <- c("interval", "steps_per_interval")
str(df.steps.per.interval)

head(df.steps.per.interval)
tail(df.steps.per.interval)

with(df.steps.per.interval, plot(steps_per_interval ~ interval, type = "l", xlab = "Interval", ylab = "Steps per interval"))
which.max(df.steps.per.interval$steps_per_interval)
df.steps.per.interval$interval[104]

str(exercise.activity)
summary(exercise.activity$steps)
sum(is.na(exercise.activity$steps))

df.steps.averages <- data.frame(as.integer(names(steps.per.interval)), as.numeric(as.vector(steps.per.interval)))
colnames(df.steps.averages) <- c("interval", "steps_average")
str(df.steps.averages)
head(df.steps.averages)

df.exercise <- merge(exercise.activity, df.steps.averages, by = "interval")
str(df.exercise)

for (i in (1:nrow(df.exercise))) {
  if (is.na(df.exercise$steps[i]) == TRUE) {
    df.exercise$steps[i] <- df.exercise$steps_average[i]
  }
}

head(df.exercise)
str(df.exercise)

df.exercise$steps_average <- NULL

# Now calculate total steps per day.

dayssum2 <- tapply(df.exercise$steps, df.exercise$date, sum)
hist(as.vector(dayssum2), breaks = 10, xlab = "Total steps per day", 
     main = "Frequency of steps per day \n (with imputed NA values)")

mean(as.vector(dayssum2))
median(as.vector(dayssum2))
sum(as.vector(dayssum2))
sum(as.vector(dayssum), na.rm = TRUE)

# Now create a vector with weekdays and weekends
# First convert "date" from factor to date
str(df.exercise)
head(df.exercise)
df.exercise$date <- strptime(df.exercise$date, format = "%Y-%m-%d")
df.exercise$date <- as.POSIXct(df.exercise$date)
weekdays(df.exercise$date[5])

table(df.exercise$wkd)

# We can use the ifelse() function
# 
# for (i in c(1:nrow(df.exercise))) {
#   ifelse(weekdays(df.exercise$date[i]) == "Saturday" | 
#            weekdays(df.exercise$date[i]) == "Sunday", 
#          df.exercise$wkd[i] <- "weekend", 
#          df.exercise$wkd[i] <- "weekday")
# }

# alternatively we can do:
# first convert to the name of the day

# for (i in c(1:nrow(df.exercise))) {
#   df.exercise$wkd[i] <- weekdays(df.exercise$date[i])
# }

# then convert day to weekend/weekday using grepl
# "^S" means replace all strings that start with capital "S"
# In our case it is just "Saturday" and "Sunday"
# df.exercise$wkd <- ifelse(grepl("^S", df.exercise$wkd), "weekend", "weekday")

for (i in c(1:nrow(df.exercise))) {
  if (weekdays(df.exercise$date[i]) == "Saturday" | 
        weekdays(df.exercise$date[i]) == "Sunday") {
    df.exercise$wkd[i] <- "weekend"
  } else {
    df.exercise$wkd[i] <- "weekday"
  }
}

head(df.exercise$wkd)
str(df.exercise)
df.exercise$wkd <- as.factor(df.exercise$wkd)

df.exercise$interval_converted <- strptime((sprintf("%04d", as.numeric(df.exercise$interval))), format = "%H%M")
df.exercise$interval_converted <- as.POSIXct(df.exercise$interval_converted)

df.weekdays <- subset(df.exercise, df.exercise$wkd == "weekday")
df.weekends <- subset(df.exercise, df.exercise$wkd == "weekend")

str(df.weekdays)
str(df.weekends)

head(df.weekdays)

weekdays.avgs <- tapply(df.weekdays$steps, df.weekdays$interval_converted, mean)
weekends.avgs <- tapply(df.weekends$steps, df.weekends$interval_converted, mean)

str(weekdays.avgs)
df.weekdays.avgs <- data.frame(as.POSIXct(names(weekdays.avgs)), as.vector(weekdays.avgs))
colnames(df.weekdays.avgs) <- c("interval", "steps")
str(df.weekdays.avgs)
head(df.weekdays.avgs)

df.weekends.avgs <- data.frame(as.POSIXct(names(weekends.avgs)), as.vector(weekends.avgs))
colnames(df.weekends.avgs) <- c("interval", "steps")
str(df.weekdays.avgs)
head(df.weekdays.avgs)

par(mfrow = c(2,1), mar=c(4, 4, 0.5, 1))
with(df.weekdays.avgs, plot(steps ~ interval, 
                            xlab = "Interval (weekdays)", ylab = "Steps (on weekdays)", type = "l", ylim = c(0, 250)))
with(df.weekends.avgs, plot(steps ~ interval, 
                            xlab = "Interval (weekends)", ylab = "Steps (on weekends)", type = "l", ylim = c(0, 250)))

df.weekdays.avgs$day <- c(rep("weekday", nrow(df.weekdays.avgs)))
str(df.weekdays.avgs)

df.weekends.avgs$day <- c(rep("weekends", nrow(df.weekends.avgs)))
str(df.weekends.avgs)

df.days.avgs <- rbind(df.weekdays.avgs, df.weekends.avgs)
str(df.days.avgs)
df.days.avgs$day <- as.factor(df.days.avgs$day)
head(df.days.avgs$interval)
tail(df.days.avgs$interval)

library(ggplot2)
library(scales)
ggplot(data = df.days.avgs, aes(x = interval, y = steps)) +
  geom_line() + labs(y = "Steps", x = "Interval") +
  facet_grid(day ~ .) +
  scale_x_datetime(limits = c(as.POSIXct("2015-07-19 00:00:00 EEST"), 
                              as.POSIXct("2015-07-19 23:55:00 EEST")), 
                   breaks = date_breaks("2 hours"),
                   labels = date_format("%H"))

ggplot(data = df.weekdays.avgs, aes(x = interval, y = steps)) +
  geom_line() + labs(y = "Steps", x = "Interval") +
  scale_x_datetime(limits = c(as.POSIXct("2015-07-19 00:00:00 EEST"), 
                              as.POSIXct("2015-07-19 23:55:00 EEST")), 
                   breaks = date_breaks("2 hours"),
                   labels = date_format("%H"))

loca
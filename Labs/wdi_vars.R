
library('GGally')


table(df.wdi.2019$income)
table(df.wdi.2019$region)


# df.trade.2019 <- get.Comtrade(r = 'all', p = '28', 
#                               ps = as.character(2019), freq = 'Y',
#                               rg = '1', cc = '84',
#                               fmt = 'csv')


# Строим графики ...............................................................

# Матричные графики разброса
ggpairs(df.wdi.2019[df.wdi.2019$income %in% c('Upper middle income',
                                            'High income'), -(1:2)], 
        aes(colour = income, alpha = 0.7),
        lower = list(continuous = 'smooth'))

ggpairs(df.wdi.2019[df.wdi.2019$income == 'Upper middle income', -(c(1:2, 9:10))], 
        lower = list(continuous = 'smooth'))

# логарифмируем всё, кроме индекса лёгкости ведения бизнеса (рейтинг)
#  и затрат на регистрацию бизнеса (есть нулевые значения)
summary(df.wdi.2019)
df.wdi.2019.log <- df.wdi.2019
df.wdi.2019.log[, -c(1:2, 4, 8:9)] <- apply(df.wdi.2019.log[, -c(1:2, 4, 8:9)], 
                                           2, log)
head(df.wdi.2019.log)

# Матричные графики разброса в логарифмах
ggpairs(df.wdi.2019.log[df.wdi.2019.log$income %in% c('Upper middle income',
                                                    'High income'), -(1:2)], 
        aes(colour = income, alpha = 0.7),
        lower = list(continuous = 'smooth'))

ggpairs(df.wdi.2019.log[df.wdi.2019.log$income == 'Upper middle income', 
                       -(c(1:2, 9:10))], 
        lower = list(continuous = 'smooth'))

fit <- lm(IC.BUS.EASE.XQ ~ ., data = df.wdi.2019[, -c(1:2, 9:10)])
summary(fit)

fit.log <- lm(IC.BUS.EASE.XQ ~ ., data = df.wdi.2019.log[, -c(1:2, 9:10)])
summary(fit.log)


data.fit <- df.wdi.2019[df.wdi.2019$income == 'Upper middle income', 
                        -c(1:2, 9:10)]
ggpairs(data.fit, lower = list(continuous = 'smooth'))
fit <- lm(IC.BUS.EASE.XQ ~ ., data = data.fit)
fit <- lm(IC.BUS.EASE.XQ ~ . -IC.REG.DURS, data = data.fit)
summary(fit)

data.fit <- df.wdi.2019[df.wdi.2019$income == 'Lower middle income', 
                        -c(1:2, 9:10)]
ggpairs(data.fit, lower = list(continuous = 'smooth'))
fit <- lm(IC.BUS.EASE.XQ ~ ., data = data.fit)
fit <- lm(IC.BUS.EASE.XQ ~ . -IC.TAX.TOTL.CP.ZS -IC.REG.DURS, 
          data = data.fit)
summary(fit)

data.fit <- df.wdi.2019[df.wdi.2019$income == 'High income', 
                        -c(1:2, 9:10)]
ggpairs(data.fit, lower = list(continuous = 'smooth'))
fit <- lm(IC.BUS.EASE.XQ ~ ., data = data.fit)
fit <- lm(IC.BUS.EASE.XQ ~ . -IC.TAX.TOTL.CP.ZS -IC.TAX.DURS 
          -IC.REG.COST.PC.ZS, 
          data = data.fit)
summary(fit)


data.fit <- df.wdi.2019[df.wdi.2019$income == 'Low income', 
                        -c(1:2, 9:10)]
ggpairs(data.fit, lower = list(continuous = 'smooth'))
fit <- lm(IC.BUS.EASE.XQ ~ ., data = data.fit)
fit <- lm(IC.BUS.EASE.XQ ~ . -IC.TAX.TOTL.CP.ZS -IC.REG.DURS 
          -IC.TAX.DURS -NY.GDP.PCAP.CD, data = data.fit)
summary(fit)


data.fit <- df.wdi.2019[df.wdi.2019$regio %in% c('East Asia & Pacific',
                                                 'South Asia'), 
                        -c(1:2, 9:10)]
ggpairs(data.fit, lower = list(continuous = 'smooth'))
fit <- lm(IC.BUS.EASE.XQ ~ ., data = data.fit)
fit <- lm(IC.BUS.EASE.XQ ~ . -IC.TAX.DURS -IC.TAX.TOTL.CP.ZS
          -IC.REG.DURS -IC.REG.COST.PC.ZS, 
          data = data.fit)
summary(fit)


data.fit <- df.wdi.2019[df.wdi.2019$regio == 'Europe & Central Asia', 
                        -c(1:2, 9:10)]
ggpairs(data.fit, lower = list(continuous = 'smooth'))
fit <- lm(IC.BUS.EASE.XQ ~ ., data = data.fit)
fit <- lm(IC.BUS.EASE.XQ ~ . -IC.REG.DURS -IC.TAX.TOTL.CP.ZS 
          -NY.GDP.PCAP.CD, 
          data = data.fit)
summary(fit)


data.fit <- df.wdi.2019[df.wdi.2019$regio == 'Latin America & Caribbean', 
                        -c(1:2, 9:10)]
ggpairs(data.fit, lower = list(continuous = 'smooth'))
fit <- lm(IC.BUS.EASE.XQ ~ ., data = data.fit)
fit <- lm(IC.BUS.EASE.XQ ~ . -NY.GDP.PCAP.CD -IC.TAX.TOTL.CP.ZS
          -IC.REG.COST.PC.ZS -IC.TAX.DURS, 
          data = data.fit)
summary(fit)


data.fit <- df.wdi.2019[df.wdi.2019$region == 'Middle East & North Africa', 
                        -c(1:2, 9:10)]
ggpairs(data.fit, lower = list(continuous = 'smooth'))
fit <- lm(IC.BUS.EASE.XQ ~ ., data = data.fit)
fit <- lm(IC.BUS.EASE.XQ ~ . -NY.GDP.PCAP.CD, 
          data = data.fit)
summary(fit)


data.fit <- df.wdi.2019[df.wdi.2019$region == 'Sub-Saharan Africa', 
                        -c(1:2, 9:10)]
ggpairs(data.fit, lower = list(continuous = 'smooth'))
fit <- lm(IC.BUS.EASE.XQ ~ ., data = data.fit)
fit <- lm(IC.BUS.EASE.XQ ~ . -IC.REG.DURS -IC.REG.COST.PC.ZS, 
          data = data.fit)
summary(fit)


data.fit <- df.wdi.2019[df.wdi.2019$region %in% c('Latin America & Caribbean',
                                                  'North America'), 
                        -c(1:2, 9:10)]
ggpairs(data.fit, lower = list(continuous = 'smooth'))
fit <- lm(IC.BUS.EASE.XQ ~ ., data = data.fit)
fit <- lm(IC.BUS.EASE.XQ ~ . -IC.REG.COST.PC.ZS -IC.TAX.DURS
          -IC.TAX.TOTL.CP.ZS, 
          data = data.fit)
summary(fit)


# Данные примеров:
#  класс стран для задания 1
#    region:  High income & Upper middle income
#  код товара для задания 2
#    86
#  страна для задания 2
#    Уругвай (Uruguay)


# Загрузка пакетов
library('dplyr')            # функции манипуляции данными  
library('data.table')       # объект "таблица данных"
library('WDI')              # загрузка данных из базы Всемирного банка
library('ggplot2')          # графическая система ggplot2
library('lattice')          # графическая система lattice
library('GGally')           # матричные графики разброса




# Пример 1: данные по импорту --------------------------------------------------



# Загрузка данных ==============================================================

# создаём директорию для данных, если она ещё не существует:
data.dir <- 'data'
if (!file.exists(data.dir)) dir.create(data.dir)

# создаём файл с логом загрузок, если он ещё не существует:
log.filename <- 'data/download.log'
if (!file.exists(log.filename)) file.create(log.filename)

# # Загрузить из базы данных международной торговли статистику импорта за 2019
# #  год (данные ежемесячные) по стране и кодам, указанным в варианте.
# # функция, реализующая API (источник: UN COMTRADE)
# source("https://raw.githubusercontent.com/aksyuk/R-data/master/API/comtrade_API.R")
# # список стран и регионов с кодами:
# # https://comtrade.un.org/Data/cache/partnerAreas.json
# # имя файла для сохранения
# dest.file <- './data/comtrade_import-2019_raw.csv'
# if (!file.exists(dest.file)) {
#     # загрузить и сохранить файл 
#     s1 <- get.Comtrade(r = 'all', p = '858',
#                        ps = as.character(2019), freq = "M",
#                        rg = '1', cc = '86',
#                        fmt = 'csv')
#     write.csv(s1$data, fileName, row.names = F)
#     # сделать запись в лог
#     write(paste('Файл', dest.file, 'загружен', Sys.time()), 
#           file = log.filename, append = T)
# }



# Очистка данных ===============================================================

# читаем ранее загруженные данные
# fileURL <- dest.file
fileURL <- 'https://raw.githubusercontent.com/aksyuk/R_data_glimpse/main/Labs/data/comtrade_import-2019_raw.csv'
DF.01 <- read.csv(fileURL, stringsAsFactors = F)

dim(DF.01)
str(DF.01)
colnames(DF.01)


# Разбираемся с именами столбцов таблицы #######################################

# копируем имена в символьный вектор, чтобы ничего не испортить
nms <- colnames(DF.01)
# заменить серии из двух и более точек на одну
nms <- gsub('[.]+', '.', nms)
# убрать все хвостовые точки
nms <- gsub('[.]+$', '', nms)
# заменить US на USD
nms <- gsub('Trade.Value.US', 'Trade.Value.USD', nms)
# проверяем, что всё получилось, и заменяем имена столбцов
colnames(DF.01) <- nms
# результат обработки имён столбцов
colnames(DF.01)


# Удаляем полностью пустые столбцы #############################################

# делаем подсчёт пропусков по каждому столбцу
na.num <- sapply(DF.01, function(x) sum(is.na(x)))
na.num

# в каких столбцах все наблюдения пропущены?
col.remove <- na.num == nrow(DF.01)

# уберём эти столбцы из таблицы
DF.01 <- DF.01[, !col.remove]
dim(DF.01)


# создаём data.table из фрейма #################################################

DT.import <- data.table(DF.01)
# столбцы таблицы
colnames(DT.import)
# оставляем только нужные столбцы
DT.import <- select(DT.import, Year, Period, Trade.Flow, Reporter, Partner, 
                    Commodity.Code, Trade.Value.USD)

# список стран из справочника БД Всемирного банка
DT.country <- data.table(WDI_data$country)
DT.country <- select(DT.country, iso2c, country, region, income)

# добавляем 'Reporter.' в названия столбцов с характеристиками стран,
#  чтобы отличать продавцов от покупателя
colnames(DT.country) <- paste0('Reporter.', colnames(DT.country))
# добавляем столбец с группой стран-продавцов
DT.import <- merge(DT.import, DT.country, 
                   by.x = 'Reporter', by.y = 'Reporter.country')
colnames(DT.import)
dim(DT.import)

# наконец, меняем формат периода времени с ГГГГММ на ГГГГ-ММ
DT.import[, Period := as.character(Period)]
DT.import[, Period := paste0(substr(Period, 1, 4), '-', substr(Period, 5, 7))]
DT.import[, Period := factor(Period, 
                             levels = paste0('2019-', formatC(1:12, width = 2, 
                                                              flag = '0')))]



# Визуализация и дескриптивный анализ ==========================================


# описательные статистики по таблице данных
summary(DT.import)

# описательные статистики по количественному показателю
summary(DT.import$Trade.Value.USD)

# суммарная стоимость импорта в Уругвай в 2019 году по коду 86
sum(DT.import$Trade.Value.USD)

# к каким категориям относится Уругвай
filter(DT.country, Reporter.country == 'Uruguay')


# график динамики по месяцам 2019 в разрезе регионов мира (lattice) ############

# так получается неверное отображение данных
xyplot(Trade.Value.USD ~ Period | Reporter.region, data = DT.import,
       type = 'o')

# чтобы отразить динамику правильно, нужно агрегировать стоимость поставок
#  по периоду и по региону мира
group_by(DT.import, Period, Reporter.region) %>% 
    summarise(Trade.Value.USD = sum(Trade.Value.USD)) -> dt.plot.01
colnames(dt.plot.01)[colnames(dt.plot.01) == 'Reporter.region'] <- 
    'Регион.поставщика'
# для отображения на графиках называем столбцы по-русски
colnames(dt.plot.01)[colnames(dt.plot.01) == 'Period'] <- 'Месяц'
colnames(dt.plot.01)[colnames(dt.plot.01) == 'Trade.Value.USD'] <- 
    'Стоимость.поставок.долл'

# теперь получается верный график динамики 
xyplot(Стоимость.поставок.долл ~ Месяц | Регион.поставщика, data = dt.plot.01,
       type = 'o')


# круговая для отображения долей регионов за год (ggplot2) #####################
group_by(DT.import, Reporter.region) %>% 
    summarise(Trade.Value.USD = sum(Trade.Value.USD)) -> dt.plot.02
dt.plot.02$Trade.Value.share <- paste0(round(dt.plot.02$Trade.Value.USD / 
    sum(dt.plot.02$Trade.Value.USD) * 100, 1), '%')
# для отображения на графиках называем столбцы по-русски
colnames(dt.plot.02)[colnames(dt.plot.02) == 'Reporter.region'] <- 
    'Регион.поставщика'

# исходные данные для графика и роли столбцов
gp <- ggplot(data = dt.plot.02, aes(x = '', y = Trade.Value.USD,
                                    fill = Регион.поставщика,
                                    label = Trade.Value.share))
# добавляем геометрию: столбчатая диаграмма 
#  + полярные координаты, чтобы свернуть ряд данных в окружность
gp <- gp + geom_bar(stat = 'identity', width = 1) + coord_polar('y', start = 0)
# добавляем подписи секторов
gp <- gp + geom_text(size = 3, position = position_stack(vjust = 0.5))
# меняем палитру графика
gp <- gp + scale_fill_brewer(palette = 'Set2')
# добавляем заголовок
gp <- gp + ggtitle('Импорт в Уругвай в 2019 по коду 86')
# добавляем подпись под графиком
gp <- gp + labs(caption = 'Уругвай относится к региону "Latin America & Caribbean"')
# убираем разметку шкалы
gp <- gp + theme_void()
# отображаем график
gp


# столбчатые для отображения с долями по месяцам (ggplot2) #####################

# используем агрегированные данные для первого графика, 
#  только теперь сопоставим доли
#  и пересчитаем стоимость в тысячи долларов
dt.plot.01$Стоимость.поставок.долл <- 
    round(dt.plot.01$Стоимость.поставок.долл / 1000, 1)
colnames(dt.plot.01)[colnames(dt.plot.01) == 'Стоимость.поставок.долл'] <- 
    'Стоимость.поставок.тыс.долл'

gp <- ggplot(data = dt.plot.01, aes(x = Месяц, y = Стоимость.поставок.тыс.долл,
                                    fill = Регион.поставщика,
                                    label = Стоимость.поставок.тыс.долл))
# добавляем геометрию: столбчатая диаграмма, столбики друг на друге
gp <- gp + geom_bar(stat = 'identity')
# добавляем подписи значений
gp <- gp + geom_text(size = 3, position = position_stack(vjust = 0.5))
# настройки горизонтальной оси
gp <- gp + scale_x_discrete(drop = F)
# меняем палитру графика
gp <- gp + scale_fill_brewer(palette = 'Set2')
# разворачиваем подписи по горизонтальной оси на 90 градусов
gp <- gp + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
# добавляем заголовок
gp <- gp + ggtitle('Импорт в Уругвай по коду 86')
# отображаем график
gp


# находим топ-5 стран-поставщиков ##############################################

# по всем странам
group_by(DT.import, Reporter) %>% 
    summarise(Trade.Value.USD = sum(Trade.Value.USD)) %>% 
    arrange(-Trade.Value.USD) -> df.top
# первые 5 строк отсортированной таблицы
df.top[1:5, ]

# по странам латиноамериканского региона
group_by(filter(DT.import, Reporter.region == 'Latin America & Caribbean'), 
         Reporter) %>% 
    summarise(Trade.Value.USD = sum(Trade.Value.USD)) %>% 
    arrange(-Trade.Value.USD) -> df.top.region
# первые 5 строк отсортированной таблицы
df.top.region[1:min(nrow(df.top.region), 5), ]

# по странам с высоким доходом
group_by(filter(DT.import, Reporter.income == 'High income'), 
         Reporter) %>% 
    summarise(Trade.Value.USD = sum(Trade.Value.USD)) %>% 
    arrange(-Trade.Value.USD) -> df.top.income
# первые 5 строк отсортированной таблицы
df.top.income[1:min(nrow(df.top.income), 5), ]




# Пример 2: показатели развития стран ------------------------------------------



# Загрузка данных ==============================================================

# коды и названия показателей по странам
ind.names <- c('NY.GDP.PCAP.CD', 'IC.REG.COST.PC.ZS', 
               'IC.REG.DURS', 'IC.TAX.TOTL.CP.ZS', 
               'IC.TAX.DURS', 'IC.BUS.EASE.XQ')
ind.labels <- c('ВВП на душу, текущие цены, USD',
                'Затраты на создание бизнеса, % от ВНД на душу',
                'Время на создание бизнеса, дней', 
                'Налоговая нагрузка на бизнес, % от прибыли',
                'Время на выплату налогов, часов',
                'Рейтинг лёгкости ведения бизнеса')
names(ind.labels) <- ind.names



# Очистка данных ===============================================================

# читаем ранее скачанные данные за 2019 год
# dest.file <- './data/wdi_2019.csv'
# fileURL <- dest.file
fileURL <- 'https://raw.githubusercontent.com/aksyuk/R_data_glimpse/main/Labs/data/wdi_2019.csv'
DT.wdi.2019 <- data.table(read.csv(fileURL, stringsAsFactors = F))

# смотрим первые строки таблицы
head(DT.wdi.2019)

# фильтруем страны по регионам из варианта
unique(DT.country$Reporter.income)
DT.wdi.2019 <- filter(DT.wdi.2019, 
                      income %in% c('High income', 'Upper middle income'))

# сколько пропусков в столбцах таблицы
sapply(DT.wdi.2019, function(x){sum(is.na(x))})

# код Намибии NA совпадает с меткой пропущенного наблюдения в R
DT.wdi.2019[is.na(DT.wdi.2019$iso2c), ]
# исправляем это
DT.wdi.2019[is.na(DT.wdi.2019$iso2c), iso2c := 'NA']

# убираем строки с пропусками
dim(DT.wdi.2019)
DT.wdi.2019 <- na.omit(DT.wdi.2019)
dim(DT.wdi.2019)



# Визуализация и дескриптивный анализ ==========================================


# описательные статистики ######################################################
summary(DT.wdi.2019[, ..ind.names])
# коэффициенты вариации
CV <- round(sapply(DT.wdi.2019[, ..ind.names], sd) / 
                sapply(DT.wdi.2019[, ..ind.names], mean) * 100, 1)
df.CV <- data.frame(Показатель = ind.labels[ind.names], Коэфф.вариации.прц = CV)
df.CV


# строим графики взаимного разброса (ggplot2) ##################################

ggpairs(DT.wdi.2019[, ..ind.names], lower = list(continuous = 'smooth'))



# Линейные регрессионные модели ================================================

# модель со всеми объясняющими переменными
fit.all <- lm(IC.BUS.EASE.XQ ~ ., data = DT.wdi.2019[, ..ind.names])
summary(fit.all)

# корреляция между объясняющими IC.REG.COST.PC.ZS и IC.REG.DURS
#  выше, чем корреляция IC.REG.DURS с зависимой переменной IC.BUS.EASE.XQ, 
#  поэтому корректнее будет включить IC.REG.COST.PC.ZS и IC.REG.DURS 
#  по отдельности в две разные модели
# модель 1
fit.1 <- lm(IC.BUS.EASE.XQ ~ . -IC.REG.COST.PC.ZS, 
            data = DT.wdi.2019[, ..ind.names])
summary(fit.1)

# модель 2
fit.2 <- lm(IC.BUS.EASE.XQ ~ . -IC.REG.DURS, 
            data = DT.wdi.2019[, ..ind.names])
summary(fit.2)

# модель 2, параметры значимы на уровне 0.05
fit.3 <- lm(IC.BUS.EASE.XQ ~ . -IC.REG.DURS -IC.TAX.TOTL.CP.ZS, 
            data = DT.wdi.2019[, ..ind.names])
summary(fit.3)

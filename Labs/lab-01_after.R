# Esly russkie bukvy ne otobrajautsa: File -> Reopen with encoding... UTF-8

# Используйте UTF-8 как кодировку по умолчанию!
# Установить кодировку в RStudio: Tools -> Global Options -> General, 
#  Default text encoding: UTF-8

# Лабораторная работа №1. Загрузка данных

# Загрузка пакетов
library('WDI')     # импорт данных из базы Всемирного банка




# Часть 1: Загрузка данных -----------------------------------------------------



# Загрузка файла .csv из сети ==================================================


# Пример 1: Импорт масла в РФ ##################################################

# адрес файла с данными по импорту масла в РФ
fileURL <- 'https://raw.githubusercontent.com/aksyuk/R-data/master/COMTRADE/040510-Imp-RF-comtrade.csv'
data.dir <- './data'
dest.file <- './data/040510-Imp-RF-comtrade.csv'

# создаём директорию для данных, если она ещё не существует:
if (!file.exists(data.dir)) dir.create(data.dir)

# создаём файл с логом загрузок, если он ещё не существует:
log.filename <- './data/download.log'
if (!file.exists(log.filename)) file.create(log.filename)

# загружаем файл, если он ещё не существует,
#  и делаем запись о загрузке в лог:
if (!file.exists(dest.file)) {
    # загрузить файл 
    download.file(fileURL, dest.file)
    # сделать запись в лог
    write(paste('Файл', dest.file, 'загружен', Sys.time()), 
          file = log.filename, append = T)
}

# читаем данные из загруженного .csv во фрейм, 
#  если он ещё не существует
if (!exists('DF.import')) {
    DF.import <- read.csv(dest.file, stringsAsFactors = F)    
}
# предварительный просмотр
dim(DF.import)     # размерность таблицы
str(DF.import)     # структура (характеристики столбцов)
head(DF.import)    # первые несколько строк таблицы
tail(DF.import)    # последние несколько строк таблицы

# справочник к данным
# https://github.com/aksyuk/R-data/blob/master/COMTRADE/CodeBook_040510-Imp-RF-comtrade.md




# Загрузка данных с помощью API ================================================


# Пример 2: Импорт масла в РФ по годам #########################################


# Статистика международной торговли из базы UN COMTRADE

# адрес справочника по странам UN COMTRADE
fileURL <- "http://comtrade.un.org/data/cache/partnerAreas.json"
# загружаем данные из формата JSON
reporters <- fromJSON(file = fileURL)
is.list(reporters)

# соединяем элементы списка построчно
reporters <- t(sapply(reporters$results, rbind))
dim(reporters)

# превращаем во фрейм
reporters <- as.data.frame(reporters)
head(reporters)

# даём столбцам имена
names(reporters) <- c('State.Code', 'State.Name.En')
# находим РФ
reporters[reporters$State.Name.En == 'Russian Federation', ]

# функция, реализующая API (источник: UN COMTRADE)
source("https://raw.githubusercontent.com/aksyuk/R-data/master/API/comtrade_API.R")
# ежемесячные данные по импорту масла в РФ за 2010 год
# 040510 – код сливочного масла по классификации HS
s1 <- get.Comtrade(r = 'all', p = "643", 
                   ps = as.character(2010), freq = "M",
                   rg = '1', cc = '040510',
                   fmt = "csv")
dim(s1$data)
is.data.frame(s1$data)

# записываем выборку за 2010 год в файл
file.name <- './data/comtrade_2010.csv'
write.csv(s1$data, file.name, row.names = F)

# загрузка данных в цикле
for (i in 2011:2020) {
    # таймер для ограничения API: не более запроса в секунду
    Sys.sleep(5)
    s1 <- get.Comtrade(r = 'all', p = "643", 
                       ps = as.character(i), freq = "M",
                       rg = '1', cc = '040510',
                       fmt = "csv")
    # имя файла для сохранения
    file.name <- paste0('./data/comtrade_', i, '.csv')
    # записать данные в файл
    write.csv(s1$data, file.name, row.names = F)
    # вывести сообщение в консоль
    print(paste('Данные за', i, 'год сохранены в файл', 
                file.name))
    # сделать запись в лог
    write(paste('Файл', file.name, 'загружен', Sys.time()), 
          file = log.filename, append = T)
}


# Пример 3: Статистика Всемирного банка по странам мира ########################




# source: https://github.com/yihui/xaringan/wiki/Export-Slides-to-PDF

# install.packages(c("pagedown", "xaringan"))
# # make sure you have pagedown >= 0.2 and xaringan >= 0.9; if not, run
# # remotes::install_github(c('rstudio/pagedown', 'yihui/xaringan'))

library('pagedown')
library('xaringan')
library('knitr')

# связать методичку в .md
knit(input = './practice_2-1-2021_Getting_Data.Rmd')

# экспортировать слайды в pdf
# pagedown::chrome_print("../Slides/slides_practice_01.Rmd", format = 'pdf',
#                        browser = "C:\\Users\\sa_suyazova\\AppData\\Local\\Google\\Chrome\\Application\\chrome.exe")
pagedown::chrome_print("../Slides/slides_lection_01.Rmd", format = 'pdf',
                       browser = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe")

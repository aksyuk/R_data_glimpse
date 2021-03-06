
# source: https://github.com/yihui/xaringan/wiki/Export-Slides-to-PDF

# install.packages(c("pagedown", "xaringan"))
# # make sure you have pagedown >= 0.2 and xaringan >= 0.9; if not, run
# # remotes::install_github(c('rstudio/pagedown', 'yihui/xaringan'))

library('pagedown')
library('xaringan')

# pagedown::chrome_print("./Lab-01_manual.html",
#                        browser = "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe")

pagedown::chrome_print("./slides_lection_03.Rmd", format = 'pdf',
                       browser = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe")

# pagedown::chrome_print("./slides_practice_OLAP.Rmd",
#                        browser = "/usr/bin/chromium-browser")

# # or just pass the HTML output file path to chrome_print()
# pagedown::chrome_print("path/to/your/slides.html")



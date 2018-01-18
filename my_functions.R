##Get basic githubrepo data

library(jsonlite)
library(httpuv)
library(httr)
library(data.table)
library(rvest)

start_selenium_server<- function(){
  
   system("nohup java -jar ~/Documents/selenium-server-standalone-3.6.0.jar &", show.output.on.console = F)
  
  return('Elinditva')
}

stop_selenium_server <- function() {
  id_hosz <- as.character(system('netstat | grep 4444', intern = T))
  proc_id <- trimws(strsplit(strsplit(id_hosz, 'LISTEN')[[1]][2], '/')[[1]][1])
  system(paste('kill', proc_id), ignore.stdout = T)
  return('megálitva')
}

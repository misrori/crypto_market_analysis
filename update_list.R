library(rvest)
library(RSelenium)
library(data.table)
adat<- read_html('https://coinmarketcap.com/all/views/all/')%>%
  html_nodes('.currency-name-container')%>%
  html_attr('href')

d<- data.table("id"=adat)
d$help <- gsub('/','_', d$id)

d$help<-substr(d$help, 2, nchar(d$help)-1)


mar_meglevok <- list.files("~/Desktop/crypto_market_analysis/filok/")
vannak <- sapply(strsplit(mar_meglevok, ".", fixed = T), "[[", 1)

ezeket <- d[help%in%vannak==F,]

remDr <- remoteDriver(remoteServerAddr = "localhost" 
                      , port = 4444L
                      , browserName = "chrome"
)
remDr$open()



for(i in ezeket$id){
  print(i)
  my_links<- paste0('https://coinmarketcap.com', i)
  fname<- gsub('/','_', i)
  fname<-substr(fname, 2, nchar(fname)-1)
  remDr$navigate(my_links)
  Sys.sleep(1)
  
  webElem <- remDr$findElement("css", "g.highcharts-input-group")
  szoveg <-as.character(webElem$getElementText()[[1]])
  szoveg <-gsub("\n", '',szoveg)
  t<- data.table('id'=i, 'date'=szoveg)
  write.csv(t, paste0('~/Desktop/crypto_market_analysis/filok/', fname, ".csv"), row.names = F)
}



#














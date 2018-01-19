library(data.table)
library(jsonlite)

get_coin_hist_data <- function(coin_list,agg_time){
  
  adat<-data.table()
  for(i in coin_list){
    print(i)
    adat <- rbind(adat, get_one_coin(i,agg_time))
  }
  return(adat)
}


adat <- data.table(rbindlist(lapply(paste0('~/Desktop/crypto_market_analysis/filok/', list.files('~/Desktop/crypto_market_analysis/filok/')),fread)))
setkey(adat, id)
#clean
#####
adat$id<- sapply(strsplit(adat$id, "/"), "[[", 3)

adat$start_date<- gsub('From','',sapply(strsplit(adat$date, "To"), "[[", 1))
adat$start_date <-gsub( 'Jan', '01',adat$start_date)
adat$start_date <-gsub( 'Feb', '02',adat$start_date)
adat$start_date <-gsub( 'Mar', '03',adat$start_date)
adat$start_date <-gsub( 'Apr', '04',adat$start_date)
adat$start_date <-gsub( 'May', '05',adat$start_date)
adat$start_date <-gsub( 'Jun', '06',adat$start_date)
adat$start_date <-gsub( 'Jul', '07',adat$start_date)
adat$start_date <-gsub( 'Aug', '08',adat$start_date)
adat$start_date <-gsub( 'Sep', '09',adat$start_date)
adat$start_date <-gsub( 'Oct', '10',adat$start_date)
adat$start_date <-gsub( 'Nov', '11',adat$start_date)
adat$start_date <-gsub( 'Dec', '12',adat$start_date)


date_help <- as.numeric(gsub(',','',sapply(strsplit(adat$start_date, "\\s+"), "[[", 2)))
my_day <- ifelse(date_help<10, paste('0',date_help, sep = ""), date_help)


month_help <- sapply(strsplit(adat$start_date, "\\s+"), "[[", 1)

year_help <- sapply(strsplit(adat$start_date, "\\s+"), "[[", 3)
adat$start_date <- as.Date(paste(year_help,month_help, my_day, sep = "-"))
adat <- adat[,c(1,3)]
setorder(adat, start_date)
#####


osszes <- data.table(fromJSON("https://api.coinmarketcap.com/v1/ticker/?limit=0"))
setkey(osszes, id)

adat <- osszes[adat]
setorder(adat, start_date)

rm(osszes)

get_one_coin <- function(coin){
  print(coin)
  link<- paste('https://min-api.cryptocompare.com/data/histoday?fsym=',coin,'&tsym=USD&limit=120',sep ="")
  adat <- fromJSON(link)
  if(length(adat$Data)!=0){
    adat<- data.table(adat$Data)
    adat<- adat[high!=0&close!=0&low!=0,]
    adat$time <- as.POSIXct(adat$time, origin="1970-01-01")
    adat$symbol <- coin
    adat <- adat[,c("symbol","time",'close')]
    return(adat)
  }else{
    return(data.frame())
  }
}



my_df_list <- rbindlist(lapply(adat[start_date>=Sys.Date()- lubridate::days(90),]$symbol, get_one_coin))

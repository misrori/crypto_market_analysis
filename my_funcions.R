library(rvest)
library(data.table)
get_one_doboz_ended_ico<- function(adat){
  crypto_names <- 
    adat%>%
    html_nodes("h1")%>%
    html_text()
  crypto_names <- trimws(crypto_names[2:length(crypto_names)])
  
  crypto_id <- 
    adat%>%
    html_nodes("h1 strong")%>%
    html_text()
  
  crypto_id <- trimws(crypto_id)
  
  crypto_cagtegory <- 
    adat%>%
    html_nodes(".category strong")%>%
    html_text()
  
  crypto_days <- 
    adat%>%
    html_nodes(".dt")%>%
    html_text()
  
  
  crypo_linkek <-
    adat%>%
    html_nodes(".links a")%>%
    html_attr("href")
  crypo_linkek <- paste(crypo_linkek, collapse = " # ")
  
  crypto_website <- 
    adat%>%
    html_nodes(".lst-link")%>%
    html_attr("href")
  crypto_website <-paste0("https://www.icolist.com.au", crypto_website)
  
  return(data.table("name"= crypto_names, "id"= crypto_id, "category"= crypto_cagtegory,  "days"= crypto_days,"website"=crypto_website,"linkek" =crypo_linkek))
  
  
}



get_one_page_ended_ico<- function(my_url){
  adatok <- read_html(my_url)
  adat <- adatok%>%
    html_nodes(".listing")
  if(length(adat)<1){
    return(data.table())
  }
  
  one_p <- rbindlist(lapply(adat, get_one_doboz_ended_ico))
  one_p<- one_p[name!="NA",]
  return(one_p)
  
  
}


 



get_ended_icos<- function(){
  my_fin_list <- list()
  szamlalo <- 1
  my_url <-"https://www.icolist.com.au/finished?view_type=tile&q=&t=&page="
  
  while(TRUE){
    d <- get_one_page_ended_ico(paste0(my_url, szamlalo))
    my_fin_list[[szamlalo]] <- d
    szamlalo <- szamlalo+1
    if(nrow(d)==0){
      break
    }
  }
  return(rbindlist(my_fin_list))
  
}

adat <- get_ended_icos()


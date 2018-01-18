library(jsonlite)
library(httpuv)
library(httr)
library(data.table)
library(rvest)
library(RCurl)
library(XML)
library(RSelenium)
source('my_functions.R')


#my_repo <- "https://github.com/antonmks/Alenka"
my_repo <- "https://github.com/kiszk/spark-gpu"


if(file.exists(paste0("/home/mihaly/R_codes/HR_tool/eredmenyek/",author, '_', repo ))==F){
  system(paste('mkdir',paste0("/home/mihaly/R_codes/HR_tool/eredmenyek/",author, '_', repo ) ))
  
}

ere <- get_a_page(paste0(my_repo,'/graphs/contributors'))

idk <- ere%>%
  html_nodes('.float-right+ .text-normal')%>%
  html_attr('href')

commits <- ere%>%
  html_nodes('.link-gray')%>%
  html_text()
a <- lapply(idk, get_git_profile)


top100_commiters <- rbindlist(a)
write.csv(top100_commiters, paste0('eredmenyek/',author,'_',repo,'/',"top_100_git_profile.csv"), row.names = F)

commiters_df <- get_commiters(my_repo)
write.csv(commiters_df, paste0('eredmenyek/',author,'_',repo,'/','all_commiters_from_git_log.csv'), row.names = F)

commiters_df <-commiters_df[duplicated(nev)==F,]
setkey(commiters_df, nev )
setkey(top100_commiters, fullname)

with_email <- commiters_df[top100_commiters]
write.csv(with_email, paste0('eredmenyek/',author,'_',repo,'/','git_profile_with_mail.csv'), row.names = F)
with_email$repo_owner <- with_email$repo_owner[is.na(with_email$repo_owner)==F][1]
with_email$proj <- with_email$proj[is.na(with_email$proj)==F][1]

nevek <- ifelse(with_email$nev=='', with_email$git_name, with_email$nev)
proj<-
ifelse(is.na(with_email$email) | grepl('gmail', with_email$email) | grepl('yahoo', with_email$email) , with_email$proj,
       sapply(strsplit(sapply(strsplit(ifelse(grepl('@', with_email$email),with_email$email, paste0('@',with_email$email)), '@'), "[[", 2), '.', fixed = T),'[[', 1)
              ) 



git_linkek<-NULL
for(i in 1:length(nevek)){
  
  git_linkek<-c(git_linkek, get_Linked_in_links(nev = nevek[i], project = proj[i]))
  
}

with_email$possible_linked_in_profile <- git_linkek

write.csv(with_email, paste0('eredmenyek/',author,'_',repo,'/','git_profile_with_mail_linkedin.csv'), row.names = F)

setwd("/home/mihaly/R_codes/HR_tool/")




#open linked_in
#####

#start_selenium_server()
Sys.sleep(3)

remDr <- remoteDriver(remoteServerAddr = "localhost" 
                      , port = 4444L
                      , browserName = "chrome"
)
remDr$open()
remDr$navigate("http://www.linkedin.com")

Sys.sleep(2)

username <- remDr$findElement(using = "id", value = "login-email")
username$clearElement()
username$sendKeysToElement(list("misroritozsde@gmail.com"))
Sys.sleep(2)

pass <- remDr$findElement(using = "id", value = "login-password")
pass$clearElement()
pass$sendKeysToElement(list("Megleslek"))
Sys.sleep(2)

login_gomb <- remDr$findElement(using = "id", value = "login-submit")
login_gomb$sendKeysToElement(list())
login_gomb$clickElement()

Sys.sleep(5)
#####

my_li<- list()

for(i in 57:nrow(with_email)){
  t <- with_email[i,]
  if(grepl('linkedin.com/in/',t$possible_linked_in_profile)){
    nev <- strsplit(t$possible_linked_in_profile, '/in/')[[1]][2]
    nev <- gsub('/','',nev)
    #remDr$open()
    remDr$navigate(t$possible_linked_in_profile)
    
    Sys.sleep(5)
    webElem <- remDr$findElement("css", "body")
    webElem$sendKeysToElement(list(key = "end"))
    webElem$sendKeysToElement(list(key = "page_up"))
    Sys.sleep(3)
    
   skills_holder <-  tryCatch({
      remDr$findElement("css", ".artdeco-container-card-action-bar")
    }, error = function(e) {
      NULL
    })
   
    if(is.null(skills_holder)!=T){
    
      skills_holder$sendKeysToElement(list(""))
      skills_holder$clickElement()
    }
    Sys.sleep(3)
    page_html <- read_html(remDr$getPageSource()[[1]])
    
    write_html(page_html, paste0('eredmenyek/',author, '_', repo, '/', nev,'.html'))
    #my_li[[i]]<- get_linked_in_profile_data(page_html)
    
    #remDr$close()
  }else{
    my_li[[i]]<- "nem_volt"
  }
  
}

remDr$close()



https://www.linkedin.com/in/kaisasaki/
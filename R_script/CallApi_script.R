#-------------------------------------------------------------------------------------
rm(list = ls())
gc()


lib<-c("dplyr", "plyr", "ggplot2", "data.table", "pracma", "tidyverse",
       "lubridate", "ggridges", "reshape2","knitr","MASS","caret","corrplot",
       "kernlab","data.table","rvest","XML","jsonlite","httr","readxl","xlsx","sn","stringr")

sapply(lib, require, character.only = TRUE)


#-------------------------------------------------------------------------------------
file_path <- "~/Documents/rscript/sh_hackton"      
setwd(file_path)
files <- paste0(file_path,"/",list.files(pattern = "v0.2.xlsx")) #명세서 READ
sh <- excel_sheets(path = files)   

dat <- NULL
for ( i  in 1:(length(sh)-1) ) {
  dat[[i]] <- read.xlsx(files, i, header=TRUE, encoding = "UTF-8")
}

URI_set <- NULL
URI_set <- lapply(1:4, function(x){ 
  data.frame(sh[x], dat[[x]]["URI"],dat[[x]]["API.Request_sample"],dat[[x]]["gubun"])
})


URI_set <- rbindlist(URI_set) ; URI_set <- data.frame(URI_set)
colnames(URI_set) <-c("sh","URI","json_structure","gubun")


# matching table
matching_table <- data.frame(
  sh = c("신한은행","신한카드","신한금투","신한생명"),
  URI_http = c("http://10.3.17.61:8080",
               "http://10.3.17.61:8081",
               "http://10.3.17.61:8082",
               "http://10.3.17.61:8083"),
  stringsAsFactors = FALSE
)

URI_set$sh <- as.character( URI_set$sh )
URI_set_total <- URI_set %>%  na.omit()
# dplyr :: filter(gubun == 1) # 필요한 API 항목 선별
URI_set_total <- left_join(URI_set_total,matching_table, by = "sh")
#-------------------------------------------------------------------------------------
# API 호출 

api_data <- NULL
for ( k  in 1:nrow(URI_set_total)) {
  tmps<-POST(paste0(URI_set_total$URI_http,URI_set_total$URI)[k], body = as.character(URI_set_total$json_structure[k]), encode = "raw")
  try(  total_tmp <-content(tmps) ,silent = TRUE )
  
  api_data[[k]] <- data.frame( sapply( total_tmp$dataBody,c) )
  cat(k)
}


#-------------------------------------------------------------------------------------

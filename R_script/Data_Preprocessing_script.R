
#-------------------------------------------------------------------------------------
# Library 
rm(list = ls())
gc()

lib<-c("dplyr", "plyr", "ggplot2", "data.table", "pracma", "tidyverse",
       "lubridate", "ggridges", "reshape2","knitr","MASS","caret","corrplot",
       "kernlab","data.table","rvest","XML","jsonlite","httr","readxl","xlsx","sn","digest")

suppressMessages(sapply(lib,require,character.only = TRUE))

#-------------------------------------------------------------------------------------
# setwd

file_path <- "~/Documents/rscript/sh_hackton"
setwd(file_path)


#-------------------------------------------------------------------------------------
#--------------------------------- DATA SET #1 ---------------------------------------
#-------------------------------------------------------------------------------------


# 필요 함수 정의 
Specific_rnorm_ft <- function(n, mean, sd, max, min) {
  sample_set <- rnorm(n, mean = mean, sd = sd)
  re_n <-  sum((sample_set < min) | (sample_set > max))
  
  while( re_n >0 ) {
    sample_set[(sample_set < min) | (sample_set > max)] <- rnorm(re_n, mean, sd)
    re_n <-  sum((sample_set < min) | (sample_set > max))
    sd <- sd * 0.9
    if( re_n==0 ) break
  }
  return(sample_set)
}


################

nsize = 3000



#-------------------------------------------------------------------------------------
# Data Preprocessing
#-------------------------------------------------------------------------------------
set.seed(100)
######-------- 1) user_id
profile_user_id <- lapply(1:nsize, function(x){
  user_id <- sprintf("custom_%s", substr(digest(runif(1)),1,5)) 
  return(user_id)}); 
profile_user_id <- data.frame( sapply(profile_user_id,c) ) ; colnames(profile_user_id) <- "profile_user_id"



######-------- 2) 성별 
set.seed(100)
profile_sex <- sample( x=c("F", "M"),
                       prob = c(0.5,0.5), 
                       size = nsize, 
                       replace=TRUE ) %>% data.frame() %>% `colnames<-`(c("profile_sex"))

######-------- 3) 직업 (한국직업사전 참고)



while (1) {
  
  prob_set <- sample(seq(0,1,0.001)[1:200],size = 6,replace =TRUE)
  sample_sum <- sum(prob_set)
  
  if(sample_sum==1)  break
  
}


set.seed(100)
profile_job_M <- sample( x = c(1,2,3,4,5,6),
                       prob = prob_set,
                       size = as.vector( table(profile_sex)[2]),
                       replace = TRUE)  %>% data.frame() %>% `colnames<-`(c("profile_job"))




while (1) {
  
  prob_set <- sample(seq(0,1,0.001)[1:200],size = 6,replace =TRUE)
  sample_sum <- sum(prob_set )
  
  if(sample_sum==1)  break
  
}
profile_job_F <- sample( x = c(1,2,3,4,5,6),
                         prob = prob_set,
                         size = as.vector( table(profile_sex)[1]),
                         replace = TRUE)  %>% data.frame() %>% `colnames<-`(c("profile_job"))


profile_job <- rbind(profile_job_M, profile_job_F)


######-------- 3)-2 직업_카테고리
set.seed(100)
profile_job_category_M <- sample( x = 
                        c("관리자",
                         "전문가",
                         "사무직",
                         # "서비스종사자",
                         "자영업",
                         # "농/어업_종사자",
                         "공무원",
                         "주부"
                         # "무직",
                         # "군인"
                         ), 
                       prob = prob_set,
                       size = as.vector( table(profile_sex)[2]),
                       replace = TRUE)  %>% data.frame() %>% `colnames<-`(c("profile_job_category"))

profile_job_category_F <- sample( x = 
                                    c("관리자",
                                      "전문가",
                                      "사무직",
                                      # "서비스종사자",
                                      "자영업",
                                      # "농/어업_종사자",
                                      "공무원",
                                      "주부"
                                      # "무직",
                                      # "군인"
                                    ), 
                                  prob = prob_set,
                                  size = as.vector( table(profile_sex)[1]),
                                  replace = TRUE)  %>% data.frame() %>% `colnames<-`(c("profile_job_category"))


profile_job_category <- rbind( profile_job_category_M, profile_job_category_F)




######-------- 4) 나이 
set.seed(100)
profile_age <- 
  Specific_rnorm_ft(nsize,45,10,90,19) %>%
  as.integer %>% data.frame() %>% `colnames<-`(c("profile_age"))


######-------- 4)-1 나이대

profile_age_category <- NULL


profile_age_category <- lapply(1:nrow(profile_age), function(x){ 
  
  tmp <- ( profile_age[x,1] %/% 10) * 10
  
  return( paste0(tmp,"대") )
  
} )


profile_age_category <- data.frame(sapply( profile_age_category,c))
colnames(profile_age_category) <- c("profile_age_category")

# profile_age %>%
#   ggplot(aes(x=age)) +
#   geom_histogram()


######-------- 5) 주소 

# site_set <- c("서울시", "경기도","부산광역시", "인천광역시", "대구광역시", "대전광역시",
#               "광주광역시","울산광역시", "경상남도", "충청북도", 
#               "전라북도", "전라남도", "충청남도", "강원도" )


site_set <- c( seq(1,14,1))
set.seed(100)
profile_address <- sample(x =site_set,
                          size = nsize,
                          prob = c(0.5, 0.2, rep(0.3/ (length(site_set)-2),(length(site_set)-2))), 
                          replace =TRUE) %>% data.frame() %>% `colnames<-`(c("profile_address"))


# key="xY8Z4t4%2B3xsD9YhAHUgROlVOTudQQv6roKPTBWyvU9eeOEsrwUfXxPP5mqmS0dZ3ZszHfg98378Qs2ZYxCAgjw%3D%3D"
# api_key = "http://apis.data.go.kr/1611000/nsdi/eios/CnrdlnService"


######-------- 6) 입회경과(월)
set.seed(100)
profile_during_month <- 
  Specific_rnorm_ft(nsize,50,20,400,1) %>%
  as.integer %>% data.frame() %>% `colnames<-`(c("profile_during_month"))


# profile_thedate_month %>%
#    ggplot(aes(x=thedate_month)) +
#    geom_histogram()


######-------- 7) 신용등급(KCB)
set.seed(100)
profile_kcb <- sample( x=c(1,2,3,4,5,6,7,8,9),
                       prob = c(0.09, 0.145, 0.13, 0.14, 0.24, 0.13, 0.08, 0.035, 0.01), 
                       size = nsize, 
                       replace=TRUE ) %>% data.frame() %>% `colnames<-`(c("profile_kcb"))

# profile_kcb %>%
#   ggplot(aes(x=kcb)) +
#   geom_histogram()



######-------- 8) 	profile_married

set.seed(100)
profile_married <- sample(c(TRUE,FALSE), size = nsize, replace = TRUE) %>%
  data.frame() %>% `colnames<-`(c("profile_married"))

######-------- 9) 	profile_children
set.seed(100)
profile_children <- rlnorm(nsize,0.01,.6) %>% 
  as.integer %>%
  data.frame() %>% `colnames<-`(c("profile_children"))


#미혼자는 자녀 수 0
for (i in 1:nrow(profile_children)){
  ifelse(profile_married[i,1] == FALSE , profile_children[i,1] <-0 , profile_children[i,1] <- profile_children[i,1] )
}

######-------- 10) 가족 수

profile_married_count <- ifelse( profile_married == TRUE, 2, 1)
profile_family_cnt <- data.frame( profile_married_count + profile_children )
rm(profile_married_count)

colnames( profile_family_cnt ) <- c("profile_family_cnt")

# 
# ifelse(profile_children > 0, 
# 
# profile_family <- as.integer %>%
#       data.frame() %>% `colnames<-`(c("profile_family"))


######-------- 11) 가족 수 카테고리

profile_married_count_category <- NULL

for ( i  in 1:nrow(profile_family_cnt)){
  profile_married_count_category[[i]] <-
    ifelse(profile_family_cnt[i,1] > 3, "4인이상" , paste0(profile_family_cnt[i,1],"인") )
  
}


profile_married_count_category <- data.frame(sapply(profile_married_count_category,c))

colnames(profile_married_count_category) <- c("profile_married_count_category")

#----------------------------------------------------
######-------- 1) 대출잔액 : finance1_debt_remain(천원)
set.seed(100)
finance1_debt_remain <- 
  Specific_rnorm_ft(nsize,40000,20000,100000,0) %>%
  as.integer %>% data.frame() %>% `colnames<-`(c("finance1_debt_remain"))

# 100명은 대출잔액 0원
finance1_debt_remain[sample(1:nsize,size = 100),1] <- 0  


######-------- 2) 대출이율 : finance1_assets_interest
set.seed(100)
finance1_assets_interest <- 
  Specific_rnorm_ft(nsize,0.025,0.01,0.09,0.01) %>%
  round(3) %>% data.frame() %>% `colnames<-`(c("finance1_assets_interest"))

#대출잔액인 0원인 사용자는 이율 0

for (i in 1:nrow(finance1_debt_remain)){
  
  ifelse(finance1_debt_remain[i,1] == 0, finance1_assets_interest[i,1] <-0 , finance1_assets_interest[i,1] <- finance1_assets_interest[i,1] )
  
}

######-------- 3) 월 소득 : finance1_assets_income(천원)
set.seed(100)
finance1_assets_income <- rlnorm(nsize,7.9,.6) %>% # skwness
  as.integer() %>%
  data.frame() %>% `colnames<-`(c("finance1_assets_income"))


######-------- 4) 총자산 : finance1_assets_amount(천원)
min = 1000 # 백만원 
max = 10000000 # 백억
mean = 74000 # 7천 4백만원 

set.seed(100)
finance1_assets_amount <- 
  Specific_rnorm_ft(nsize,mean,10000,max,min) %>%
  as.integer %>% data.frame() %>% `colnames<-`(c("finance1_assets_amount"))


######-------- 5) 총자산_category

finance1_assets_amount_category <- NULL


for( k  in  1:nrow(finance1_assets_amount) ) {
  
  if( finance1_assets_amount[k,1] <= 10000) {finance1_assets_amount_category[[k]] <- "천만원이하"
  } else if ((finance1_assets_amount[k,1] > 10000) && (finance1_assets_amount[k,1] <= 30000) ) {finance1_assets_amount_category[[k]] <- "1000~3000만원"
  } else if ((finance1_assets_amount[k,1] > 30000) && (finance1_assets_amount[k,1] <= 50000) ) {finance1_assets_amount_category[[k]] <- "3000~5000만원"
  } else if ((finance1_assets_amount[k,1] > 50000) && (finance1_assets_amount[k,1] <= 80000) ) {finance1_assets_amount_category[[k]] <- "5000~8000만원"
  } else if ((finance1_assets_amount[k,1] > 80000) && (finance1_assets_amount[k,1] <= 100000) ) {finance1_assets_amount_category[[k]] <-"8000만원~1억원"
  } else if (finance1_assets_amount[k,1] > 100000) {finance1_assets_amount_category[[k]] <- "1억원초과 "
  }
}



finance1_assets_amount_category <- data.frame( sapply(finance1_assets_amount_category,c))
colnames( finance1_assets_amount_category ) <- c("finance1_assets_amount_category")  



######-------- 6) 월 카드 전체 사용액 : finance2_card_expense_amount(천원)
min = 100 # 10만원  
max = 100000 # 1억 
mean = 1500 # 150만원 

set.seed(100)
finance2_card_expense_amount <- 
  Specific_rnorm_ft(nsize,mean,500,max,min) %>%
  as.integer %>% data.frame() %>% `colnames<-`(c("finance2_card_expense_amount"))


######-------- 7) 할부 개월 수 : finance2_installments(월)

set.seed(100)
finance2_installments <-rlnorm(nsize,1,.6) %>% # skwness
  as.integer() %>%
  data.frame() %>% `colnames<-`(c("finance2_installments"))



######-------- 8) 총누적포인트 : finance2_cul_point

set.seed(100)
finance2_cul_point <-rlnorm(nsize,9,.6) %>% # skwness
  as.integer() %>%
  data.frame() %>% `colnames<-`(c("finance2_cul_point"))

######-------- 9) 총사용포인트 : finance2_use_point


set.seed(100)
finance2_use_point <-rlnorm(nsize,8,.6) %>% # skwness
  as.integer() %>%
  data.frame() %>% `colnames<-`(c("finance2_use_point"))


######-------- 10) 소멸포인트 : finance2_lapse_point
set.seed(100)
finance2_lapse_point <-rlnorm(nsize,8,.6) %>% # skwness
  as.integer() %>%
  data.frame() %>% `colnames<-`(c("finance2_lapse_point"))


######-------- 11) 주 포인트 유형 코드 : finance2_point_code

set<-expand.grid(letters[1:4], paste0(0,seq(1,9,1)))
set.seed(100)

finance2_point_code <- sample( x = paste0(set[,1],set[,2]),
                               size = nsize,
                               replace = TRUE) %>% data.frame() %>% 
  `colnames<-`(c("finance2_point_code"))


######-------- 12) 주 사용 카드 종류 : finance2_main_card


card_set <-c(
  "신한_Mr.Life",
  "신한_DeepDreamPlatinum",	
  "신한_Hi_Point",
  "신한_Noon",
  "신한_B.Big",
  "신한_DeepOnPlatinum",	
  "신한_TheCLASSIC_L",
  "신한_RPM_Platinum",
  "신한_Shopping",
  "신한_The_LADY_CLASSIC",
  "신한_YOLO_Tasty")


set.seed(100)
finance2_main_card <- sample( x = card_set,
                              size = nsize,
                              replace = TRUE) %>% data.frame() %>% 
  `colnames<-`(c("finance2_main_card"))


######-------- 13) SOW(신한카드사용빈도/전체카드사용빈도) : finance2_sow


set.seed(100)
finance2_sow <-round( rlnorm(nsize,1,.6)/20, 2)  %>% # skwness
  data.frame() %>% `colnames<-`(c("finance2_sow"))


######-------- 14) 주요소비처 


main_expense_set <- c("백화점" 
                      #,"대형슈퍼마켓"
                      #,"전자상거래" 
                      ,"통신요금" 
                      ,"문화/레져" 
                      # ,"스포츠" 
                      # ,"외식" 
                      # ,"유흥" 
                      ,"자동차" 
                      #,"주유소" 
                      # ,"양품점" 
                      ,"패션" 
                      #,"미용" 
                      # ,"골프" 
                      ,"병원" 
                      #,"보험" 
                      #,"교통카드" 
                      ,"식생활"
                      ,"주거생활")



while (1) {
  
  prob_set <- sample(seq(0,1,0.001)[1:200],size = length(main_expense_set),replace =TRUE)
  sample_sum <- sum(prob_set )
  
  if(sample_sum==1)  break
  
}

set.seed(100)
finance2_main_expense <- sample( x = main_expense_set,
                                 prob = prob_set,
                                 size = nsize,
                                 replace = TRUE) %>% data.frame() %>% 
  `colnames<-`(c("finance2_main_expense"))


######-------- segment 변수 
# col_set <- ls()[grepl("profile_",ls()) | grepl("finance1_",ls()) | grepl("finance2_",ls())

set.seed(100); prom_가계소비지출비율_1 <- sample(c("상","중","하"), prob = c(0.4,0.5,0.1),size = nsize, replace = TRUE) %>% data.frame() %>% `colnames<-`(c("prom_가계소비지출비율_1"))
set.seed(100); prom_자산비중_2 <- sample(c("상","중","하"), size = nsize, replace = TRUE) %>% data.frame() %>% `colnames<-`(c("prom_자산비중_2"))
set.seed(100); prom_캠핑관심도_3<- sample(c("상","중","하"), prob = c(0.2,0.3,0.5),size = nsize, replace = TRUE) %>% data.frame() %>% `colnames<-`(c("prom_캠핑관심도_3"))
set.seed(100); prom_가족규모_4 <- sample(c("상","중","하"),size = nsize, replace = TRUE) %>% data.frame() %>% `colnames<-`(c("prom_가족규모_4"))
set.seed(100); prom_유류비소비비중_5<- sample(c("상","중","하"), prob = c(0.2,0.3,0.5),size = nsize, replace = TRUE) %>% data.frame() %>% `colnames<-`(c("prom_유류비소비비중_5"))
set.seed(100); prom_차량관심도_6<-   sample(c("상","중","하"),size = nsize, replace = TRUE) %>% data.frame() %>% `colnames<-`(c("prom_차량관심도_6"))

######-------- 1차데이터 완료 
total_data <- data.frame(profile_user_id,
                         profile_sex,
                         profile_job,
                         profile_job_category,
                         profile_age,
                         profile_age_category,
                         profile_address,
                         profile_during_month,
                         profile_kcb,
                         profile_married,    
                         profile_children,
                         profile_family_cnt,
                         profile_married_count_category,
                         finance1_debt_remain, 
                         finance1_assets_interest,
                         finance1_assets_income,
                         finance1_assets_amount,
                         finance1_assets_amount_category,
                         finance2_card_expense_amount,
                         finance2_installments,
                         finance2_cul_point,
                         finance2_use_point,
                         finance2_lapse_point,
                         finance2_point_code,
                         finance2_main_card,
                         finance2_sow,
                         finance2_main_expense,
                         prom_가계소비지출비율_1,
                         prom_자산비중_2,
                         prom_캠핑관심도_3,
                         prom_가족규모_4,
                         prom_유류비소비비중_5,
                         prom_차량관심도_6
                          )

x <- c( "prom_가계소비지출비율_1",
        "prom_자산비중_2",
        "prom_캠핑관심도_3",
        "prom_가족규모_4",
        "prom_유류비소비비중_5",
        "prom_차량관심도_6")

y <- c( "prom_가계소비지출비율_1",
        "prom_자산비중_2",
        "prom_캠핑관심도_3",
        "prom_가족규모_4",
        "prom_유류비소비비중_5",
        "prom_차량관심도_6")



matching <- data.frame(class = c("하하", "중하", "상하", 
                                 "하중", "중중", "상중",
                                 "하상", "중상", "상상"),
                       seg = c(1,2,3,4,5,6,7,8,9) )

xy <- expand.grid(y,x)
xy_set <- xy[!xy[,1] == xy[,2],]



tmpxy_total <- data.frame(c=1:nsize)

for ( i in 1: nrow(xy_set)) {
  tmpx <- total_data[,colnames(total_data) == xy_set[i,2]];
  tmpy <- total_data[,colnames(total_data) == xy_set[i,1]];
  
  tmpxy <- data.frame( paste0(tmpx,tmpy));colnames(tmpxy) <-"class"
  tmpxy <- left_join(tmpxy,matching) 
  
  
  name1 <- substr(xy_set[i,2], nchar(as.vector(xy_set[i,2])), nchar(as.vector(xy_set[i,2])))
  name2 <- substr(xy_set[i,1], nchar(as.vector(xy_set[i,1])), nchar(as.vector(xy_set[i,1])))
  
  
  colnames(tmpxy) <- c(paste0("prom_",name1,"_",name2),
                       paste0("prom_",name1,"_",name2,"_seg"))
  
  
  tmpxy_total<-cbind(tmpxy_total, tmpxy)
  
}


tmpxy_total <- tmpxy_total[,-1]

######-------- 2차데이터 완료 
total_data2 <- cbind( total_data,tmpxy_total)
write_json(total_data2, "data_set1_total_10000.json", pretty = TRUE, auto_unbox = TRUE)

# 
# # rm(data_set1_json)
# # data_set1_json <- toJSON(total_data)
# # write(data_set1_json, "data_set1.json")
# write_json(total_data, "data_set1_v3.json", pretty = TRUE, auto_unbox = TRUE)






#-------------------------------------------------------------------------------------
#--------------------------------- DATA SET #2 ---------------------------------------
#-------------------------------------------------------------------------------------



matching <- data.frame(class = c("하하", "중하", "상하", 
                                 "하중", "중중", "상중",
                                 "하상", "중상", "상상"),
                       seg = c(1,2,3,4,5,6,7,8,9) )
######-------- DATA SET #2-0
x1_유류비 <- sample(c("상","중","하"), size = 1000, prob = c(0.1,0.3,0.6),replace = TRUE) 
x2_레져비용소비비율 <- sample(c("상","중","하"), size = 1000, replace = TRUE) 


tmp <- data.frame( paste0( x1_유류비,x2_레져비용소비비율)); colnames(tmp) <- "class"
tmp <- left_join(tmp,matching)

x1_x2_seg <- data.frame ( tmp$seg ); colnames(x1_x2_seg) <-"seg"


data_set2_test <- data.frame(x1_유류비,x2_레져비용소비비율,x1_x2_seg)
write_json(data_set2_test, "data_set2_test_re.json", pretty = TRUE, auto_unbox = TRUE)


######-------- DATA SET #2-1 : 전업주부 대상으로 한 소형 SUV(베뉴)
x_가계소비지출비율 <- sample(c("상","중","하"), prob = c(0.4,0.5,0.1),size = 1000, replace = TRUE) 
y_레져비용소비비율 <- sample(c("상","중","하"), size = 1000, replace = TRUE) 

tmp <- data.frame( paste0( x_가계소비지출비율,y_레져비용소비비율)); colnames(tmp) <- "class"

tmp <- left_join(tmp,matching)
xy_seg <- data.frame ( tmp$seg ); colnames(xy_seg) <-"seg"


data_set2_1 <- data.frame(x_가계소비지출비율,y_레져비용소비비율,xy_seg)
write_json(data_set2_1, "data_set2_1.json", pretty = TRUE, auto_unbox = TRUE)




######-------- DATA SET #2-2 : 가족단위 액티비티를 즐기는 고객을 대상으로 캠핑카

x_캠핑관심도<- sample(c("상","중","하"), prob = c(0.2,0.3,0.5),size = 1000, replace = TRUE) 
y_가족규모 <- sample(c("3인이상","2인","1인"),size = 1000, replace = TRUE) 

tmp <- data.frame( paste0( x_캠핑관심도,y_가족규모)); colnames(tmp) <- "class"


matching2 <- data.frame(class = c("하1인", "중1인", "상1인", 
                                 "하2인", "중2인", "상2인",
                                 "하3인이상", "중3인이상", "상3인이상"),
                       seg = c(1,2,3,4,5,6,7,8,9) )



tmp <- left_join(tmp,matching2)
xy_seg <- data.frame ( tmp$seg ); colnames(xy_seg) <-"seg"


data_set2_2 <- data.frame(x_캠핑관심도,y_가족규모,xy_seg)
write_json(data_set2_2, "data_set2_2.json", pretty = TRUE, auto_unbox = TRUE)

# 프로모션3. 전기차 
# —> x: 유류비 소비 비중(상/중/하)
# —> y: 차량관심도 (자동차 관련 소비 비중으로 산출하며 상/중/하)

######-------- DATA SET #2-3 : 전기차

x_유류비소비비중<- sample(c("상","중","하"), prob = c(0.2,0.3,0.5),size = 1000, replace = TRUE) 
y_차량관심도<-   sample(c("상","중","하"),size = 1000, replace = TRUE) 

tmp <- data.frame( paste0( x_유류비소비비중,y_차량관심도)); colnames(tmp) <- "class"


tmp <- left_join(tmp,matching)
xy_seg <- data.frame ( tmp$seg ); colnames(xy_seg) <-"seg"


data_set2_3 <- data.frame(x_유류비소비비중,y_차량관심도,xy_seg)
write_json(data_set2_3, "data_set2_3.json", pretty = TRUE, auto_unbox = TRUE)



#-------------------------------------------------------------------------------------
#--------------------------------- DATA SET #3 ---------------------------------------
#-------------------------------------------------------------------------------------
rm(list = ls())
gc()
######-------- DATA SET #3

# time set 생성
Time_Set_Function <- function(k){
  
  while(k){
    x <- ymd_hms("2019-01-01 00:00:00")
    time_set <- NULL
    time_set <- lapply(1:24, function(k){
      x <- x+3600*(k-1);
      time_set[[k]] <- paste0( format(x,'%H'),"H" )
      
    })
    time_set <- as.matrix( sapply(time_set,c))
    colnames(time_set) <-"time"
    return(time_set) }
}


time_data_set <- NULL

for(k in 1:4) {
  
######-------- DATA SET #3-1 (대상군이휴대폰을자주보는시간대)
  
  while (1) {
    
    set_one <- sample(seq(0,1,0.001)[1:100],size = 24,replace =TRUE)
    sample_sum <- sum(set_one )
    
    if(sample_sum==1)  break
    
  }
  
  time_set <- Time_Set_Function(1)
  time_set_sample <- sample(time_set,1000, prob = set_one ,replace = TRUE) 
  data_set31 <- time_set_sample %>% table() %>% data.frame() 
  
  
  if(nrow(data_set31) <24) {
    time_set <- data.frame(time_set)
    colnames(time_set) <-"time"
    colnames(data_set31) <- c("time","freq")
    ttset <- left_join(time_set, data_set31)
    ttset[is.na(ttset[,2]),2] <-0
    data_set31 <- ttset
  }
  
  
  colnames(data_set31) <- c("시간대","freq")
  # data_set31 <- list(대상군이휴대폰을자주보는시간대 = data_set31)
  
  
  
######-------- DATA SET #3-2 (대상 군의 예상 취침 시간대)
  
  time_set <- Time_Set_Function(1)
  sample_set <- c( sample(  x = time_set[ (grepl("21H",time_set) |  grepl("22H",time_set) |  grepl("23H",time_set) |  grepl("23H",time_set) |
                                             grepl("00H",time_set) | grepl("01H",time_set))],
                            size = 900,
                            replace =  TRUE)
                   
                   ,sample(  x = time_set[ !(grepl("21H",time_set) |  grepl("22H",time_set) |  grepl("23H",time_set) |  grepl("23H",time_set) |
                                               grepl("00H",time_set) | grepl("01H",time_set))],
                             size = 100,
                             replace =  TRUE) )
  
  
  data_set32 <- sample_set %>% table() %>% data.frame() 
  colnames(data_set32) <- c("시간대 ","freq")
  
  #---- 24개 미만일 경우 해당되는 행에 0의 값 기입 
  if(nrow(data_set32) < 24){
    tmp <-NULL
    tmp <- data.frame( 시간대 = c( time_set[!time_set %in% sort( unique(time_set_sample))]),
                      freq = rep(0,1,sum(!time_set %in% sort( unique(time_set_sample)))))
    
    
    data_set32 <-rbind(data_set32, tmp)
  }
  
  # data_set32 <- list(대상군의예상취침시간대 = data_set32)
  
  
######--------DATA SET #3-3 (반응율이적은시간대)
  
  time_set <- Time_Set_Function(1)
  
  # data 생성 
  while (1) {
    
    set_one <- sample(seq(0,1,0.001)[1:100],size = 24,replace =TRUE)
    sample_sum <- sum(set_one )
    
    if(sample_sum==1)  break
    
  }
  time_set_sample <- sample(time_set,1000, prob = set_one ,replace = TRUE) 
  data_set33 <- time_set_sample %>% table() %>% data.frame() 
  colnames(data_set33) <- c("시간대","freq")
  #---- 24개 미만일 경우 해당되는 행에 0의 값 기입 
  if(nrow(data_set33) < 24){
    tmp <-NULL
    tmp <- data.frame( 시간대 = c( time_set[!time_set %in% sort( unique(time_set_sample))]),
                      freq = rep(0,1,sum(!time_set %in% sort( unique(time_set_sample)))))
    
    
    data_set33 <-rbind(data_set33, tmp)
  }
  
  # data_set33 <- list(반응율이적은시간대 = data_set33)
  
  
  
######-------- DATA SET #3-4 (반응율이적은시간대)
  data_set34 <-sample(x = paste0( seq(11,49,1),"%") ,size=1)
  
  time_data_set[[k]] <- list("대상군이휴대폰을자주보는시간대" = data_set31, 
                             "대상군의예상취침시간대" = data_set32, 
                             "반응율이적은시간대" = data_set33,
                             "긍정반응율" = data_set34)
  
}

x1 <- list( target_id = 1, 
            time_data_set[[1]])
x2 <- list( target_id = 2, 
            time_data_set[[2]])
x3 <- list( target_id = 3, 
            time_data_set[[3]])
x4 <- list( target_id = 4, 
            time_data_set[[4]])
xxxx_plot <- list(프로모션1=x1,프로모션2=x2,프로모션3=x3,프로모션4=x4)

write_json(xxxx_plot, "data_set3_time_v6.json", pretty = TRUE, auto_unbox = TRUE)

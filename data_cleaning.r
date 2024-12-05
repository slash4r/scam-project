library(tidyverse)

categorize_job <- function(title) {
  # Check for IT subcategories first
  if (grepl("програміст|розробник|software engineer|developer|frontend|backend|fullstack|HTML", title, ignore.case = TRUE)) {
    return("Software Development")
  } else if (grepl("тестувальник|qa|quality assurance|test|тестування|тестировщиков|Тестирование", title, ignore.case = TRUE)) {
    return("Testing")
  } else if (grepl("адміністратор|DevOps|sysadmin|network|infrastructure|administrator|системный администратор", title, ignore.case = TRUE)) {
    return("System Administration / DevOps")
  } else if (grepl("аналітик|data scientist|data engineer|big data|data|analyst", title, ignore.case = TRUE)) {
    return("Data Analysis / Data Science")
  } else if (grepl("AI|machine learning|штучний інтелект|deep learning|computer vision|research|науковий співробітник", title, ignore.case = TRUE)) {
    return("AI / Research")
  }
  else if (grepl("дизайнер|ux|ui|graphic|web design|illustrator|photoshop|designer|artist", title, ignore.case = TRUE)) {
    return("Design")
  }
  else if (grepl("ремонт|maintenance|technician|service|монтажник|майстер|Технік", title, ignore.case = TRUE)) {
    return("Repair / Maintenance")
  }
  else if (grepl("інженер|engineering|engineer|mechanical engineer|civil engineer|engineer|Збиральник", title, ignore.case = TRUE)) {
    return("Engineering")
  }
  return("Non-IT")
}

govern_tb <- read_csv('/home/kyarish/Documents/GitHub/scam-project/data/govern_offers2.csv')
govern_tb %>% glimpse()
govern_tb <- govern_tb%>%
mutate(site_name = case_when(
    str_detect(Site, "logo_1") ~ "governmental",
    str_detect(Site, "robota") ~ "robota",
    str_detect(Site, "jooble.png") ~ "jooble",
    str_detect(Site, "pidbir.png") ~ "pidbir",
    str_detect(Site, "work.png") ~ "work",
    str_detect(Site, "grc_ua_logo.png") ~ "grc.ua",
    TRUE ~ "Other"))



govern_tb <- govern_tb %>%
mutate(
    Salary_from = Salary %>% str_remove_all(" ") %>%
    str_remove("грн") %>% as.numeric(),
    Salary_to = Salary %>% str_remove_all(" ") %>%
    str_remove("грн") %>% as.numeric()
    
)

govern_tb <- govern_tb %>%
select(-c(Site, Salary))

govern_tb$Employment_Type %>% unique()
govern_tb <- govern_tb %>%
mutate(
    Location = ifelse(str_detect(Employment_Type,"дистанційно"), "remote", Location),
    Employment_Type = case_when(
        Employment_Type == "повна,неповна" ~ "Full-Time, Part-Time",
        str_detect(Employment_Type, "повна") ~ "Full-Time",
        str_detect(Employment_Type, "неповна") ~ "Part-Time",
        str_detect(Employment_Type, "проектна") ~ "Part-Time"
    )
)



govern_tb <- govern_tb %>%
  mutate(Job_Category = sapply(Title, categorize_job))
govern_tb %>% glimpse()


happy_tb <- read_csv("data/happy_offers3.csv")
happy_tb %>% glimpse()

happy_tb <- happy_tb %>% 
  mutate(
    Salary_from = str_remove_all(Salary, "грн.*| ") %>% 
                  str_extract("^\\d+"),
    Salary_to = str_remove_all(Salary, "грн.*| ") %>% 
                str_extract("(?<=–)\\d+")
  ) %>% 
  mutate(
    Salary_from = as.numeric(Salary_from),
    Salary_to = as.numeric(Salary_to),
    site_name = 'HappyMonday',
    Location = str_remove_all(Location, "\\s*\\(Україна\\)\\s*")
  )
happy_tb<- happy_tb %>% 
  select(-`...5`)

# View the cleaned data
happy_tb <- happy_tb %>%
  mutate(Job_Category = sapply(Title, categorize_job))
happy_tb %>% glimpse()




# write.csv(all_jobs, "all_jobs.csv", row.names = FALSE)

olx_tb <- read_csv("data/olx_offers.csv")
olx_tb %>% glimpse()


olx_tb <- olx_tb %>% 
  mutate(
    currency = case_when(
      str_detect(Salary, "грн") ~ "грн",
      str_detect(Salary, "\\$") ~ "$",
      TRUE ~ "грн"
    ),
    Salary_from = str_remove_all(Salary, "грн.*|\\$.*| ") %>% 
                  str_extract("^\\d+") %>% 
                  as.numeric(),
    Salary_to = str_remove_all(Salary, "грн.*|\\$.*| ") %>% 
                str_extract("(?<=[-–])\\d+") %>% 
                as.numeric(),
    Salary_from = ifelse(currency == "$", Salary_from * 42, Salary_from),
    Salary_to = ifelse(currency == "$", Salary_to * 42, Salary_to),
    site_name = 'OLX'
  )
olx_tb$currency

olx_tb <- olx_tb %>% mutate(
  Location = ifelse(Employment_Type %in% c("Удаленная работа","Віддалена робота"),"remote", Location ),
  Location = ifelse(str_detect(Location,","), strsplit(Location, ", ")[[1]][1], Location),
  Employment_Type = case_when(
    Employment_Type %in% c("Повна зайнятість", "Полная занятость") ~ "Full-Time",
    Employment_Type %in% c("Віддалена робота", "Удаленная работа") ~ NA_character_, # Use NA_character_ for character columns
    TRUE ~ "Part-Time"
  )
)



city_translation <- c(
  "Киев" = "Київ",
  "Чернигов" = "Чернігів",
  "Уклин" = "Уклін",
  "Белая Церковь" = "Біла Церква",
  "Черкассы" = "Черкаси",
  "Умань" = "Умань",
  "Нетешин" = "Нетішин",
  "Черновцы" = "Чернівці",
  "Мукачево" = "Мукачево",
  "Никополь" = "Нікополь",
  "Ходосівка" = "Ходосівка",  # Already correct
  "Полтава" = "Полтава",  # Already correct
  "Рівне" = "Рівне",  # Already correct
  "Херсон" = "Херсон",  # Already correct
  "Кам'янське" = "Кам'янське",  # Already correct
  "Слов'янськ" = "Слов'янськ",  # Already correct
  "Луцьк" = "Луцьк",  # Already correct
  "Корсунці" = "Корсунці",  # Already correct
  "Кременчук" = "Кременчук",  # Already correct
  "Стрий" = "Стрий",  # Already correct
  "Тернопіль" = "Тернопіль",  # Already correct
  "Хмельницький" = "Хмельницький",  # Already correct
  "Чернівці" = "Чернівці",  # Already correct
  "Сміла" = "Сміла",  # Already correct
  "Біла Церква" = "Біла Церква",  # Already correct
  "Івано-Франківськ" = "Івано-Франківськ",  # Already correct
  "Кам'янець-Подільський" = "Кам'янець-Подільський",  # Already correct
  "Дзюби" = "Дзюби",
  "Золотоноша" = "Золотоноша",
  "Суми" = "Суми",
  "Бровари" = "Бровари",
  "Софіївська Борщагівка" = "Софіївська Борщагівка",
  "Ужгород" = "Ужгород",
  "Васильків" = "Васильків",
  "Інженерний" = "Інженерний",
  "Березне" = "Березне",
  "Ковель" = "Ковель",
  "Козятин" = "Козятин",
  "Павлоград" = "Павлоград"
)

olx_tb <- olx_tb %>%
mutate(
  Location = recode(Location, !!!city_translation, .default = Location)
)

olx_tb$Location %>% unique()

olx_tb <- olx_tb %>%
  mutate(Job_Category = sapply(Title, categorize_job))

olx_tb <- olx_tb %>% mutate(
  Company = NA
)

olx_tb <- olx_tb %>%
select("Title","Location","Company","Employment_Type","site_name","Salary_from","Salary_to","Job_Category","Salary")
olx_tb %>% glimpse()

all_jobs <- bind_rows(govern_tb, happy_tb, olx_tb)
glimpse(all_jobs)

write.csv(all_jobs, "all_jobs.csv", row.names = FALSE)

library(tidyverse)

categorize_job <- function(title) {
  # Check for IT subcategories first
  if (grepl("програміст|розробник|software engineer|developer|frontend|backend|fullstack", title, ignore.case = TRUE)) {
    return("Software Development")
  } else if (grepl("тестувальник|qa|quality assurance|test", title, ignore.case = TRUE)) {
    return("Testing")
  } else if (grepl("адміністратор|DevOps|sysadmin|network|infrastructure", title, ignore.case = TRUE)) {
    return("System Administration / DevOps")
  } else if (grepl("аналітик|data scientist|data engineer|big data|data", title, ignore.case = TRUE)) {
    return("Data Analysis / Data Science")
  } else if (grepl("AI|machine learning|штучний інтелект|deep learning|computer vision|research|науковий співробітник", title, ignore.case = TRUE)) {
    return("AI / Research")
  }
  else if (grepl("дизайнер|ux|ui|graphic|web design|illustrator|photoshop", title, ignore.case = TRUE)) {
    return("Design")
  }
  else if (grepl("ремонт|maintenance|technician|service", title, ignore.case = TRUE)) {
    return("Repair / Maintenance")
  }
  return("Non-IT")
}

govern_tb <- read_csv('/home/kyarish/Documents/GitHub/scam-project/data/govern_offers2.csv')
govern_tb %>% glimpse()
govern_tb <- govern_tb%>%
mutate(site_name = case_when(
    str_detect(Site, "logo_1") ~ "governmental",
    str_detect(Site, "robota") ~ "robota",
    str_detect(Site, "jooble") ~ "jooble",
    str_detect(Site, "pidbir") ~ "pidbir",
    str_detect(Site, "grc.ua") ~ "grc.ua",
    TRUE ~ "Other"
))



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
    site_name = 'HappyMonday'
  )
happy_tb<- happy_tb %>% 
  select(-`...5`)

# View the cleaned data
happy_tb <- happy_tb %>%
  mutate(Job_Category = sapply(Title, categorize_job))
happy_tb %>% glimpse()

all_jobs <- bind_rows(govern_tb, happy_tb)
glimpse(all_jobs)


write.csv(all_jobs, "all_jobs.csv", row.names = FALSE)
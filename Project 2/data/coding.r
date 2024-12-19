library(tidyverse)

missile_attacks <- read_csv("/home/kyarish/Documents/GitHub/scam-project/Project 2/data/Massive Missile Attacks on Ukraine/missile_attacks_daily.csv")

categorize_missile <- function(missile) {
  severity_scores <- c(
    "High-powered missiles" = 10,
    "Medium-powered missiles" = 7,
    "Drones" = 3,
    "Composite weapon types" = 5,
    "Low-powered missiles / Others" = 2,
    "Unknown" = NA_real_  # Default for unknown categories
  )
  
  if (grepl("3M22 Zircon|Iskander-M|Iskander-K|X-47 Kinzhal|Kalibr|X-101/X-555|X-22|P-800 Oniks|X-59", missile, ignore.case = TRUE)) {
    return(severity_scores["High-powered missiles"])
  }
  else if (grepl("C-300|C-400|C-300/C-400|C-300/C-400 and Iskander-M|C-400 and Iskander-M|Iskander-M/KN-23|X-22/X-31P|X-22/X-32|X-31PD|X-31|KAB", missile, ignore.case = TRUE)) {
    return(severity_scores["Medium-powered missiles"])
  }
  else if (grepl("Shahed-136/131|Lancet|Mohajer-6|Orion|Orlan-10|Orlan-30|ZALA|Supercam|Merlin-VR|Eleron|Reconnaissance UAV|Unknown UAV", missile, ignore.case = TRUE)) {
    return(severity_scores["Drones"])
  }
  else if (grepl("Orlan-10 and Supercam|Orlan-10 and ZALA|Shahed-136/131 and Lancet|Orlan-10 and ZALA and Supercam|Orlan-10 and Orlan-30 and ZALA and Supercam", missile, ignore.case = TRUE)) {
    return(severity_scores["Composite weapon types"])
  }
  else if (grepl("Aerial Bomb|Grad/Urgan Rockets|Granat-4|Forpost|Картограф|Привет-82|Фенікс", missile, ignore.case = TRUE)) {
    return(severity_scores["Low-powered missiles / Others"])
  }
  
  return(severity_scores["Unknown"])  
}

missile_attacks <- missile_attacks %>% 
    mutate(
        missile_scoring = sapply(model, categorize_missile), 
        total_score = missile_scoring * launched,
        date = as.Date(time_start))


##  two cols day and total score per day
missile_attacks_score_per_day <- missile_attacks %>% 
group_by(date)%>%
summarize(total_score_per_day = sum(total_score))
print(missile_attacks_score_per_day, n = 10001)


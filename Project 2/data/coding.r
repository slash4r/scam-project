library(tidyverse)
library(tidymodels)

missile_attacks <- read_csv("/home/kyarish/Documents/GitHub/scam-project/Project 2/data/Massive Missile Attacks on Ukraine/missile_attacks_daily.csv")
missile_attacks %>% glimpse()
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
        date = as.Date(time_end))
        
missile_attacks <- missile_attacks[!is.na(missile_attacks$total_score), ]
##  two cols day and total score per day
missile_attacks_score_per_day <- missile_attacks %>% 
group_by(date)%>%
summarize(total_score_per_day = sum(total_score))

full_date_range <- seq.Date(from = min(missile_attacks$date), to = max(missile_attacks$date), by = "day")

complete_dataset <- tibble(date = full_date_range) %>%
  left_join(missile_attacks_score_per_day, by = "date") %>%
  replace_na(list(total_score_per_day = 0))

print(complete_dataset, n = 100)





#### kvitkas part 

significant_dates <- as.Date(c("2022-08-24",
    "2023-08-24",
    "2024-08-24",
    "2022-12-25",
    "2023-12-25",
    "2024-12-25",
    "2022-12-06",
    "2023-12-06",
    "2024-12-06",
    "2022-01-25",
    "2023-01-25",
    "2024-01-25",
    "2022-01-01",
    "2023-01-01",
    "2024-01-01",
    "2022-01-01",
    "2023-01-01",
    "2024-01-01",
    "2022-06-28",
    "2023-06-28",
    "2024-06-28",
    "2022-05-09",
    "2023-05-09",
    "2024-05-09",
    "2022-10-07",
    "2023-10-07",
    "2024-10-07",
    "2022-04-24",
    "2023-04-16",
    "2024-04-16"
))

missile_attacks_score_per_day_significant <- complete_dataset %>%
  mutate(significant_date = ifelse(
    date %in% significant_dates, TRUE, FALSE
  ))

missile_attacks_score_per_day_significant %>% glimpse()
# without removed outliers
t.test(total_score_per_day ~ significant_date, missile_attacks_score_per_day_significant)

# with removed outliers IQR
Q1 <- quantile(missile_attacks_score_per_day_significant$total_score_per_day, 0.25, na.rm = TRUE)
Q3 <- quantile(missile_attacks_score_per_day_significant$total_score_per_day, 0.75, na.rm=TRUE)
Q3
IQR <- Q3 - Q1

upper_threshold <- Q3 + 1.5 * IQR
upper_threshold

filtered_date <- missile_attacks_score_per_day_significant %>% filter(total_score_per_day < 125)
filtered_date

t.test(total_score_per_day ~ significant_date, missile_attacks_score_per_day_significant,alternative = "less")


```{r}
#| label: box plot
#| warning: false
#| fig-width: 9
#| fig-asp: 0.618
#| echo: false

ggplot(missile_attacks_score_per_day_significant, aes(x = significant_date, y = total_score_per_day, fill = significant_date)) +
  geom_boxplot(alpha = 0.7) +
  labs(
    title = "Severity of missile attacks ",
    x = "Significant date",
    y = "Severity score",
    fill = "Significant day"
  ) +
  theme_minimal() +
  theme(
    legend.position = "top",
    plot.title = element_text(size = 20),
    axis.text = element_text(size = 10)
  )
```
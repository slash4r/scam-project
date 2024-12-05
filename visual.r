library(ggplot2)
library(dplyr)
library(readr)
library(stringr)
library(scales)

file_path <- "all_jobs.csv"
job_data <- read_csv(file_path, show_col_types = FALSE)

# Filter out non-IT vacancies (adjust the condition as per your dataset)
job_data <- job_data %>%
  filter(Job_Category != "Non-IT")

extract_salary <- function(salary_str) {
  if (is.na(salary_str)) return(NA)

  salary_str <- gsub("[^0-9–-]", "", salary_str)

  if (str_detect(salary_str, "–|-")) {
    parts <- as.numeric(unlist(str_split(salary_str, "–|-")))
    return(mean(parts, na.rm = TRUE))
  }

  return(as.numeric(salary_str))
}

job_data <- job_data %>%
  mutate(
    Salary = sapply(Salary, extract_salary),
    Salary_from = as.numeric(Salary_from),
    Salary_to = as.numeric(Salary_to),
    Salary = ifelse(is.na(Salary), (Salary_from + Salary_to) / 2, Salary)
  )

job_data <- job_data %>%
  mutate(Salary_Provided = !is.na(Salary))

salary_visibility <- job_data %>%
  group_by(Job_Category) %>%
  summarize(
    Percentage_Companies_Showing_Salaries = mean(Salary_Provided, na.rm = TRUE) * 100,
    Total_Jobs = n(),
    .groups = "drop"
  )

salary_visibility_by_platform <- job_data %>%
  group_by(site_name) %>%
  summarize(
    Percentage_Salaries_Showing = mean(Salary_Provided, na.rm = TRUE) * 100,
    Total_Jobs = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(Percentage_Salaries_Showing))

job_data <- job_data %>%
  filter(Salary > 0 & Salary < 500000)

minimum_vacancies <- 30
average_salary_by_category <- job_data %>%
  group_by(Job_Category) %>%
  summarize(
    Average_Salary = mean(Salary, na.rm = TRUE),
    Total_Jobs = n(),
    Salary_Std_Dev = sd(Salary, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(Total_Jobs >= minimum_vacancies) %>%
  arrange(desc(Average_Salary))

average_salary_by_city <- job_data %>%
  group_by(Location) %>%
  summarize(
    Average_Salary = mean(Salary, na.rm = TRUE),
    Total_Jobs = n(),
    Salary_Std_Dev = sd(Salary, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(Total_Jobs >= minimum_vacancies) %>%
  arrange(desc(Average_Salary))

remote_vs_office <- job_data %>%
  group_by(Employment_Type) %>%
  summarize(
    Average_Salary = mean(Salary, na.rm = TRUE),
    Total_Jobs = n(),
    Salary_Std_Dev = sd(Salary, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(!is.na(Employment_Type), Total_Jobs >= minimum_vacancies) %>%
  arrange(desc(Average_Salary))

ggplot(average_salary_by_category, aes(x = reorder(Job_Category, Average_Salary), y = Average_Salary, fill = Total_Jobs)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(
    title = "Average Salary by Job Category (IT Only, Minimum 30 Vacancies)",
    subtitle = "Bars colored by total number of vacancies",
    x = "Job Category",
    y = "Average Salary (UAH)"
  ) +
  scale_fill_gradient(name = "Total Vacancies", low = "lightblue", high = "darkblue") +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 8))

top_cities <- average_salary_by_city %>%
  slice_max(order_by = Average_Salary, n = 15)

ggplot(top_cities, aes(x = reorder(Location, Average_Salary), y = Average_Salary, fill = Total_Jobs)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(
    title = "Average Salary by City (IT Only, Top 15, Minimum 30 Vacancies)",
    subtitle = "Bars colored by total number of vacancies",
    x = "City",
    y = "Average Salary (UAH)"
  ) +
  scale_fill_gradient(name = "Total Vacancies", low = "lightgreen", high = "darkgreen") +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 8))

ggplot(remote_vs_office, aes(x = Employment_Type, y = Average_Salary, fill = Total_Jobs)) +
  geom_bar(stat = "identity", show.legend = TRUE) +
  labs(
    title = "Remote vs Office Work: Average Salary (IT Only, Minimum 30 Vacancies)",
    subtitle = "Bars colored by total number of vacancies",
    x = "Employment Type",
    y = "Average Salary (UAH)",
    fill = "Total Vacancies"
  ) +
  scale_fill_gradient(low = "pink", high = "red") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(salary_visibility, aes(x = reorder(Job_Category, Percentage_Companies_Showing_Salaries), y = Percentage_Companies_Showing_Salaries, fill = Total_Jobs)) +
  geom_bar(stat = "identity", show.legend = TRUE) +
  coord_flip() +
  labs(
    title = "Percentage of Companies Showing Salaries by Job Category (IT Only)",
    subtitle = "Bars colored by total number of vacancies",
    x = "Job Category",
    y = "Percentage (%)",
    fill = "Total Vacancies"
  ) +
  scale_fill_gradient(low = "yellow", high = "orange") +
  theme_minimal()

ggplot(salary_visibility_by_platform, aes(x = reorder(site_name, Percentage_Salaries_Showing), y = Percentage_Salaries_Showing, fill = Total_Jobs)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(
    title = "Percentage of Job Postings Showing Salaries by Platform (IT Only)",
    subtitle = "Bars colored by total number of vacancies",
    x = "Platform",
    y = "Percentage (%)",
    fill = "Total Vacancies"
  ) +
  scale_fill_gradient(low = "lightgray", high = "black") +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 8))

ggplot(job_data, aes(x = Salary)) +
  geom_histogram(binwidth = 5000, fill = "skyblue", color = "black") +
  scale_x_continuous(
    labels = scales::comma,
    breaks = seq(0, 300000, by = 20000)
  ) +
  labs(
    title = "Distribution of Salaries Across All IT Job Postings",
    x = "Salary (UAH)",
    y = "Number of Job Postings"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

boxplot_data <- job_data %>%
  group_by(Job_Category) %>%
  filter(n() >= minimum_vacancies)

ggplot(boxplot_data, aes(x = reorder(Job_Category, Salary, median), y = Salary)) +
  geom_boxplot(fill = "lightcoral") +
  coord_flip() +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Salary Distribution by Job Category (IT Only, Minimum 30 Vacancies)",
    x = "Job Category",
    y = "Salary (UAH)"
  ) +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 8))

employment_type_data <- job_data %>%
  filter(!is.na(Employment_Type)) %>%
  group_by(Job_Category, Employment_Type) %>%
  summarize(
    Total_Jobs = n(),
    .groups = "drop"
  )

employment_type_data <- employment_type_data %>%
  group_by(Job_Category) %>%
  mutate(Percentage = Total_Jobs / sum(Total_Jobs) * 100)

employment_type_data <- employment_type_data %>%
  group_by(Job_Category) %>%
  filter(sum(Total_Jobs) >= minimum_vacancies)

ggplot(employment_type_data, aes(x = Job_Category, y = Percentage, fill = Employment_Type)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(
    title = "Proportion of Employment Types within IT Job Categories (Minimum 30 Vacancies)",
    x = "Job Category",
    y = "Percentage (%)",
    fill = "Employment Type"
  ) +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 8))

top_categories <- job_data %>%
  group_by(Job_Category) %>%
  summarize(
    Total_Jobs = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(Total_Jobs)) %>%
  slice_max(Total_Jobs, n = 10)

ggplot(top_categories, aes(x = reorder(Job_Category, Total_Jobs), y = Total_Jobs)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top 10 IT Job Categories by Total Vacancies",
    x = "Job Category",
    y = "Number of Vacancies"
  ) +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 8))

avg_salary_vacancies <- job_data %>%
  group_by(Job_Category) %>%
  summarize(
    Average_Salary = mean(Salary, na.rm = TRUE),
    Total_Jobs = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(Average_Salary))

ggplot(avg_salary_vacancies, aes(x = Total_Jobs, y = Average_Salary, label = Job_Category)) +
  geom_point(color = "darkorange", size = 3) +
  geom_text(vjust = -0.5, size = 3) +
  scale_y_continuous(labels = scales::comma) +
  scale_x_continuous(labels = scales::comma) +
  labs(
    title = "Average Salary vs Total Vacancies by IT Job Category",
    x = "Total Vacancies",
    y = "Average Salary (UAH)"
  ) +
  theme_minimal()
library(dplyr)

# Simulate the main dataset
main_data <- data.frame(
  date = as.Date("2024-12-01") + 0:3,
  aircraft = c(10, 11, 12, 13),
  helicopter = c(5, 5, 6, 6),
  tank = c(20, 21, 23, 24),
  APC = c(15, 15, 17, 18),
  field_artillery = c(8, 9, 10, 11),
  MRL = c(2, 2, 3, 3),
  drone = c(3, 4, 5, 6),
  naval_ship = c(0, 0, 0, 0),
  submarines = c(0, 0, 0, 0),
  anti_aircraft_warfare = c(5, 5, 5, 5),
  special_equipment = c(10, 11, 12, 13),
  vehicles_and_fuel_tanks = c(12, 12, 13, 14),
  cruise_missiles = c(0, 0, 0, 0)
)

# Simulate the correction dataset
corrections <- data.frame(
  date = as.Date(c("2024-12-02", "2024-12-03", "2024-12-04")),
  aircraft = c(1, 0, 1),
  helicopter = c(0, -1, 0),
  tank = c(0, 1, -2),
  APC = c(-2, 0, 0),
  field_artillery = c(0, 0, 1),
  MRL = c(1, 0, 0),
  drone = c(2, -1, 0),
  naval_ship = c(0, 0, 0),
  submarines = c(0, 0, 0),
  anti_aircraft_warfare = c(0, 0, 0),
  special_equipment = c(0, 0, 0),
  vehicles_and_fuel_tanks = c(3, 2, 0),
  cruise_missiles = c(1, 0, 0)
)

write.csv(main_data, "main_dataset.csv", row.names = FALSE)
write.csv(corrections, "correction_dataset.csv", row.names = FALSE)

### --- Now, let's try to apply the corrections to the main dataset --- ###


main_data <- read.csv("main_dataset.csv")
corrections <- read.csv("correction_dataset.csv")


apply_corrections <- function(main_data, corrections) {
    corrected_data <- main_data %>%
        left_join(corrections, by = "date", suffix = c("", "_correction"))
        
    corrected_columns <- c("aircraft", "helicopter", "tank", "APC", "field_artillery",
                                                 "MRL", "drone", "naval_ship", "submarines", 
                                                 "anti_aircraft_warfare", "special_equipment", 
                                                 "vehicles_and_fuel_tanks", "cruise_missiles")
    
    for (col in corrected_columns) {
        correction_col <- paste0(col, "_correction")
        if (correction_col %in% colnames(corrected_data)) {
            # replace NA in correction with 0 (на всяк випадок)
            corrected_data[[correction_col]][is.na(corrected_data[[correction_col]])] <- 0
            
            # cumulative correction
            corrected_data[[col]] <- corrected_data[[col]] + cumsum(replace_na(corrected_data[[correction_col]], 0))
        }
    }
    
    # Remove correction columns
    corrected_data <- corrected_data %>%
        select(-ends_with("_correction"))
    
    return(corrected_data)
}

# Apply corrections
corrected_dataset <- apply_corrections(main_data, corrections)

# Save the corrected dataset
write.csv(corrected_dataset, "corrected_dataset.csv", row.names = FALSE)

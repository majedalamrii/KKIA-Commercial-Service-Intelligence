# ==============================================================================
# Project: KKIA Commercial Service Intelligence
# Author: Majed ALAMRI
# Description:
# Statistical analysis of commercial-service distribution at
# King Khalid International Airport using public Saudi open data.
#
# Expected input object:
#   airport
#
# Expected columns:
#   TRADE_CATEGORY
#   TRADE_SUBCATEGORY
#   BRAND_NAME
#   LOCATION
#   TERMINAL
# ==============================================================================

library(dplyr)
library(ggplot2)

# 1. DATA CLEANING ---------------------------------------------------------------

airport_clean <- airport %>%
  mutate(across(everything(), trimws)) %>%
  mutate(across(everything(), ~ na_if(.x, "null"))) %>%
  mutate(
    BRAND_NAME = case_when(
      BRAND_NAME == "City Fresh Kitchen CafÃ©" ~ "City Fresh Kitchen Café",
      BRAND_NAME == "LagardÃ¨re" ~ "Lagardère",
      BRAND_NAME == "Dr. CafÃ© Coffee" ~ "Dr. Café Coffee",
      BRAND_NAME == "Mama Bunz CafÃ©" ~ "Mama Bunz Café",
      BRAND_NAME == "Archi CafÃ©" ~ "Archi Café",
      BRAND_NAME == "Simit Sarayi CafÃ©" ~ "Simit Sarayi Café",
      BRAND_NAME == "Java CafÃ©" ~ "Java Café",
      BRAND_NAME == "Urth CafÃ©" ~ "Urth Café",
      BRAND_NAME == "Hudson CafÃ©" ~ "Hudson Café",
      TRUE ~ BRAND_NAME
    )
  ) %>%
  filter(!if_all(everything(), is.na()))

# Exact duplicate rows are intentionally retained because the dataset
# contains no unique store/service identifier proving that repeated rows
# are data-entry errors.

cat("Clean rows:", nrow(airport_clean), "\n")
cat("Missing values:", sum(is.na(airport_clean)), "\n")

# 2. ARRIVAL VS DEPARTURE --------------------------------------------------------

chi_data <- airport_clean %>%
  filter(LOCATION %in% c("Arrival", "Departure"))

arrival_departure_category <- chi_data %>%
  count(LOCATION, TRADE_CATEGORY, name = "Number_of_Services") %>%
  group_by(LOCATION) %>%
  mutate(
    Location_Total = sum(Number_of_Services),
    Percentage = round(Number_of_Services / Location_Total * 100, 1)
  ) %>%
  ungroup()

print(arrival_departure_category)

ggplot(
  arrival_departure_category,
  aes(
    x = TRADE_CATEGORY,
    y = Number_of_Services,
    fill = LOCATION
  )
) +
  geom_col(position = "dodge") +
  labs(
    title = "Trade Categories: Arrival vs Departure",
    x = "Trade Category",
    y = "Number of Services",
    fill = "Location"
  ) +
  theme_minimal()

chi_table <- table(
  chi_data$LOCATION,
  chi_data$TRADE_CATEGORY
)

chi_result <- chisq.test(chi_table)

cat(
  "Arrival/Departure expected cells below 5:",
  sum(chi_result$expected < 5), "\n"
)

cat(
  "Arrival/Departure percentage below 5:",
  round(mean(chi_result$expected < 5) * 100, 1), "%\n"
)

set.seed(123)

fisher_result <- fisher.test(
  chi_table,
  simulate.p.value = TRUE,
  B = 100000
)

print(fisher_result)

# 3. ARRIVAL VS DEPARTURE STANDARDIZED RESIDUALS --------------------------------

arrival_residuals <- as.data.frame(
  as.table(chi_result$stdres)
)

names(arrival_residuals) <- c(
  "Location",
  "Trade_Category",
  "Standardized_Residual"
)

important_arrival_residuals <- arrival_residuals %>%
  mutate(
    Absolute_Residual = abs(Standardized_Residual)
  ) %>%
  filter(Absolute_Residual > 2) %>%
  arrange(desc(Absolute_Residual))

print(important_arrival_residuals)

# 4. TERMINALS 1-5 ---------------------------------------------------------------

terminal_data <- airport_clean %>%
  filter(
    TERMINAL %in% c(
      "Terminal 1",
      "Terminal 2",
      "Terminal 3",
      "Terminal 4",
      "Terminal 5"
    )
  )

terminal_counts <- terminal_data %>%
  count(TERMINAL, name = "Number_of_Services") %>%
  mutate(
    Percentage = round(
      Number_of_Services / sum(Number_of_Services) * 100,
      1
    )
  ) %>%
  arrange(desc(Number_of_Services))

print(terminal_counts)

terminal_category <- terminal_data %>%
  count(
    TERMINAL,
    TRADE_CATEGORY,
    name = "Number_of_Services"
  ) %>%
  group_by(TERMINAL) %>%
  mutate(
    Terminal_Total = sum(Number_of_Services),
    Percentage = round(
      Number_of_Services / Terminal_Total * 100,
      1
    )
  ) %>%
  ungroup()

ggplot(
  terminal_category,
  aes(
    x = TERMINAL,
    y = Number_of_Services,
    fill = TRADE_CATEGORY
  )
) +
  geom_col() +
  labs(
    title = "Service Composition by Terminal",
    x = "Terminal",
    y = "Number of Services",
    fill = "Trade Category"
  ) +
  theme_minimal()

# 5. RESTAURANT ANALYSIS ---------------------------------------------------------

restaurants_terminal <- airport_clean %>%
  filter(
    TERMINAL %in% c(
      "Terminal 1",
      "Terminal 2",
      "Terminal 3",
      "Terminal 4",
      "Terminal 5"
    ),
    TRADE_SUBCATEGORY %in% c(
      "Restaurant",
      "Restaurants"
    )
  ) %>%
  count(
    TERMINAL,
    name = "Restaurants"
  )

total_services_terminal <- terminal_data %>%
  count(
    TERMINAL,
    name = "Total_Services"
  )

restaurant_share <- total_services_terminal %>%
  left_join(
    restaurants_terminal,
    by = "TERMINAL"
  ) %>%
  mutate(
    Restaurants = coalesce(Restaurants, 0L),
    Restaurant_Share = round(
      Restaurants / Total_Services * 100,
      1
    )
  ) %>%
  arrange(desc(Restaurant_Share))

print(restaurant_share)

ggplot(
  restaurant_share,
  aes(
    x = reorder(TERMINAL, Restaurant_Share),
    y = Restaurant_Share
  )
) +
  geom_col() +
  geom_text(
    aes(
      label = paste0(Restaurant_Share, "%")
    ),
    hjust = -0.2
  ) +
  coord_flip() +
  labs(
    title = "Restaurant Share by Terminal",
    x = "Terminal",
    y = "Restaurant Share (%)"
  ) +
  theme_minimal()

# 6. TERMINAL × TRADE CATEGORY --------------------------------------------------

terminal_table <- table(
  terminal_data$TERMINAL,
  terminal_data$TRADE_CATEGORY
)

terminal_chi <- chisq.test(
  terminal_table
)

print(terminal_chi)

cat(
  "Terminal expected cells below 5:",
  sum(terminal_chi$expected < 5), "\n"
)

cat(
  "Terminal percentage below 5:",
  round(
    mean(terminal_chi$expected < 5) * 100,
    1
  ),
  "%\n"
)

set.seed(123)

terminal_fisher <- fisher.test(
  terminal_table,
  simulate.p.value = TRUE,
  B = 100000
)

print(terminal_fisher)

# 7. TERMINAL STANDARDIZED RESIDUALS --------------------------------------------

terminal_residuals <- terminal_chi$stdres

residual_data <- as.data.frame(
  as.table(terminal_residuals)
)

names(residual_data) <- c(
  "Terminal",
  "Trade_Category",
  "Standardized_Residual"
)

important_terminal_residuals <- residual_data %>%
  mutate(
    Absolute_Residual = abs(Standardized_Residual)
  ) %>%
  filter(Absolute_Residual > 2) %>%
  arrange(desc(Absolute_Residual))

print(important_terminal_residuals)

# 8. SERVICE CONCENTRATION -------------------------------------------------------

service_concentration <- terminal_data %>%
  count(
    TERMINAL,
    TRADE_CATEGORY,
    name = "Number_of_Services"
  ) %>%
  group_by(TERMINAL) %>%
  mutate(
    Total_Services = sum(Number_of_Services),
    Percentage = round(
      Number_of_Services / Total_Services * 100,
      1
    )
  ) %>%
  ungroup()

dominant_service <- service_concentration %>%
  group_by(TERMINAL) %>%
  slice_max(
    order_by = Percentage,
    n = 1,
    with_ties = FALSE
  ) %>%
  ungroup() %>%
  arrange(desc(Percentage))

print(dominant_service)

# 9. SHANNON DIVERSITY -----------------------------------------------------------

terminal_diversity <- service_concentration %>%
  group_by(TERMINAL) %>%
  summarise(
    Total_Services = sum(Number_of_Services),
    Number_of_Categories = n(),
    Shannon_Index = -sum(
      (Number_of_Services / sum(Number_of_Services)) *
      log(
        Number_of_Services /
        sum(Number_of_Services)
      )
    ),
    .groups = "drop"
  ) %>%
  mutate(
    Shannon_Index = round(
      Shannon_Index,
      3
    )
  ) %>%
  arrange(desc(Shannon_Index))

print(terminal_diversity)

ggplot(
  terminal_diversity,
  aes(
    x = reorder(TERMINAL, Shannon_Index),
    y = Shannon_Index
  )
) +
  geom_col() +
  geom_text(
    aes(label = Shannon_Index),
    hjust = -0.2
  ) +
  coord_flip() +
  labs(
    title = "Service Diversity by Terminal",
    subtitle = "Shannon Diversity Index based on service categories",
    x = "Terminal",
    y = "Shannon Diversity Index"
  ) +
  theme_minimal()

# ==============================================================================
# End of analysis
# ==============================================================================

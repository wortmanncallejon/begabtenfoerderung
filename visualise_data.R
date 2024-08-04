###########################################

# PROJECT TITLE: Begabtenförderung

# AUTHOR: Felix Wortmann Callejón

# Date: 2024-08-04

###########################################

#install.packages("pacman")

pacman::p_load("dplyr", "ggplot2", "here", "readxl", "tidyr")

# Aggreagtion von Daten über alle Begabtenförderwerke hinweg

data_agg <- read_xlsx(here("_data", "clean_data.xlsx")) |>
    summarise(across(c(n, N), \(x) sum(x, na.rm = T)),
              .by = c("Jahr", "Variable", "Ausprägung"))

# Anzahl Geförderte über Zeit 

data_agg |>
    distinct(Jahr, N) |>
    ggplot(aes(x = Jahr, y = N)) +
    geom_line() +
    geom_point() +
    scale_x_continuous(NULL, breaks = 2013:2022, label = function (x) as.character(x)) +
    scale_y_continuous("Anzahl Geförderte", labels = scales::label_comma()) +
    theme_light(base_size = 24)

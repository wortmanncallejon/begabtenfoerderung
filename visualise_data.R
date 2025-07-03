###########################################

# PROJECT TITLE: Begabtenförderung

# AUTHOR: Felix Wortmann Callejón

# Date: 2024-08-04

###########################################

#install.packages("pacman")

pacman::p_load("dplyr", "ggplot2", "here", "readxl", "tidyr", "viridis")

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
    scale_x_continuous(NULL, breaks = 2013:2024, label = function (x) paste0("'", substr(as.character(x),3,4))) +
    scale_y_continuous("Anzahl Geförderte", labels = scales::label_comma()) +
    theme_light(base_size = 14)

ggsave(here("_plots", "total_stips.png"), width = 16, height = 9, dpi = 300, units = "cm")

data_agg |>
    filter(Variable == "Förderungsart") |>
    mutate(BAFöG = ifelse(Ausprägung == "SKP", "Nein", "Ja")) |>
    summarise(across(c(n, N), \(x) sum(x, na.rm = T)),
              .by = c("Jahr", "BAFöG")) |>
    ggplot(aes(x = Jahr, y = n, color = BAFöG)) +
    geom_line() +
    geom_point() +
    scale_x_continuous(NULL, breaks = 2013:2024, label = function (x) paste0("'", substr(as.character(x),3,4))) +
    scale_y_continuous("Anzahl Geförderte", labels = scales::label_comma()) +
    scale_color_viridis("BAFöG-Berechtigung", discrete = T) +
    theme_light(base_size = 14) +
    theme(legend.position = "bottom")

ggsave(here("_plots", "förderungsart.png"), width = 16, height = 9, dpi = 300, units = "cm")

data_agg |>
    filter(Variable == "Förderungsart") |>
    mutate(BAFöG = ifelse(Ausprägung == "SKP", "Nein", "Ja")) |>
    summarise(across(c(n, N), \(x) sum(x, na.rm = T)),
              .by = c("Jahr", "BAFöG")) |>
    mutate(baseline = mean(ifelse(Jahr == 2013, n, NA), na.rm = T),
            .by = BAFöG) |>
    mutate(indicator = (n/baseline)) |>
    ggplot(aes(x = Jahr, y = indicator, color = BAFöG)) +
    geom_line() +
    geom_point() +
    scale_x_continuous(NULL, breaks = 2013:2024, label = function (x) paste0("'", substr(as.character(x),3,4))) +
    scale_y_continuous("Wachstum Geförderte", labels = scales::label_percent()) +
    scale_color_viridis("BAFöG-Berechtigung", discrete = T) +
    theme_light(base_size = 14) +
    theme(legend.position = "bottom")

ggsave(here("_plots", "förderungsart_indicator.png"), width = 16, height = 9, dpi = 300, units = "cm")

data_agg |>
    filter(Variable == "Migrationshintergrund") |>
    mutate(Ausprägung = ifelse(Ausprägung == "Migrationshintergrund", "Ja", "Nein")) |>
    ggplot(aes(x = Jahr, y = n, color = Ausprägung)) +
    geom_line() +
    geom_point() +
    scale_x_continuous(NULL, breaks = 2013:2024, label = function (x) paste0("'", substr(as.character(x),3,4))) +
    scale_y_continuous("Wachstum seit 2013", labels = scales::label_comma(1)) +
    scale_color_viridis("Migrationshintergrund", discrete = T) +
    theme_light(base_size = 14) +
    theme(legend.position = "bottom")

ggsave(here("_plots", "migrationshintergrund.png"), width = 16, height = 9, dpi = 300, units = "cm")

data_agg |>
    filter(Variable == "Migrationshintergrund") |>
    mutate(Ausprägung = ifelse(Ausprägung == "Migrationshintergrund", "Ja", "Nein")) |>
    mutate(baseline = mean(ifelse(Jahr == 2013, n, NA), na.rm = T),
            .by = Ausprägung) |>
    mutate(indicator = (n/baseline)) |>
    ggplot(aes(x = Jahr, y = indicator, color = Ausprägung)) +
    geom_line() +
    geom_point() +
    scale_x_continuous(NULL, breaks = 2013:2024, label = function (x) paste0("'", substr(as.character(x),3,4))) +
    scale_y_continuous("Wachstum seit 2013", labels = scales::label_percent(1)) +
    scale_color_viridis("Migrationshintergrund", discrete = T) +
    theme_light(base_size = 14) +
    theme(legend.position = "bottom")

ggsave(here("_plots", "migrationshintergrund_indicator.png"), width = 16, height = 9, dpi = 300, units = "cm")

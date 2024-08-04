###########################################

# PROJECT TITLE: Begabtenförderung

# AUTHOR: Felix Wortmann Callejón

# Date: 2024-08-04

###########################################

#install.packages("pacman")

pacman::p_load("dplyr", "ggplot2", "here", "readxl", "tidyr")

files <- list.files(here("_data"))

förderungsart <- read_xlsx(here("_data", files[2]), range = "A2:U16") |> 
    pivot_longer(-Werk) |> 
    mutate(int = as.integer(sub(".*\\.+", "", name)),
           Jahr = case_when(int < 6 ~ 2013,
                            int < 10 ~ 2014,
                            int < 14 ~ 2015,
                            int < 18 ~ 2016,
                            int < 22 ~ 2017),
            type = sub("\\.\\.\\.\\d{0,2}$", "", name)) |>
    select(Werk, Jahr, type, value) |>
    filter(Werk != "Jahr") |>
    pivot_wider(names_from = type, values_from = value) |>
    arrange(Werk, Gesamt, SKP, Teil, Voll, Jahr)


frauen <- read_xlsx(here("_data", files[2]), range = "A2:K15", sheet = 2) |> 
    pivot_longer(-Werke, names_to = "Jahr", values_to = "Frauen") |>
    mutate(Werk = sub("\\*", "", Werke),
           Jahr = as.integer(Jahr)) |>
    select(Werk, Jahr, Frauen)


migrationshintergrund <- read_xlsx(here("_data", files[2]), range = "A2:K15", sheet = 3) |> 
    mutate(across(everything(), as.character)) |>
    pivot_longer(-Werke, names_to = "Jahr", values_to = "Migrationshintergrund") |>
    mutate(Werk = sub("\\*", "", Werke),
           Jahr = as.integer(Jahr),
           Migrationshintergrund = as.integer(ifelse(Migrationshintergrund == "-", NA, Migrationshintergrund))) |>
    select(Werk, Jahr, Migrationshintergrund)

erstakademikerinnen <- read_xlsx(here("_data", files[2]), range = "A2:K15", sheet = 4) |> 
    mutate(across(everything(), as.character)) |>
    pivot_longer(-Werke, names_to = "Jahr", values_to = "Erstakademikerinnen") |>
    mutate(Werk = sub("\\*\\*", "", Werke),
           Jahr = as.integer(Jahr),
           Erstakademikerinnen = as.integer(ifelse(Erstakademikerinnen %in% c("0", "***"), NA, Erstakademikerinnen))) |>
    select(Werk, Jahr, Erstakademikerinnen)






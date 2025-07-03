###########################################

# PROJECT TITLE: Begabtenförderung

# AUTHOR: Felix Wortmann Callejón

# Date: 2025-07-03

###########################################


# Setup ----
## Load dependencies

#install.packages("pacman")

pacman::p_load("dplyr", "ggplot2", "here", "readxl", "tidyr", "purrr", "stringr", "writexl")

## Load data files
files <- list.files(here("_data"))
files <- files[grep("frderung(\\d{4})?\\.xlsx$", files)]

# Read and process "clean" data from 2013 - 2020 ----
## BMBF provided us with a pre-cleaned set of variables of special interest. These are read here.

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
    select(Werk, Gesamt, SKP, Teil, Voll, Jahr) |>
    bind_rows(read_xlsx(here("_data", "stips.xlsx"))) |>
    pivot_longer(-c("Werk", "Jahr", "Gesamt"), names_to = "Ausprägung", values_to = "n") |>
    mutate(Variable = "Förderungsart") |>
    rename(N = Gesamt) |>
    select(Werk, Jahr, N, Variable, Ausprägung, n) |>
    arrange(Jahr, Werk)

frauen <- read_xlsx(here("_data", files[2]), range = "A2:K15", sheet = 2) |> 
    pivot_longer(-Werke, names_to = "Jahr", values_to = "Frauen") |>
    mutate(Werk = sub("\\*", "", Werke),
           Jahr = as.integer(Jahr)) |>
    select(Werk, Jahr, Frauen) |>
    left_join(select(förderungsart, Werk, Jahr, N), by = c("Werk", "Jahr")) |>
    distinct(Werk, Jahr, .keep_all = T) |>
    mutate(Männer = N - Frauen) |>
    pivot_longer(-c("Werk", "Jahr", "N"), names_to = "Ausprägung", values_to = "n") |>
    mutate(Variable = "Geschlecht") |>
    select(Werk, Jahr, N, Variable, Ausprägung, n) |>
    arrange(Jahr, Werk)

migrationshintergrund <- read_xlsx(here("_data", files[2]), range = "A2:K15", sheet = 3) |> 
    mutate(across(everything(), as.character)) |>
    pivot_longer(-Werke, names_to = "Jahr", values_to = "Migrationshintergrund") |>
    mutate(Werk = sub("\\*", "", Werke),
           Jahr = as.integer(Jahr),
           Migrationshintergrund = as.integer(ifelse(Migrationshintergrund == "-", NA, Migrationshintergrund))) |>
    select(Werk, Jahr, Migrationshintergrund) |>
    left_join(select(förderungsart, Werk, Jahr, N), by = c("Werk", "Jahr")) |>
    distinct(Werk, Jahr, .keep_all = T) |>
    mutate(`Kein Migrationshintergrund` = N - Migrationshintergrund) |>
    pivot_longer(-c("Werk", "Jahr", "N"), names_to = "Ausprägung", values_to = "n") |>
    mutate(Variable = "Migrationshintergrund") |>
    select(Werk, Jahr, N, Variable, Ausprägung, n) |>
    arrange(Jahr, Werk)


## Combine all data and write to Excel file
bind_rows(förderungsart, frauen, migrationshintergrund) |> 
    writexl::write_xlsx(here("_data", "clean_data.xlsx"))

# Additional data for 2023 and 2024 ----

## Common cleaning steps
new_data <- files[grep("studien", files)][2:3] |>
    map(~read_xlsx(here("_data", .x))) |>
    bind_rows(.id = "Jahr") |>
    rename(Werk = `Project type - Begabtenfoerderungswerke text`,
           N = `Gesamtanzahl Geförderte`,
           SKP = `nur Studienkostenpauschale`,
           Teil = `Geförderte mit Teilstipendium`,
           Voll = `Geförderte mit Vollstipendium`,
           Frauen = `Gesamtanzahl - weiblich`,
           Migrationshintergrund = `Gesamtanzahl - mit Migrationshintergrund`) |>
    rowwise() |>
    mutate(Jahr = ifelse(Jahr == 1, 2024, 2023),
           Werk = unlist(str_split(Werk, " "))[1]) |>
    select(Werk, Jahr:Migrationshintergrund)

## Create new data frames for 2023 and 2024
förderungsart_2324 <- new_data |>
    select(Werk:N, SKP:Voll) |>
    pivot_longer(SKP:Voll, names_to = "Ausprägung", values_to = "n") |>
    mutate(Variable = "Förderungsart") |>
    select(Werk, Jahr, N, Variable, Ausprägung, n)

frauen_2324 <- new_data |>
    select(Werk:N, Frauen) |>
    mutate(Männer = N - Frauen) |>
    pivot_longer(Frauen:Männer, names_to = "Ausprägung", values_to = "n") |>
    mutate(Variable = "Geschlecht") |>
    select(Werk, Jahr, N, Variable, Ausprägung, n)

migrationshintergrund_2324 <- new_data |>
    select(Werk:N, Migrationshintergrund) |>
    mutate(`Kein Migrationshintergrund` = N - Migrationshintergrund) |>
    pivot_longer(Migrationshintergrund:`Kein Migrationshintergrund`, names_to = "Ausprägung", values_to = "n") |>
    mutate(Variable = "Migrationshintergrund") |>
    select(Werk, Jahr, N, Variable, Ausprägung, n)

## Combine new data and write to Excel file
bind_rows(förderungsart_2324, frauen_2324, migrationshintergrund_2324) |> 
    bind_rows(förderungsart, frauen, migrationshintergrund) |>
    arrange(Jahr, Werk) |>
    writexl::write_xlsx(here("_data", "clean_data.xlsx"))

# Defunct code ---- 

## Measurement of this data is really opaque, hence it is not processed further
erstakademikerinnen <- read_xlsx(here("_data", files[2]), range = "A2:K15", sheet = 4) |> 
    mutate(across(everything(), as.character)) |>
    pivot_longer(-Werke, names_to = "Jahr", values_to = "Erstakademikerinnen") |>
    mutate(Werk = sub("\\*\\*", "", Werke),
           Jahr = as.integer(Jahr),
           Erstakademikerinnen = as.integer(ifelse(Erstakademikerinnen %in% c("0", "***"), NA, Erstakademikerinnen)))

## Overview over other criteria from base data 
read_xlsx(here("_data", files[2]), sheet = 5) |> 
    mutate(across(everything(), as.character)) |>
    pivot_longer(-c("Jahr", Werke), names_to = "Kriterium", values_to = "n") |>
    summarise(n = sum(as.integer(n), na.rm = T),
              .by = c("Kriterium")) |>
    rowwise() |>
    mutate(var_1 = unlist(strsplit(Kriterium, " - "))[1],
           var_2 = unlist(strsplit(Kriterium, " - "))[2],
           var_3 = unlist(strsplit(Kriterium, " - "))[3]) |>
    ungroup() |>
    select(var_1, var_2, var_3, n)
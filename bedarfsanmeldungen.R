###########################################

# PROJECT TITLE: Begabtenförderung

# AUTHOR: Felix Wortmann Callejón

# Date: 2026-02-12

###########################################


# Setup ----
## Load dependencies

#install.packages("pacman")

pacman::p_load("dplyr", "ggplot2", "here", "readxl", "tidyr", "purrr", "stringr", "writexl")

## Load data files
files <- list.files(here("_data", "bedarfsanmeldungen"))

bedarfsanmeldungen <- here("_data", "bedarfsanmeldungen", files[2]) |>
  read_excel() |>
  pivot_longer(-`...1`, names_to = "year", values_to = "bedarfsanmeldungen") |>
  rename(werk = `...1`)

bewilligungen <- here("_data", "bedarfsanmeldungen", files[2]) |>
  read_excel(sheet = 2) |>
  pivot_longer(-`...1`, names_to = "year", values_to = "bewilligungen") |>
  rename(werk = `...1`)

money <- full_join(bedarfsanmeldungen, bewilligungen, by = c("werk", "year")) |>
  mutate(year = as.integer(year),
         quote = ifelse(bedarfsanmeldungen != 0, bewilligungen/bedarfsanmeldungen, 0)) |>
  pivot_longer(c(bedarfsanmeldungen, bewilligungen, quote), names_to = "variable", values_to = "euro")
  arrange(werk, year) 

# CUS

theme <- theme_light(base_size = 14, base_family = "CMU Sans Serif")+ theme(panel.grid = element_blank())

money |>
  filter(!werk %in% c("Gesamt", "StS") & variable != "quote") |>
  mutate(cusanus = ifelse(werk == "CUS", "CUS", "Other"),
         typ = case_when(werk %in% c("CUS", "Avicenna", "ESW", "ELES") ~ "Religiöse Werke",
                         werk %in% c("FES", "FNS", "hbs_böll", "HSS", "KAS", "RLS") ~ "Politische Werke",
                         werk %in% c("HBS", "SDW") ~ "Wirtschaftliche Werke",
                         TRUE ~ "Sonstige Werke")) |>
    ggplot(aes(x = year, y = euro, color = werk, linetype = variable, shape = variable, alpha = cusanus)) +
    scale_alpha_manual(values = c("CUS" = 1, "Other" = 0.5)) +
    scale_linetype_discrete(NULL, labels = c("Bedarfsanmeldungen", "Bewilligungen")) +
    scale_shape_discrete(NULL, labels = c("Bedarfsanmeldungen", "Bewilligungen")) +
    scale_y_continuous(labels = scales::label_currency(prefix = "€", suffix = "M", scale = 1e-6)) +
    geom_line() +
    geom_point() +
    guides(alpha = "none") +
    labs(x = "Jahr",
         y = "Euro",
         color = NULL) +
    theme +
    facet_grid(typ ~ ., scales = "free_y") +
    theme(legend.position = "bottom")

ggsave(here("_plots", "bedarfsanmeldungen.png"), width = 12, height = 8, dpi = 300)


money |>
  filter(!werk %in% c("Gesamt") & variable == "quote") |>
  mutate(cusanus = ifelse(werk == "CUS", "CUS", "Other"),
         typ = case_when(werk %in% c("CUS", "Avicenna", "ESW", "ELES") ~ "Religiöse Werke",
                         werk %in% c("FES", "FNS", "hbs_böll", "HSS", "KAS", "RLS") ~ "Politische Werke",
                         werk %in% c("HBS", "SDW") ~ "Wirtschaftliche Werke",
                         TRUE ~ "Studienstiftung")) |>
    ggplot(aes(x = year, y = euro, color = werk, alpha = cusanus)) +
    scale_alpha_manual(values = c("CUS" = 1, "Other" = 0.5)) +
    scale_y_continuous(labels = scales::label_percent(1)) +
    geom_line() +
    geom_point() +
    guides(alpha = "none") +
    labs(x = "Jahr",
         y = "Bewillingungsquote (Bewilligungen / Bedarfsanmeldungen)",
         color = NULL) +
    theme +
    facet_grid(typ ~ ., scales = "free_y") +
    theme(legend.position = "bottom")

ggsave(here("_plots", "quoten.png"), width = 12, height = 8, dpi = 300)

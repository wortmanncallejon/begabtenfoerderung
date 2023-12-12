###########################################

# PROJECT TITLE: Stipendiat:innen

# AUTHOR: Felix Wortmann Callejón

# Date: 2023-12-12

###########################################

pacman::p_load("dplyr", "ggplot2", "here", "readxl")


# Anteil Stips SKP/Vollstipendium over time -----

read_xlsx(here("_data", "stips.xlsx")) %>% 
  mutate(across(SKP:Voll, \(x) x/Gesamt)) %>% 
  rename("SK-Pauschale" = "SKP",
         "Teilstipendium" = "Teil",
         "Vollstipendium" = "Voll") %>% 
  tidyr::pivot_longer(cols = `SK-Pauschale`:Vollstipendium, names_to = "Art der Förderung", values_to = "Anteil") %>% 
  mutate(col = ifelse(Werk == "hbs", "HBS", "Andere"),
         lab = ifelse(Jahr == 2022, Werk, NA),
         dot = ifelse(Jahr == 2022, Anteil, NA)) %>% 
  filter(`Art der Förderung` != "Teilstipendium") %>% 
  ggplot(aes(x = Jahr, y = Anteil, color = col, group = Werk)) +
  scale_y_continuous("Anteil der Stipendiat:innen", labels = scales::label_percent(1), limits = c(0,0.75)) +
  scale_x_continuous(NULL, limits = c(2018,2022.6), breaks = 2018:2022 ,labels = function(x) paste0("'",substr(x,nchar(x)-1, nchar(x)))) +
  scale_color_manual(values = c("lightgrey", "#97d700")) +
  geom_line() +
  geom_point(aes(y = dot)) +
  geom_text(aes(label = lab, x = Jahr + 0.2), hjust = 0, size = 2, family = "Helvetica Neue") +
  facet_wrap(~`Art der Förderung`) +
  theme_light(base_family = "Helvetica Neue") +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        legend.position = "none")

ggsave(here("_plots","förderung_stips.png"), width = 16, height = 9, units = "cm", dpi = 600)  

# Gesamtzahl Stips Werke over time -----

read_xlsx(here("_data", "stips.xlsx")) %>% 
  select(Werk, Gesamt, Jahr) %>% 
  mutate(col = ifelse(Werk == "hbs", "HBS", "Andere"),
         lab = ifelse(Jahr == 2022, Werk, NA),
         dot = ifelse(Jahr == 2022, Gesamt, NA)) %>% 
  ggplot(aes(x = Jahr, y = Gesamt, color = col, group = Werk)) +
  scale_y_log10("Gesamtzahl der Stipendiat:innen", labels = scales::label_comma(1)) +
  scale_x_continuous(NULL, limits = c(2018,2022.3), breaks = 2018:2022 ,labels = function(x) paste0("'",substr(x,nchar(x)-1, nchar(x)))) +
  scale_color_manual(values = c("lightgrey", "#97d700")) +
  geom_line() +
  geom_point(aes(y = dot)) +
  geom_text(aes(label = lab, x = Jahr + 0.1), hjust = 0, size = 2, family = "Helvetica Neue") +
  theme_light(base_family = "Helvetica Neue") +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        legend.position = "none")

ggsave(here("_plots","gesamtstips.png"), width = 16, height = 9, units = "cm", dpi = 600)

# Wachstum Werke 2018 - 2022 -----

read_xlsx(here("_data", "stips.xlsx")) %>% 
  select(Werk, Gesamt, Jahr) %>% 
  tidyr::pivot_wider(values_from = Gesamt, names_from = Jahr) %>% 
  select(Werk, `2018`, `2022`) %>% 
  mutate(growth = (`2022`/`2018`)-1,
         col = ifelse(Werk == "hbs", "HBS", "Andere"),
         lab = paste0(format(round(growth*100,1), decimal.mark = ","),"%")) %>% 
  ggplot(aes(x = forcats::fct_reorder(Werk, desc(growth)), y = growth, fill = col, color = col)) +
  scale_y_continuous("Wachstum 2018 - 2022", labels = scales::label_percent(1)) +
  scale_x_discrete("Begabtenförderwerke") +
  scale_fill_manual(values = c("lightgrey", "#97d700")) +
  scale_color_manual(values = c("#97d700", "black", "#97d700", "lightgrey")) +
  geom_col(aes(color = ifelse(Werk != "hbs","lightgrey", "#97d700"))) +
  geom_text(aes(label = lab, vjust = ifelse(growth > 0, -0.3,1.3)), size = 3, family = "Helvetica Neue") +
  theme_light(base_family = "Helvetica Neue") +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        legend.position = "none")

ggsave(here("_plots","wachstum.png"), width = 16, height = 9, units = "cm", dpi = 600)

# Wachstum HBS Absolut nach Art Förderung -----

read_xlsx(here("_data", "stips.xlsx")) %>% 
  filter(Werk == "hbs") %>% 
  rename("SK-Pauschale" = "SKP",
         "Teilstipendium" = "Teil",
         "Vollstipendium" = "Voll") %>% 
  tidyr::pivot_longer(cols = `SK-Pauschale`:Vollstipendium, names_to = "Art der Förderung", values_to = "Zahl") %>% 
  mutate(dot = ifelse(Jahr == 2022, Zahl, NA),
         lab = ifelse(Jahr == 2022, Zahl, NA)) %>% 
  ggplot(aes(x = Jahr, y = Zahl, color = `Art der Förderung`)) +
  scale_y_continuous("Stipendiat:innen Heinrich-Böll-Stiftung", limits = c(0,1000), labels = scales::label_comma(1)) +
  scale_x_continuous(NULL, limits = c(2018,2022.11), breaks = 2018:2022 ,labels = function(x) paste0("'",substr(x,nchar(x)-1, nchar(x)))) +
  scale_color_manual(values = c("#00b140", "#00ac8c", "#c4d600")) +
  geom_line() +
  geom_point(aes(y = dot)) +
  geom_text(aes(label = lab, x = Jahr + 0.1), hjust = 0, size = 3, family = "Helvetica Neue") +
  theme_light(base_family = "Helvetica Neue") +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        legend.position = "bottom")

ggsave(here("_plots","entwicklung_hbs.png"), width = 16, height = 9, units = "cm", dpi = 600)

# Wachstum HBS Relativ nach Art Förderung -----

read_xlsx(here("_data", "stips.xlsx")) %>% 
  filter(Werk == "hbs") %>% 
  select(-Werk) %>% 
  rename("Gesamtwachstum" = "Gesamt",
         "SK-Pauschale" = "SKP",
         "Teilstipendium" = "Teil",
         "Vollstipendium" = "Voll") %>% 
  tidyr::pivot_longer(-Jahr) %>% 
  tidyr::pivot_wider(values_from = value, names_from = Jahr) %>% 
  mutate(growth = (`2022`/`2018`) - 1,
         lab = paste0(format(round(growth*100,1), decimal.mark = ","),"%"),
         fct = ifelse(name == "Gesamtwachstum", "Gesamtwachstum", "Nach Art der Förderung")) %>% 
  ggplot(aes(x = forcats::fct_reorder(name, growth, .desc = T), y = growth, fill = name)) +
  scale_y_continuous("Wachstum Heinrich-Böll-Stiftung 2018 - 2022", labels = scales::label_percent(1), limits = c(-0.05,0.5)) +
  scale_x_discrete(NULL) +
  scale_fill_manual(values = c("#97d700", "#00b140", "#c4d600", "#00ac8c")) +
  geom_col() +
  geom_text(aes(label = lab, vjust = ifelse(growth > 0, -0.3,1.3)), size = 3, family = "Helvetica Neue") +
  facet_wrap(~fct, scales = "free_x") +
  theme_light(base_family = "Helvetica Neue") +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        legend.position = "none")

ggsave(here("_plots","wachstum_hbs.png"), width = 16, height = 9, units = "cm", dpi = 600)

# Wachstum polit. Werke relativ nach Art Förderung -----

read_xlsx(here("_data", "stips.xlsx")) %>% 
  filter(Werk %in% c("RLS", "hbs", "FES", "FNS", "KAS", "HSS")) %>% 
  rename("Gesamtwachstum" = "Gesamt",
         "SK-Pauschale" = "SKP",
         "Teilstipendium" = "Teil",
         "Vollstipendium" = "Voll") %>% 
  tidyr::pivot_longer(-c(Jahr, Werk)) %>% 
  filter(name != "Gesamtwachstum") %>% 
  tidyr::pivot_wider(values_from = value, names_from = Jahr) %>% 
  mutate(growth = (`2022`/`2018`) - 1,
         lab = paste0(format(round(growth*100,1), decimal.mark = ","),"%"),
         fct = ifelse(name == "Gesamtwachstum", "Gesamtwachstum", "Nach Art der Förderung")) %>% 
  ggplot(aes(x = forcats::fct_reorder(name, growth, .desc = T), y = growth, fill = name)) +
  scale_y_continuous("Wachstum 2018 - 2022", labels = scales::label_percent(1)) +
  scale_x_discrete(NULL) +
  #scale_fill_manual(values = c("#97d700", "#00b140", "#c4d600", "#00ac8c")) +
  geom_col() +
  geom_text(aes(label = lab, vjust = ifelse(growth > 0, -0.3,1.3)), size = 3, family = "Helvetica Neue") +
  facet_wrap(~Werk,
             scales = "free") +
  theme_light(base_family = "Helvetica Neue") +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        legend.position = "none")

w = 30

ggsave(here("_plots","wachstum_polit.png"), width = w, height = w * (9/16), units = "cm", dpi = 600 * (16/w))

# Wachstum polit. Werke absolut nach Art Förderung -----

read_xlsx(here("_data", "stips.xlsx")) %>% 
  filter(Werk %in% c("RLS", "hbs", "FES", "FNS", "KAS", "HSS")) %>% 
  rename("SK-Pauschale" = "SKP",
         "Teilstipendium" = "Teil",
         "Vollstipendium" = "Voll") %>% 
  tidyr::pivot_longer(cols = `SK-Pauschale`:Vollstipendium, names_to = "Art der Förderung", values_to = "Zahl") %>% 
  mutate(dot = ifelse(Jahr == 2022, Zahl, NA),
         lab = ifelse(Jahr == 2022, format(Zahl, big.mark = "."), NA)) %>% 
  ggplot(aes(x = Jahr, y = Zahl, color = `Art der Förderung`)) +
  scale_y_continuous("Sxtipendiat:innen Heinrich-Böll-Stiftung", labels = scales::label_comma(1)) +
  scale_x_continuous(NULL, limits = c(2018,2023), breaks = 2018:2022 ,labels = function(x) paste0("'",substr(x,nchar(x)-1, nchar(x)))) +
  #scale_color_manual(values = c("#00b140", "#00ac8c", "#c4d600")) +
  geom_line() +
  geom_point(aes(y = dot)) +
  geom_text(aes(label = lab, x = Jahr + 0.1), hjust = 0, size = 3, family = "Helvetica Neue") +
  facet_wrap(~Werk) +
  theme_light(base_family = "Helvetica Neue") +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        legend.position = "bottom")

ggsave(here("_plots","entwicklung_polit.png"), width = w , height = w * (9/16), units = "cm", dpi = 600 * (16/w))



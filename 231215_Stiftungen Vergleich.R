###########################################

# PROJECT TITLE: Stiftungen Vergleich

# AUTHOR: Felix Wortmann Callejón

# Date: 2023-12-15

###########################################

pacman::p_load("dplyr", "ggplot2", "here", "readxl", "ggtext")

font <- "Helvetica Neue"

w = 16

theme <- theme_light(base_family = font) +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        plot.caption = element_markdown(),
        plot.title = element_markdown(),
        plot.subtitle = element_markdown()) 

# Entwiklung SKP/BAFöG-Anteil 2018 - 2022 ----

read_xlsx(here("_data", "stips.xlsx")) %>% 
  mutate(bafoeg = Voll + Teil,
         across(c(SKP, bafoeg), \(x) x/Gesamt)) %>% 
  rename("SK-Pauschale" = "SKP",
         "Voll-/Teilstipendium" = "bafoeg") %>% 
  select(-Voll, -Teil) %>% 
  tidyr::pivot_longer(cols = c(`SK-Pauschale`, `Voll-/Teilstipendium`), names_to = "Art der Förderung", values_to = "Anteil") %>% 
  mutate(lab = ifelse(Jahr == 2022, Werk, NA),
         dot = ifelse(Jahr == 2022, Anteil, NA)) %>%
  ggplot(aes(x = Jahr, y = Anteil, color = Werk, group = Werk)) +
  scale_y_continuous("Anteil der Stipendiat:innen", labels = scales::label_percent(1), limits = c(0,1)) +
  scale_x_continuous(NULL, limits = c(2018,2022.6), breaks = 2018:2022 ,labels = function(x) paste0("'",substr(x,nchar(x)-1, nchar(x)))) +
  geom_hline(linetype = "longdash", linewidth = 0.2, yintercept = 0.5, color = "black") +
  geom_line() +
  geom_point(aes(y = dot)) +
  geom_text(aes(label = lab, x = Jahr + 0.1), hjust = 0, size = 2, family = font) +
  facet_wrap(~`Art der Förderung`) +
  theme +
  theme(legend.position = "none") +
  labs(title = "AVICENNA, Luxemborg- und Böckler-Stiftungen fördern die meisten\nBAFöG-berechtigten Studierenden.",
       subtitle = "CUS, KAS, und FNS fördern vor allem reine SK-Pauschale Empfänger:innen.",
       caption = "Datenquelle: BMBF via IFG-Antrag/FragDenStaat.de")

ggsave(here("_plots","entwicklung_anteil_bafoeg.png"), width = w , height = w * (9/16), units = "cm", dpi = 600 * (16/w))  

# Aufschlüsselung Wachstum 2018 - 2022 BAFöG/Nicht ----

read_xlsx(here("_data", "stips.xlsx")) %>% 
  mutate(bafoeg = Voll + Teil) %>% 
  select(-Gesamt, - Teil, -Voll) %>% 
  rename("SK-Pauschale" = "SKP",
         "Voll-/Teilstipendium" = "bafoeg") %>% 
  tidyr::pivot_longer(-c(Jahr, Werk)) %>% 
  tidyr::pivot_wider(values_from = value, names_from = Jahr) %>% 
  mutate(abs_growth = `2022` - `2018`) %>% 
  group_by(Werk) %>% 
  mutate(total_growth = (sum(`2022`)/sum(`2018`)) - 1,
         share_growth = (abs_growth/sum(abs_growth)) * total_growth) %>% 
  ggplot(aes(x = forcats::fct_reorder(Werk, total_growth, .desc = T), y = share_growth, fill = name)) +
  scale_y_continuous("Gesamtwachstum 2018 - 2022", labels = scales::label_percent(1)) +
  scale_x_discrete(NULL) +
  scale_fill_discrete(NULL) +
  geom_col(color = "white") +
  theme +
  theme(legend.position = "none") +
  labs(title = "AVICENNA, Cusanus-Werk, Böll-Stiftung sind am stärksten gewachsen.",
       subtitle = "CUS und hbs vorallm zugunsten von reinen SK-Pauschale Empfänger:innen.",
       caption = "Datenquelle: BMBF via IFG-Antrag/FragDenStaat.de")

ggsave(here("_plots","wachstum_aufgeschluesselt.png"), width = w , height = w * (9/16), units = "cm", dpi = 600 * (16/w))


# Aufschlüsselung Wachstum 2018 - 2022 Voll/Teil/SKP ----

read_xlsx(here("_data", "stips.xlsx")) %>% 
  select(-Gesamt) %>% 
  rename("SK-Pauschale" = "SKP",
         "Teilstipendium" = "Teil",
         "Vollstipendium" = "Voll") %>% 
  tidyr::pivot_longer(-c(Jahr, Werk)) %>% 
  tidyr::pivot_wider(values_from = value, names_from = Jahr) %>% 
  mutate(abs_growth = `2022` - `2018`) %>% 
  group_by(Werk) %>% 
  mutate(total_growth = (sum(`2022`)/sum(`2018`)) - 1,
         share_growth = (abs_growth/sum(abs_growth)) * total_growth) %>% 
  ggplot(aes(x = forcats::fct_reorder(Werk, total_growth, .desc = T), y = share_growth, fill = name)) +
  scale_y_continuous("Gesamtwachstum 2018 - 2022", labels = scales::label_percent(1)) +
  scale_x_discrete(NULL) +
  scale_fill_discrete(NULL) +
  geom_col(color = "white") +
  theme_light(base_family = font) +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        legend.position = "bottom")



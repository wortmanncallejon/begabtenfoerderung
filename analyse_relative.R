###########################################

# PROJECT TITLE: Begabtenförderung - Relative Analysen

# AUTHOR: Georg Wind

# Date: 2025-02-13

# Beschreibung: Berechnet relative Kennzahlen, die die Stipendiaten-Daten
#               in Relation zu Gesamtstudierenden und BAföG-Empfängern setzen.
#               Zentrale Frage: Wie groß ist der tatsächliche Effekt der
#               Begabtenförderung, wenn man absolute Zahlen berücksichtigt?

# Voraussetzung: merge_context_data.R muss zuvor ausgeführt werden.

###########################################


# Setup ----

pacman::p_load("dplyr", "tidyr", "readr", "here", "ggplot2", "scales", "viridis", "purrr")

theme_stip <- theme_light(base_size = 14) +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold", size = 14),
        plot.subtitle = element_text(size = 11, color = "grey40"))


# 1. Daten einlesen ----

agg <- read_csv(here("_data", "merged_aggregiert.csv"), show_col_types = FALSE)
werk <- read_csv(here("_data", "merged_pro_werk.csv"), show_col_types = FALSE)


# 2. Aggregierte Quoten berechnen ----

quoten_agg <- agg |>
  mutate(
    # Kernquoten
    stipendiaten_quote = stip_gesamt / studierende_gesamt,
    bafoeg_quote = bafoeg_studierende / studierende_gesamt,
    nicht_bafoeg = studierende_gesamt - bafoeg_studierende,

    # Stipendiaten: BAföG-Anteil (= Kernaussage des SZ-Artikels)
    stip_bafoeg_anteil = stip_bafoeg_Ja / stip_gesamt,

    # Welcher Anteil der BAföG-Empfänger bekommt zusätzlich ein Stipendium?
    stip_bafoeg_von_bafoeg = stip_bafoeg_Ja / bafoeg_studierende,

    # Welcher Anteil der NICHT-BAföG-Berechtigten bekommt ein Stipendium?
    stip_nichtbafoeg_von_nichtbafoeg = stip_bafoeg_Nein / nicht_bafoeg,

    # Verhältnis: Wie viel wahrscheinlicher ist ein Stipendium ohne BAföG-Berechtigung?
    # > 1 bedeutet: Nicht-BAföG-Berechtigte sind überrepräsentiert
    ueberrepraesentation = stip_nichtbafoeg_von_nichtbafoeg / stip_bafoeg_von_bafoeg
  )


# 3. Quoten pro Förderwerk berechnen ----

quoten_werk <- werk |>
  mutate(
    stip_bafoeg_anteil = stip_bafoeg_Ja / (stip_bafoeg_Ja + stip_bafoeg_Nein),
    stip_von_bafoeg = stip_bafoeg_Ja / bafoeg_studierende,
    stip_von_nichtbafoeg = stip_bafoeg_Nein / (studierende_gesamt - bafoeg_studierende)
  )


# 4. Zeitreihen-Indices (Basis 2013 = 100) ----

basis_jahr <- min(quoten_agg$jahr)

indices <- quoten_agg |>
  select(jahr, stipendiaten_quote, bafoeg_quote, stip_bafoeg_anteil,
         stip_bafoeg_von_bafoeg, stip_nichtbafoeg_von_nichtbafoeg) |>
  pivot_longer(-jahr, names_to = "kennzahl", values_to = "wert") |>
  mutate(
    basis = mean(ifelse(jahr == basis_jahr, wert, NA), na.rm = TRUE),
    .by = kennzahl
  ) |>
  mutate(index = wert / basis * 100)


# 5. Ergebnisse speichern ----

write_csv(quoten_agg, here("_data", "quoten_aggregiert.csv"))
write_csv(quoten_werk, here("_data", "quoten_pro_werk.csv"))
write_csv(indices, here("_data", "zeitreihen_indices.csv"))

message("✓ quoten_aggregiert.csv geschrieben")
message("✓ quoten_pro_werk.csv geschrieben")
message("✓ zeitreihen_indices.csv geschrieben")


# 6. Kern-Ergebnisse ausgeben ----

message("\n", strrep("=", 60))
message("KERN-ERGEBNISSE: Begabtenförderung im Kontext")
message(strrep("=", 60))

latest <- quoten_agg |> filter(jahr == max(jahr))
earliest <- quoten_agg |> filter(jahr == min(jahr))

message("\n--- Studierende & Stipendiaten (", latest$jahr, ") ---")
message("Studierende gesamt:       ", formatC(latest$studierende_gesamt, format = "d", big.mark = ","))
message("BAföG-Empfänger:          ", formatC(latest$bafoeg_studierende, format = "d", big.mark = ","),
        " (", round(latest$bafoeg_quote * 100, 1), "% aller Studierenden)")
message("Stipendiaten gesamt:      ", formatC(latest$stip_gesamt, format = "d", big.mark = ","),
        " (", round(latest$stipendiaten_quote * 100, 2), "% aller Studierenden)")

message("\n--- BAföG-Berechtigung der Stipendiaten ---")
message("Stip. MIT BAföG-Ber.:     ", formatC(latest$stip_bafoeg_Ja, format = "d", big.mark = ","),
        " (", round(latest$stip_bafoeg_anteil * 100, 1), "%)")
message("Stip. OHNE BAföG-Ber.:    ", formatC(latest$stip_bafoeg_Nein, format = "d", big.mark = ","),
        " (", round((1 - latest$stip_bafoeg_anteil) * 100, 1), "%)")

message("\n--- Relative Effekte (pro Kopf) ---")
message("P(Stipendium | BAföG-berechtigt):     ",
        round(latest$stip_bafoeg_von_bafoeg * 100, 3), "%")
message("P(Stipendium | NICHT BAföG-ber.):     ",
        round(latest$stip_nichtbafoeg_von_nichtbafoeg * 100, 3), "%")
message("Verhältnis (Nicht-BAföG / BAföG):     ",
        round(latest$ueberrepraesentation, 2), "x")
message("→ BAföG-Berechtigte haben pro Kopf eine ",
        round(1 / latest$ueberrepraesentation, 1),
        "x höhere Stipendien-Wahrscheinlichkeit")

message("\n--- Entwicklung ", earliest$jahr, " → ", latest$jahr, " ---")
message("BAföG-Anteil Stipendiaten: ",
        round(earliest$stip_bafoeg_anteil * 100, 1), "% → ",
        round(latest$stip_bafoeg_anteil * 100, 1), "%")
message("Stipendiaten-Quote:        ",
        round(earliest$stipendiaten_quote * 100, 2), "% → ",
        round(latest$stipendiaten_quote * 100, 2), "%")
message("BAföG-Quote:               ",
        round(earliest$bafoeg_quote * 100, 1), "% → ",
        round(latest$bafoeg_quote * 100, 1), "%")


# 7. Förderwerk-Ranking nach BAföG-Anteil ----

message("\n--- Ranking: BAföG-Anteil nach Förderwerk (", latest$jahr, ") ---")
quoten_werk |>
  filter(jahr == max(jahr, na.rm = TRUE)) |>
  arrange(desc(stip_bafoeg_anteil)) |>
  mutate(rank = row_number(),
         label = paste0(rank, ". ", Werk, ": ",
                        round(stip_bafoeg_anteil * 100, 1), "% BAföG-berechtigt")) |>
  pull(label) |>
  walk(message)


# 8. Visualisierungen ----

## 8a. Kontextdiagramm: Studierende → BAföG → Stipendiaten
kontext_plot_data <- quoten_agg |>
  select(jahr, studierende_gesamt, bafoeg_studierende, stip_gesamt) |>
  pivot_longer(-jahr, names_to = "kategorie", values_to = "anzahl") |>
  mutate(kategorie = factor(kategorie,
    levels = c("studierende_gesamt", "bafoeg_studierende", "stip_gesamt"),
    labels = c("Studierende gesamt", "BAföG-Empfänger", "Stipendiaten")))

ggplot(kontext_plot_data, aes(x = jahr, y = anzahl, color = kategorie)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_x_continuous(NULL, breaks = seq(min(quoten_agg$jahr), max(quoten_agg$jahr), 1),
                     labels = function(x) paste0("'", substr(as.character(x), 3, 4))) +
  scale_y_log10("Anzahl (log-Skala)",
                labels = label_comma(big.mark = "."),
                breaks = c(30000, 100000, 500000, 1000000, 3000000)) +
  scale_color_viridis(NULL, discrete = TRUE) +
  labs(title = "Studierende, BAföG-Empfänger und Stipendiaten in Deutschland",
       subtitle = "Absolute Zahlen im Vergleich (logarithmische Skala)") +
  theme_stip

ggsave(here("_plots", "kontext_log.png"), width = 20, height = 12, dpi = 300, units = "cm")


## 8b. Quoten-Zeitreihe: Stipendiaten-Quote und BAföG-Anteil
quoten_plot_data <- quoten_agg |>
  select(jahr, stipendiaten_quote, stip_bafoeg_anteil, bafoeg_quote) |>
  pivot_longer(-jahr, names_to = "kennzahl", values_to = "wert") |>
  mutate(kennzahl = factor(kennzahl,
    levels = c("bafoeg_quote", "stip_bafoeg_anteil", "stipendiaten_quote"),
    labels = c("BAföG-Quote (Empfänger/Stud.)",
               "BAföG-Anteil Stipendiaten",
               "Stipendiaten-Quote (Stip./Stud.)")))

ggplot(quoten_plot_data, aes(x = jahr, y = wert, color = kennzahl)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_x_continuous(NULL, breaks = seq(min(quoten_agg$jahr), max(quoten_agg$jahr), 1),
                     labels = function(x) paste0("'", substr(as.character(x), 3, 4))) +
  scale_y_continuous("Quote", labels = label_percent(accuracy = 0.1)) +
  scale_color_viridis(NULL, discrete = TRUE) +
  facet_wrap(~ kennzahl, scales = "free_y", ncol = 1) +
  labs(title = "Zentrale Quoten im Zeitverlauf",
       subtitle = "Begabtenförderung im Verhältnis zu Studierenden und BAföG-Empfängern") +
  theme_stip +
  theme(legend.position = "none",
        strip.text = element_text(face = "bold"))

ggsave(here("_plots", "quoten_zeitreihe.png"), width = 20, height = 24, dpi = 300, units = "cm")


## 8c. Förderwerk-Vergleich: BAföG-Anteil (Balkendiagramm)
werk_ranking <- quoten_werk |>
  filter(jahr == max(jahr, na.rm = TRUE)) |>
  mutate(Werk = reorder(Werk, stip_bafoeg_anteil))

ggplot(werk_ranking, aes(x = Werk, y = stip_bafoeg_anteil, fill = stip_bafoeg_anteil)) +
  geom_col() +
  geom_text(aes(label = paste0(round(stip_bafoeg_anteil * 100, 0), "%")),
            hjust = -0.2, size = 3.5) +
  coord_flip() +
  scale_y_continuous("Anteil BAföG-Berechtigte", labels = label_percent(),
                     expand = expansion(mult = c(0, 0.15))) +
  scale_fill_viridis(option = "C", guide = "none") +
  labs(x = NULL,
       title = paste0("BAföG-Berechtigung nach Förderwerk (", max(quoten_werk$jahr, na.rm = TRUE), ")"),
       subtitle = "Anteil der Stipendiaten mit BAföG-Berechtigung") +
  theme_stip

ggsave(here("_plots", "werk_ranking_bafoeg.png"), width = 20, height = 14, dpi = 300, units = "cm")


## 8d. Überrepräsentation Nicht-BAföG-Berechtigter über Zeit
ggplot(quoten_agg, aes(x = jahr, y = ueberrepraesentation)) +
  geom_line(linewidth = 1, color = "#440154") +
  geom_point(size = 2.5, color = "#440154") +
  geom_hline(yintercept = 1, linetype = "dashed", color = "grey50") +
  annotate("text", x = min(quoten_agg$jahr) + 0.5, y = 1.05,
           label = "Keine Überrepräsentation", size = 3, color = "grey50") +
  scale_x_continuous(NULL, breaks = seq(min(quoten_agg$jahr), max(quoten_agg$jahr), 1),
                     labels = function(x) paste0("'", substr(as.character(x), 3, 4))) +
  scale_y_continuous("Faktor Überrepräsentation",
                     labels = function(x) paste0(x, "x")) +
  labs(title = "Überrepräsentation Nicht-BAföG-Berechtigter in der Begabtenförderung",
       subtitle = "Faktor = P(Stipendium | kein BAföG) / P(Stipendium | BAföG)") +
  theme_stip

ggsave(here("_plots", "ueberrepraesentation.png"), width = 20, height = 12, dpi = 300, units = "cm")


## 8e. Faceted: BAföG-Anteil pro Werk über Zeit
quoten_werk |>
  filter(!is.na(stip_bafoeg_anteil)) |>
  ggplot(aes(x = jahr, y = stip_bafoeg_anteil, color = Werk)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  scale_x_continuous(NULL, breaks = c(2013, 2016, 2019, 2022),
                     labels = function(x) paste0("'", substr(as.character(x), 3, 4))) +
  scale_y_continuous("BAföG-Anteil", labels = label_percent()) +
  scale_color_viridis(NULL, discrete = TRUE) +
  facet_wrap(~ Werk, ncol = 4) +
  labs(title = "BAföG-Berechtigung der Stipendiaten nach Förderwerk",
       subtitle = "Anteil BAföG-Berechtigter über Zeit") +
  theme_stip +
  theme(legend.position = "none",
        strip.text = element_text(size = 9))

ggsave(here("_plots", "bafoeg_anteil_pro_werk.png"), width = 28, height = 20, dpi = 300, units = "cm")


message("\n✓ Alle Visualisierungen in _plots/ gespeichert")

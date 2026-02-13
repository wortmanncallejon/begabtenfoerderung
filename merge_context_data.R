###########################################

# PROJECT TITLE: Begabtenförderung - Daten zusammenführen

# AUTHOR: Georg Wind

# Date: 2025-02-13

# Beschreibung: Führt die Stipendiaten-Daten (clean_data.xlsx) mit den
#               Destatis-Kontextdaten (Studierende gesamt, BAföG-Empfänger)
#               zusammen und berechnet aggregierte sowie werk-spezifische Kennzahlen.

# Voraussetzung: clean_data.R und fetch_context_data.R müssen zuvor ausgeführt werden.

###########################################


# Setup ----

pacman::p_load("dplyr", "tidyr", "readxl", "readr", "here", "writexl")


# 1. Daten einlesen ----

## Stipendiaten-Daten (aus Felix' clean_data.R)
stip_raw <- read_xlsx(here("_data", "clean_data.xlsx"))

## Kontextdaten (aus fetch_context_data.R)
kontext <- read_csv(here("_data", "kontext_daten.csv"), show_col_types = FALSE)


# 2. Stipendiaten aggregieren ----

## 2a. Gesamt-Stipendiaten pro Jahr (über alle Werke)
stip_gesamt <- stip_raw |>
  filter(Variable == "Förderungsart") |>
  summarise(
    stip_gesamt = sum(N, na.rm = TRUE) / n_distinct(Ausprägung),
    # N ist pro Zeile gleich (Gesamtzahl des Werks), daher durch Anzahl Ausprägungen teilen
    .by = Jahr
  ) |>
  # Sicherheits-Check: Alternative Berechnung über distinct
  left_join(
    stip_raw |>
      distinct(Werk, Jahr, N) |>
      summarise(stip_gesamt_check = sum(N, na.rm = TRUE), .by = Jahr),
    by = "Jahr"
  ) |>
  mutate(check_ok = stip_gesamt == stip_gesamt_check) |>
  select(jahr = Jahr, stip_gesamt, check_ok)

# Validierung
if (!all(stip_gesamt$check_ok, na.rm = TRUE)) {
  warning("Inkonsistenz bei der Stipendiaten-Aggregation! Prüfe clean_data.xlsx.")
}


## 2b. BAföG-Berechtigung der Stipendiaten
# SKP = Studienkostenpauschale = NICHT BAföG-berechtigt
# Teil + Voll = BAföG-berechtigt
stip_bafoeg <- stip_raw |>
  filter(Variable == "Förderungsart") |>
  mutate(bafoeg_berechtigt = ifelse(Ausprägung == "SKP", "Nein", "Ja")) |>
  summarise(
    n = sum(n, na.rm = TRUE),
    .by = c(Jahr, bafoeg_berechtigt)
  ) |>
  pivot_wider(names_from = bafoeg_berechtigt, values_from = n,
              names_prefix = "stip_bafoeg_") |>
  rename(jahr = Jahr)


## 2c. BAföG-Berechtigung pro Förderwerk
stip_bafoeg_werk <- stip_raw |>
  filter(Variable == "Förderungsart") |>
  mutate(bafoeg_berechtigt = ifelse(Ausprägung == "SKP", "Nein", "Ja")) |>
  summarise(
    n = sum(n, na.rm = TRUE),
    N = first(N),
    .by = c(Werk, Jahr, bafoeg_berechtigt)
  ) |>
  pivot_wider(names_from = bafoeg_berechtigt, values_from = n,
              names_prefix = "stip_bafoeg_") |>
  mutate(
    stip_bafoeg_anteil = stip_bafoeg_Ja / (stip_bafoeg_Ja + stip_bafoeg_Nein)
  ) |>
  rename(jahr = Jahr, stip_gesamt_werk = N)


# 3. Zusammenführen ----

## 3a. Aggregierter Datensatz (pro Jahr, alle Werke zusammen)
merged_agg <- kontext |>
  select(jahr, studierende_gesamt, bafoeg_studierende) |>
  left_join(stip_gesamt |> select(jahr, stip_gesamt), by = "jahr") |>
  left_join(stip_bafoeg, by = "jahr") |>
  filter(!is.na(stip_gesamt))  # nur Jahre mit Stipendiaten-Daten behalten

## 3b. Datensatz pro Förderwerk (mit Kontextdaten pro Jahr)
merged_werk <- kontext |>
  select(jahr, studierende_gesamt, bafoeg_studierende) |>
  left_join(stip_bafoeg_werk, by = "jahr") |>
  filter(!is.na(Werk))


# 4. Speichern ----

write_csv(merged_agg, here("_data", "merged_aggregiert.csv"))
message("✓ merged_aggregiert.csv geschrieben (", nrow(merged_agg), " Zeilen)")

write_csv(merged_werk, here("_data", "merged_pro_werk.csv"))
message("✓ merged_pro_werk.csv geschrieben (", nrow(merged_werk), " Zeilen)")


# 5. Übersicht ausgeben ----

message("\n--- Übersicht merged_aggregiert ---")
message("Jahre: ", min(merged_agg$jahr), " bis ", max(merged_agg$jahr))
message("Variablen: ", paste(names(merged_agg), collapse = ", "))
print(merged_agg)

message("\n--- Übersicht merged_pro_werk (Beispiel 2023) ---")
merged_werk |>
  filter(jahr == max(jahr, na.rm = TRUE)) |>
  arrange(desc(stip_bafoeg_anteil)) |>
  print()

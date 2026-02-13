# Begabtenförderung im Kontext: Stipendien, BAföG und Studierende

Erweiterung des [Begabtenfoerderung-Projekts](https://github.com/wortmanncallejon/Begabtenfoerderung) von Felix Wortmann Callejón.

## Fragestellung

Die Begabtenförderungswerke vergeben Stipendien zunehmend an Studierende, die keinen BAföG-Anspruch haben - also finanziell bereits gut aufgestellt sind ([SZ-Artikel](https://www.sueddeutsche.de/), [LinkedIn-Post](https://www.linkedin.com/feed/update/urn:li:activity:7427740686562516992/)).

Dieses Projekt setzt die Stipendiaten-Zahlen in Relation zu:
- **Gesamtzahl aller Studierenden** in Deutschland (~2,9 Mio.)
- **Anzahl der BAföG-Empfänger** (~484.000 Studierende)
- um den tatsächlichen Effekt der Begabtenförderung zu quantifizieren

## Datenquellen

| Datensatz | Quelle | Zeitraum |
|-----------|--------|----------|
| Stipendiaten nach Förderwerk (BAföG-Berechtigung, Geschlecht, Migration) | [FragDenStaat IFG-Anfrage](https://fragdenstaat.de/anfrage/anzahl-der-stipendiaten-und-bereitgestelltes-budget-aller-durch-das-bmbf-geforderten-begabtenforderungswerke/) / BMBF | 2013-2023 |
| Studierende insgesamt | [Destatis, Tabelle lrbil01](https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Bildung-Forschung-Kultur/Hochschulen/Tabellen/lrbil01.html) | 2013-2024 |
| BAföG-Empfänger (Studierende) | [BMFTR-Datenportal, Tabelle 2.6.11](https://www.datenportal.bmftr.bund.de/portal/de/Tabelle-2.6.11.html) | 2013-2024 |

## Projektstruktur

```
├── _data/                          # Roh- und Ergebnisdaten
│   ├── *studienfrderung*.xlsx      # BMBF-Rohdaten (via IFG)
│   ├── *promotionsfrderung*.xlsx   # BMBF-Rohdaten (Promotion)
│   ├── bedarfsanmeldungen/         # Budget-Daten
│   ├── clean_data.xlsx             # Bereinigte Stipendiaten-Daten
│   ├── destatis_studierende.csv    # Studierendenzahlen (Destatis)
│   ├── destatis_bafoeg.csv         # BAföG-Empfänger (BMFTR/Destatis)
│   ├── kontext_daten.csv           # Zusammengeführte Kontextdaten
│   ├── merged_aggregiert.csv       # Alle Daten, aggregiert pro Jahr
│   ├── merged_pro_werk.csv         # Alle Daten, pro Förderwerk
│   ├── quoten_aggregiert.csv       # Berechnete Quoten (aggregiert)
│   ├── quoten_pro_werk.csv         # Berechnete Quoten (pro Werk)
│   └── zeitreihen_indices.csv      # Index-Zeitreihen (Basis 2013)
├── _plots/                         # Generierte Visualisierungen
├── clean_data.R                    # [Original] Rohdaten bereinigen
├── visualise_data.R                # [Original] Basis-Visualisierungen
├── bedarfsanmeldungen.R            # [Original] Budget-Analyse
├── fetch_context_data.R            # [Neu] Destatis-Daten laden
├── merge_context_data.R            # [Neu] Alle Daten zusammenführen
└── analyse_relative.R              # [Neu] Relative Analysen & Plots
```

## Reproduzierbarkeit

R-Skripte in dieser Reihenfolge ausführen:

```r
source("clean_data.R")           # 1. Stipendiaten-Rohdaten bereinigen
source("fetch_context_data.R")   # 2. Destatis-Kontextdaten laden
source("merge_context_data.R")   # 3. Daten zusammenführen
source("analyse_relative.R")     # 4. Relative Analysen & Visualisierungen
```

### Abhängigkeiten

```r
install.packages("pacman")
pacman::p_load("dplyr", "tidyr", "ggplot2", "readxl", "readr",
               "writexl", "here", "purrr", "stringr", "scales", "viridis")
```

## Berechnete Kennzahlen

| Kennzahl | Beschreibung |
|----------|-------------|
| `stipendiaten_quote` | Stipendiaten / Studierende gesamt |
| `bafoeg_quote` | BAföG-Empfänger / Studierende gesamt |
| `stip_bafoeg_anteil` | Stip. mit BAföG-Berechtigung / Stip. gesamt |
| `stip_bafoeg_von_bafoeg` | Stip. mit BAföG / BAföG-Empfänger |
| `stip_nichtbafoeg_von_nichtbafoeg` | Stip. ohne BAföG / Nicht-BAföG-Empfänger |
| `ueberrepraesentation` | Faktor der Überrepräsentation Nicht-BAföG-Berechtigter |

## Methodische Hinweise

- **Jahresabgrenzung:** Stipendiaten-Daten beziehen sich auf Kalenderjahre, Studierendenzahlen auf Wintersemester (WS 2013/14 → Jahr 2013).
- **BAföG-Berechtigung vs. BAföG-Empfang:** Die Stipendiaten-Daten zeigen die BAföG-*Berechtigung* (wer hätte Anspruch), die Destatis-Daten die tatsächlichen BAföG-*Empfänger*. Die Zahl der BAföG-Berechtigten ist höher als die der Empfänger (Dunkelziffer der Nicht-Beantragung).
- **SKP-Kodierung:** In den BMBF-Daten steht "SKP" (Studienkostenpauschale) für Stipendiaten, die nur die 300€-Pauschale erhalten und NICHT BAföG-berechtigt sind. "Teil" und "Voll" kennzeichnen BAföG-berechtigte Stipendiaten.

## Danksagung

- Felix Wortmann Callejón - Originalprojekt und IFG-Datenanfrage
- Joscha F. Westerkamp (Süddeutsche Zeitung) - Berichterstattung
- Daten: BMBF/BMFTR, Statistisches Bundesamt (Destatis)

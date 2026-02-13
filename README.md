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

## Zentrale Ergebnisse (Stand 2024)

### 1. BAföG-Anteil in der Begabtenförderung sinkt — aber weniger stark als die BAföG-Quote insgesamt

| Kennzahl | 2013 | 2024 | Veränderung (relativ) |
|----------|------|------|-----------------------|
| BAföG-Quote (Empfänger / Studierende) | 25,4% | 16,9% | **-33,6%** |
| BAföG-Anteil Stipendiaten (BAföG-ber. / alle Stip.) | 50,6% | 37,6% | **-25,8%** |

Der Rückgang des BAföG-Anteils unter Stipendiaten (-25,8%) ist **schwächer** als der allgemeine Rückgang der BAföG-Quote unter allen Studierenden (-33,6%). Die Begabtenförderung hat sich also nicht überproportional von BAföG-Berechtigten abgekoppelt — der Trend spiegelt weitgehend den allgemeinen BAföG-Rückgang wider.

### 2. Stipendiaten machen nur ~1% aller Studierenden aus

| | 2013 | 2024 |
|--|------|------|
| Studierende gesamt | 2.616.881 | 2.864.122 |
| BAföG-Empfänger | 665.928 (25,4%) | 483.814 (16,9%) |
| Stipendiaten (Begabtenf.) | 25.824 (0,99%) | 31.447 (1,10%) |

### 3. BAföG-Berechtigte sind pro Kopf eher überrepräsentiert

| Kennzahl (2024) | Wert |
|-----------------|------|
| P(Stipendium \| BAföG-berechtigt) | 0,024% |
| P(Stipendium \| nicht BAföG-berechtigt) | 0,008% |
| Verhältnis (Überrepräsentationsfaktor) | 0,32x |

Ein Wert unter 1 bedeutet: BAföG-Berechtigte sind **häufiger** unter den Stipendiaten vertreten als Nicht-BAföG-Berechtigte — relativ zu ihrer Gruppengröße.

### 4. Große Unterschiede zwischen Förderwerken

Die Förderwerke unterscheiden sich stark im BAföG-Anteil ihrer Stipendiaten. Werke wie die Hans-Böckler-Stiftung und die Rosa-Luxemburg-Stiftung haben deutlich höhere BAföG-Anteile als z.B. die Studienstiftung des deutschen Volkes oder die Stiftung der Deutschen Wirtschaft.

## Generierte Visualisierungen

| Datei | Inhalt |
|-------|--------|
| `kontext_log.png` | Studierende, BAföG-Empfänger und Stipendiaten absolut (log-Skala) |
| `quoten_zeitreihe.png` | BAföG-Quote, BAföG-Anteil Stipendiaten und Stipendiaten-Quote im Zeitverlauf |
| `werk_ranking_bafoeg.png` | Ranking der Förderwerke nach BAföG-Anteil |
| `ueberrepraesentation.png` | Überrepräsentationsfaktor Nicht-BAföG-Berechtigter über Zeit |
| `bafoeg_anteil_pro_werk.png` | BAföG-Anteil pro Förderwerk im Zeitverlauf |
| `trendvergleich_bafoeg.png` | Indexierter Trendvergleich: BAföG-Rückgang allgemein vs. Begabtenförderung |
| `vergleich_rueckgang_bafoeg.png` | Relativer Rückgang im direkten Balkenvergleich |

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

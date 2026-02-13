###########################################

# PROJECT TITLE: Begabtenförderung - Kontextdaten

# AUTHOR: Georg Wind (Erweiterung des Projekts von Felix Wortmann Callejón)

# Date: 2025-02-13

# Beschreibung: Lädt Kontextdaten (Studierende gesamt, BAföG-Empfänger)
#               von Destatis / BMFTR-Datenportal herunter, um die Stipendiaten-
#               Zahlen in Relation setzen zu können.

###########################################


# Setup ----

pacman::p_load("dplyr", "tidyr", "readr", "here", "stringr")


# 1. Studierende insgesamt (Destatis) ----
# Quelle: Statistisches Bundesamt, Tabelle lrbil01 / GENESIS Tabelle 21311
# https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Bildung-Forschung-Kultur/Hochschulen/Tabellen/lrbil01.html
# Werte: Studierende insgesamt, Wintersemester (WS JJJJ/(JJ+1))
# Zuordnung: WS 2013/14 -> Jahr 2013 (analog zu den Stipendiaten-Daten)

destatis_studierende <- tibble(
  jahr = 2013:2024,
  studierende_gesamt = c(
    2616881,  # WS 2013/14
    2698910,  # WS 2014/15
    2757799,  # WS 2015/16
    2807010,  # WS 2016/17
    2844978,  # WS 2017/18
    2868222,  # WS 2018/19
    2891049,  # WS 2019/20
    2944145,  # WS 2020/21
    2941915,  # WS 2021/22
    2920263,  # WS 2022/23
    2868311,  # WS 2023/24
    2864122   # WS 2024/25 (vorl.)
  ),
  quelle_studierende = "Destatis, Fachserie 11 Reihe 4.1, Tabelle lrbil01"
)

write_csv(destatis_studierende, here("_data", "destatis_studierende.csv"))
message("✓ destatis_studierende.csv geschrieben (", nrow(destatis_studierende), " Zeilen)")


# 2. BAföG-Empfänger Studierende (Destatis / BMFTR) ----
# Quelle: Statistisches Bundesamt, BAföG-Statistik (GENESIS Tabelle 21411)
# sowie Destatis-Pressemitteilungen und BMFTR-Datenportal Tabelle 2.6.11
# https://www.datenportal.bmftr.bund.de/portal/de/Tabelle-2.6.11.html
#
# WICHTIGER HINWEIS:
# Die BAföG-Statistik unterscheidet zwischen:
#   - "Geförderte im Jahr" = alle Personen, die im Laufe des Jahres mindestens
#     einen Monat BAföG erhalten haben (= Jahreszahl, größere Zahl)
#   - "Monatsdurchschnitt" = durchschnittliche Anzahl der Geförderten pro Monat
#     (= kleinere Zahl)
#
# Hier verwenden wir die JAHRESZAHL (Geförderte im Jahr), da diese die
# gängige Kenngröße in Destatis-Pressemitteilungen ist.

# --- Option A: Manuell herunterladen von BMFTR-Datenportal ---
# Die CSV-Datei enthält die vollständige Zeitreihe:
# URL: https://www.datenportal.bmftr.bund.de/portal/docs/Tabelle-2.6.11.csv
#
# Alternativ: GENESIS-Online Tabelle 21411-0001
# URL: https://www-genesis.destatis.de (kostenloser Account erforderlich)

# --- Option B: Programmatisch via restatis (benötigt GENESIS-Account) ---
# Auskommentiert, da Account-Einrichtung nötig:
#
# library(restatis)
# gen_auth_save(username = "DEIN_USERNAME", password = "DEIN_PASSWORT")
# bafoeg_raw <- gen_table("21411-0001")

# --- Verwendete Werte ---
# Alle Werte aus dem BMFTR-Datenportal Tabelle 2.6.11 (CSV-Download)
# URL: https://www.datenportal.bmftr.bund.de/portal/docs/Tabelle-2.6.11.csv
# Originalquelle: Statistisches Bundesamt, BAföG-Statistik

destatis_bafoeg <- tibble(
  jahr = 2013:2024,
  bafoeg_studierende = c(
    # Geförderte Studierende im Laufe des Jahres (Jahreszahl)
    # Quelle: BMFTR-Datenportal Tabelle 2.6.11
    # https://www.datenportal.bmftr.bund.de/portal/docs/Tabelle-2.6.11.csv
    665928,   # 2013
    646576,   # 2014
    611377,   # 2015
    583567,   # 2016
    556573,   # 2017
    517675,   # 2018
    489313,   # 2019
    465543,   # 2020
    467595,   # 2021
    489347,   # 2022
    501425,   # 2023
    483814    # 2024
  ),
  quelle_bafoeg = "BMFTR-Datenportal Tabelle 2.6.11 (Destatis BAföG-Statistik)"
)

write_csv(destatis_bafoeg, here("_data", "destatis_bafoeg.csv"))
message("✓ destatis_bafoeg.csv geschrieben (", nrow(destatis_bafoeg), " Zeilen)")


# 3. Zusammenführung der Kontextdaten ----

kontext <- left_join(destatis_studierende, destatis_bafoeg, by = "jahr") |>
  mutate(
    bafoeg_quote = bafoeg_studierende / studierende_gesamt
  ) |>
  select(jahr, studierende_gesamt, bafoeg_studierende, bafoeg_quote,
         quelle_studierende, quelle_bafoeg)

write_csv(kontext, here("_data", "kontext_daten.csv"))
message("✓ kontext_daten.csv geschrieben")

# Plausibilitäts-Check
message("\n--- Plausibilitäts-Check ---")
message("BAföG-Quote 2013: ", round(kontext$bafoeg_quote[kontext$jahr == 2013] * 100, 1), "%")
message("BAföG-Quote 2024: ", round(kontext$bafoeg_quote[kontext$jahr == 2024] * 100, 1), "%")
message("Studierende 2024: ", format(kontext$studierende_gesamt[kontext$jahr == 2024], big.mark = "."))
message("BAföG-Empfänger 2024: ", format(kontext$bafoeg_studierende[kontext$jahr == 2024], big.mark = "."))

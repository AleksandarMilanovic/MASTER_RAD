# Implementacioni dnevnik

## 2026-07-22 — Faza 0: inicijalizacija projekta

**Cilj:** Kreiranje reproduktivne projektne osnove.

**Izvršene aktivnosti:**
- definisana struktura repozitorijuma;
- kreiran početni IP plan;
- kreirane Docker mrežne zone;
- dodat Compose profil `core`;
- dodata provera lokalnih preduslova;
- kreirani početni ADR dokumenti;
- definisan šablon dokumentacije komponenti.

**Rezultat:**
Repozitorijum je spreman za lokalnu validaciju i dodavanje Wazuh single-node
okruženja u Fazi 1.

**Sledeći korak:**
Pokrenuti proveru preduslova na ciljnom hostu i zabeležiti rezultate.


## Faza 1 — Wazuh single-node deployment

**Izabrana verzija:** 4.14.6

**Aktivnosti:**
- preuzeta zvanična Wazuh Docker konfiguracija;
- generisani TLS sertifikati;
- podignute centralne komponente;
- provereni indexer, manager i dashboard;
- provereni persistent volumeni.

**Rezultat:**
Dopuniti nakon validacije.
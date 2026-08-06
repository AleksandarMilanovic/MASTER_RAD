# Plan testiranja — Faza 0

| ID | Test | Očekivani rezultat |
|---|---|---|
| F0-T01 | `check-prerequisites.sh` | Nema kritičnih grešaka |
| F0-T02 | `docker compose config` | Konfiguracija je validna |
| F0-T03 | Podizanje `core` profila | `network-probe` radi |
| F0-T04 | Health status | Kontejner postaje `healthy` |
| F0-T05 | Pregled mreža | Kreirano je šest imenovanih mreža |
| F0-T06 | Restart kontejnera | Servis se automatski vraća |
| F0-T07 | Zaustavljanje okruženja | Kontejner je uklonjen bez greške |

## Evidencija

Za svaki test sačuvati:

- datum i vreme;
- host platformu;
- Docker i Compose verziju;
- korišćenu komandu;
- rezultat;
- screenshot ili terminal output;
- opis odstupanja.

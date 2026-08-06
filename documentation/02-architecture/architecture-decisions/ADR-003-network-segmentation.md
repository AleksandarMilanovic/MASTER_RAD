# ADR-003: Mrežna segmentacija

- **Status:** Prihvaćeno
- **Datum:** 2026-07-22

## Odluka

Definiše se šest zona: Management, Security, Monitoring, Corporate, Server/DMZ
i Attacker. Security, Monitoring, Corporate, DMZ i Attacker Docker mreže su
inicijalno interne i nemaju neposredan izlaz van Docker hosta.

## Razlog

Ranjive mete i emulacija napada moraju biti odvojene od produkcionih i kućnih
mreža. Komunikacija između zona mora biti eksplicitno dozvoljena.

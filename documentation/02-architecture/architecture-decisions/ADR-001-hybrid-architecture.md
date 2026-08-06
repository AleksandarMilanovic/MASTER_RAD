# ADR-001: Hibridna arhitektura

- **Status:** Prihvaćeno
- **Datum:** 2026-07-22

## Kontekst

Centralni Linux servisi pogodni su za kontejnerizaciju, dok Active Directory,
Windows radne stanice i određeni napadački scenariji zahtevaju pun operativni
sistem i realistične servisne uloge.

## Razmatrane opcije

1. Potpuno kontejnersko okruženje.
2. Potpuno virtuelizovano okruženje.
3. Hibridno okruženje.

## Odluka

Koristi se hibridni model: kontejneri za centralne servise i virtuelne mašine
za Windows/AD i druge sisteme kojima je potreban pun OS.

## Posledice

**Prednosti:** veća realističnost, modularnost i lakše ponovno podizanje servisa.

**Nedostaci:** složenija mrežna integracija i veća potrošnja resursa.

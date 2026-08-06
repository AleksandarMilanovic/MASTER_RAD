# ADR-002: Docker Compose za orkestraciju kontejnera

- **Status:** Prihvaćeno
- **Datum:** 2026-07-22

## Kontekst

Laboratorija mora biti prenosiva i podizati se sa što manje ručnih koraka.

## Odluka

Docker Compose koristi se za deklarativno definisanje servisa, mreža, volumena,
health check provera i profila. Funkcionalne celine biće razdvojene u modularne
Compose fajlove.

## Posledice

Konfiguracija je čitljiva i pogodna za Git. Compose nije zamena za orkestraciju
virtuelnih mašina, pa će se za njih koristiti Vagrant/Packer/Ansible.

# Pregled arhitekture

Platforma koristi hibridni model:

- centralni bezbednosni, case-management, monitoring i pomoćni servisi rade u kontejnerima;
- Windows, Active Directory i sistemi kojima je potreban pun operativni sistem rade kao virtuelne mašine;
- mrežne zone odvajaju administraciju, bezbednosne servise, monitoring, poslovne sisteme, DMZ i napadačku infrastrukturu;
- konfiguracije i dokumentacija čuvaju se u Git repozitorijumu.

## Glavni tok podataka

1. Ciljni sistem generiše telemetriju.
2. Wazuh agent ili drugi kolektor prosleđuje događaje.
3. Wazuh analizira i koreliše događaje.
4. Relevantni alarmi prosleđuju se integracionom servisu.
5. Integracioni servis kreira TheHive alert i observable objekte.
6. Cortex analizira izabrane observable podatke.
7. Prometheus prikuplja operativne metrike.
8. Eksperimentalni modul povezuje vreme napada, alarma i slučaja.

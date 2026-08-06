# Hybrid Cyber Range

Projektna osnova za master rad:

**Projektovanje hibridne virtuelizovane platforme za automatizovanu emulaciju sajber napada, detekciju pretnji i upravljanje bezbednosnim incidentima**

## Cilj

Razvoj modularne i reproduktivne laboratorije koja povezuje:

- kontejnerizovane bezbednosne i monitoring servise;
- virtuelizovane Windows, Active Directory i Linux sisteme;
- Wazuh SIEM/XDR telemetriju i detekciju;
- TheHive/Cortex upravljanje incidentima i obogaćivanje podataka;
- Atomic Red Team i MITRE Caldera emulaciju protivnika;
- Prometheus/Grafana operativni monitoring;
- automatizovanu eksperimentalnu evaluaciju.

## Trenutna faza

**Faza 0 — priprema projekta i infrastrukture**

Trenutni repozitorijum sadrži:

- inicijalnu strukturu direktorijuma;
- mrežni i adresni plan;
- Compose kostur;
- dokumentacione šablone;
- skripte za proveru preduslova i konfiguracije;
- početne Architecture Decision Record dokumente.

## Brzi početak

1. Kopirati `.env.example` u `.env`.
2. Promeniti sve podrazumevane lozinke.
3. Pokrenuti proveru preduslova:

```bash
bash scripts/validate/check-prerequisites.sh
```

4. Validirati Compose konfiguraciju:

```bash
docker compose -f compose/compose.yaml config
```

5. Pokrenuti osnovni infrastrukturni profil:

```bash
docker compose -f compose/compose.yaml --profile core up -d
```

> Compose fajl u Fazi 0 sadrži samo bezbedan pomoćni servis za proveru mreže. Wazuh se dodaje u Fazi 1 korišćenjem zvaničnih Wazuh Docker komponenti i zaključanih verzija.

## Pravila projekta

- Ne koristiti `latest` tag u stabilnim konfiguracijama.
- Ne čuvati lozinke, API ključeve ili sertifikate u Git-u.
- Ranjive mete ne izlagati internetu ili produkcionoj mreži.
- Svaka implementaciona promena mora imati dokumentaciju i test.
- Svaki napadački scenario mora imati cleanup proceduru.

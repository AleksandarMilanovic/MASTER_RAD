# Hybrid Cyber Range

## Master rad – Automatizovano Cyber Range okruženje za simulaciju napada, detekciju, odgovor i monitoring

### Sadržaj:
- [Opis projekta](#opis-projekta)
- [1. Cilj projekta](#1-cilj-projekta)
- [2. Krajnji rezultat](#2-krajnji-rezultat)
- [3. Arhitektura sistema](#3-arhitektura-sistema)
- [4. Komponente projekta](#4-komponente-projekta)
  - [4.1 Wazuh](#41-wazuh)
    - [Wazuh Manager](#wazuh-manager)
    - [Wazuh Indexer](#wazuh-indexer)
    - [Wazuh Dashboard](#wazuh-dashboard)
  - [4.2 Sysmon](#42-sysmon)
  - [4.3 MITRE CALDERA](#43-mitre-caldera)
  - [4.4 TheHive](#44-thehive)
  - [4.5 Wazuh–TheHive integracija](#45-wazuhthehive-integracija)
  - [4.6 Enrichment Wazuh alertova](#46-enrichment-wazuh-alertova)
  - [4.7 Prometheus](#47-prometheus)
  - [4.8 Node Exporter](#48-node-exporter)
  - [4.9 cAdvisor](#49-cadvisor)
  - [4.10 Grafana](#410-grafana)
- [5. Mrežna arhitektura](#5-mrežna-arhitektura)
- [6. Struktura repozitorijuma](#6-struktura-repozitorijuma)
- [7. Automatizacija](#7-automatizacija)
- [8. Sistemski zahtevi](#8-sistemski-zahtevi)
- [9. Preuzimanje projekta](#9-preuzimanje-projekta)
- [10. Provera preduslova](#10-provera-preduslova)
- [11. Inicijalizacija mrežne infrastrukture](#11-inicijalizacija-mrežne-infrastrukture)
- [12. TheHive inicijalna konfiguracija](#12-thehive-inicijalna-konfiguracija)
- [13. TheHive organizacija i servisni nalog](#13-thehive-organizacija-i-servisni-nalog)
- [14. Wazuh–TheHive integration deployment](#14-wazuhthehive-integration-deployment)
- [15. Pokretanje kompletnog okruženja](#15-pokretanje-kompletnog-okruženja)
  - [Faza 1 – Provera preduslova](#faza-1--provera-preduslova)
  - [Faza 2 – Mrežna infrastruktura](#faza-2--mrežna-infrastruktura)
  - [Faza 3 – Wazuh](#faza-3--wazuh)
  - [Faza 4 – TheHive](#faza-4--thehive)
  - [Faza 5 – Integracija](#faza-5--integracija)
  - [Faza 6 – CALDERA](#faza-6--caldera)
  - [Faza 7 – Monitoring](#faza-7--monitoring)
- [16. Pristup platformama](#16-pristup-platformama)
- [17. Provera stanja okruženja](#17-provera-stanja-okruženja)
- [18. Validacija kompletnog sistema](#18-validacija-kompletnog-sistema)
- [19. Pojedinačna validacija](#19-pojedinačna-validacija)
  - [Wazuh](#wazuh)
  - [TheHive](#thehive)
  - [Wazuh–TheHive](#wazuhthehive)
  - [CALDERA](#caldera)
  - [Monitoring](#monitoring)
- [20. Pokretanje pojedinačnih komponenti](#20-pokretanje-pojedinačnih-komponenti)
  - [Wazuh](#wazuh-1)
  - [TheHive](#thehive-1)
  - [CALDERA](#caldera-1)
  - [Monitoring](#monitoring-1)
- [21. Zaustavljanje okruženja](#21-zaustavljanje-okruženja)
- [22. Windows target sistem](#22-windows-target-sistem)
  - [Automatizovana priprema Windows target sistema](#automatizovana-priprema-windows-target-sistema)
- [23. Wazuh Windows agent](#23-wazuh-windows-agent)
- [24. CALDERA Sandcat agent](#24-caldera-sandcat-agent)
- [25. Izvođenje CALDERA scenarija](#25-izvođenje-caldera-scenarija)
- [26. Praćenje napada u Wazuh-u](#26-praćenje-napada-u-wazuh-u)
- [27. Praćenje alertova u TheHive-u](#27-praćenje-alertova-u-thehive-u)
- [28. Monitoring laboratorije](#28-monitoring-laboratorije)
- [29. Troubleshooting](#29-troubleshooting)
  - [Pregled kontejnera](#pregled-kontejnera)
  - [Pregled resursa](#pregled-resursa)
  - [Wazuh log](#wazuh-log)
  - [Wazuh integracija](#wazuh-integracija)
  - [TheHive log](#thehive-log)
  - [CALDERA](#caldera-2)
  - [Prometheus](#prometheus)
  - [Grafana](#grafana)
- [30. Korisne Make komande](#30-korisne-make-komande)
- [31. Bezbednosne napomene](#31-bezbednosne-napomene)
- [32. Reproduktivnost](#32-reproduktivnost)
- [33. Validation filozofija](#33-validation-filozofija)
- [34. Primer kompletnog eksperimenta](#34-primer-kompletnog-eksperimenta)
  - [1. Deployment](#1-deployment)
  - [2. Validation](#2-validation)
  - [3. Endpoint validation](#3-endpoint-validation)
  - [4. Attack simulation](#4-attack-simulation)
  - [5. Detection](#5-detection)
  - [6. Alert forwarding](#6-alert-forwarding)
  - [7. Incident analysis](#7-incident-analysis)
  - [8. Infrastructure monitoring](#8-infrastructure-monitoring)
  - [9. Dokumentovanje rezultata](#9-dokumentovanje-rezultata)
  - [10. Shutdown](#10-shutdown)
- [35. Glavni doprinos projekta](#35-glavni-doprinos-projekta)
- [36. Ograničenja](#36-ograničenja)
- [37. Budući razvoj](#37-budući-razvoj)
- [38. Zaključak](#38-zaključak)

## Opis projekta

Hybrid Cyber Range (HCR) predstavlja modularno, izolovano i automatizovano laboratorijsko okruženje namenjeno simulaciji realnih sajber napada i analizi kompletnog procesa od generisanja napada do njegove detekcije i obrade od strane Blue Team/SOC komponenti.

Projekat je razvijen u okviru master rada sa ciljem izgradnje praktičnog Cyber Range okruženja zasnovanog pretežno na open-source tehnologijama, koje omogućava reprodukovanje scenarija iz oblasti ofanzivne i defanzivne sajber bezbednosti.

Glavna ideja projekta je povezivanje više nezavisnih bezbednosnih platformi u jedinstven sistem koji omogućava sledeći tok:

```text
Attack Simulation
        │
        ▼
MITRE CALDERA
        │
        ▼
Target Systems
(Windows / Linux)
        │
        ▼
Endpoint Telemetry
        │
        ▼
Wazuh SIEM/XDR
        │
        ▼
Detection / Correlation
        │
        ▼
Wazuh → TheHive Integration
        │
        ▼
TheHive
Alert Triage / Case Management

        +

Prometheus + Grafana
Infrastructure Monitoring
```

Na ovaj način laboratorija ne demonstrira samo pojedinačne bezbednosne alate, već kompletan tok karakterističan za savremeno SOC okruženje:

**napad → telemetrija → detekcija → alert → analiza → odgovor → monitoring infrastrukture**

---

# 1. Cilj projekta

[↑ Nazad na sadržaj](#sadržaj)

Osnovni cilj projekta je implementacija prenosivog i automatizovanog Cyber Range okruženja koje omogućava praktično testiranje različitih faza životnog ciklusa sajber incidenta.

Laboratorija treba da omogući:

- simulaciju adversary aktivnosti;
- izvršavanje MITRE ATT&CK tehnika nad kontrolisanim target sistemima;
- prikupljanje Windows i Linux bezbednosne telemetrije;
- centralizovanu analizu događaja;
- detekciju sumnjivih i malicioznih aktivnosti;
- automatsko prosleđivanje relevantnih detekcija u sistem za upravljanje incidentima;
- obogaćivanje alertova kontekstualnim informacijama;
- praćenje resursa i dostupnosti infrastrukture;
- ponovljivo izvođenje bezbednosnih scenarija;
- automatizovano podizanje i gašenje serverskog dela laboratorije.

Poseban cilj implementacije bio je da se smanji količina ručne konfiguracije potrebne nakon inicijalnog deployment-a.

Zbog toga se centralnim komponentama laboratorije upravlja preko jedinstvenog `Makefile` interfejsa.

Na primer:

```bash
make up
```

pokreće kompletno serversko okruženje, dok:

```bash
make down
```

zaustavlja sve njegove komponente.

---

# 2. Krajnji rezultat

Rezultat projekta je funkcionalno Hybrid Cyber Range okruženje koje objedinjuje:

- MITRE CALDERA za adversary emulation;
- Windows target sistem;
- Linux target sistem;
- Sysmon za detaljnu Windows telemetriju;
- Wazuh kao SIEM/XDR platformu;
- TheHive kao platformu za upravljanje alertovima i incidentima;
- custom Wazuh–TheHive integraciju;
- Prometheus za prikupljanje infrastrukturnih metrika;
- Node Exporter za host metrike;
- cAdvisor za Docker metrike;
- Grafana za vizuelizaciju infrastrukture;
- segmentiranu Docker mrežnu arhitekturu;
- automatizovane deployment, validation i shutdown skripte.

Okruženje omogućava izvođenje praktičnog end-to-end scenarija:

```text
CALDERA
   │
   │ adversary operation
   ▼
Windows Target
   │
   │ Windows / Sysmon telemetry
   ▼
Wazuh Agent
   │
   ▼
Wazuh Manager
   │
   │ rules / detection
   ▼
Wazuh Alert
   │
   │ custom-thehive integration
   ▼
TheHive Alert
   │
   ▼
SOC Analyst
```

Paralelno sa tim:

```text
Host + Docker containers
          │
          ├── Node Exporter
          │
          └── cAdvisor
                 │
                 ▼
             Prometheus
                 │
                 ▼
              Grafana
```

---

# 3. Arhitektura sistema

[↑ Nazad na sadržaj](#sadržaj)

Hybrid Cyber Range koristi kombinaciju virtuelnih mašina i Docker kontejnera.

Serverske bezbednosne komponente izvršavaju se na Ubuntu Server sistemu, dok target sistemi mogu biti realizovani kao virtuelne mašine ili kontejneri, u zavisnosti od njihove namene.

Osnovna arhitektura:

```text
                         ┌───────────────────────┐
                         │     SOC / Student     │
                         └───────────┬───────────┘
                                     │
                ┌────────────────────┼─────────────────────┐
                │                    │                     │
                ▼                    ▼                     ▼
        ┌──────────────┐     ┌──────────────┐      ┌──────────────┐
        │    Wazuh     │     │   TheHive    │      │   Grafana    │
        │  Dashboard   │     │     GUI      │      │     GUI      │
        └──────────────┘     └──────────────┘      └──────────────┘


        ┌───────────────────────────────────────────────────────┐
        │                 Security Infrastructure               │
        │                                                       │
        │   Wazuh Manager ───────────────► TheHive              │
        │          │                         ▲                  │
        │          │                         │                  │
        │          │                    Alert Integration       │
        │          │                                            │
        │          └──── endpoint telemetry                     │
        └─────────────────────┬─────────────────────────────────┘
                              │
                 ┌────────────┴────────────┐
                 │                         │
                 ▼                         ▼
        ┌────────────────┐        ┌────────────────┐
        │ Windows Target │        │  Linux Target  │
        │ Wazuh + Sysmon │        │  Wazuh Agent   │
        └────────┬───────┘        └────────────────┘
                 ▲
                 │
                 │ adversary operations
                 │
        ┌────────┴───────┐
        │ MITRE CALDERA  │
        └────────────────┘


        ┌───────────────────────────────────────────────────────┐
        │                    Monitoring                         │
        │                                                       │
        │ Node Exporter ─┐                                      │
        │                ├────► Prometheus ─────► Grafana       │
        │ cAdvisor ──────┘                                      │
        └───────────────────────────────────────────────────────┘
```

---

# 4. Komponente projekta

## 4.1 Wazuh

[↑ Nazad na sadržaj](#sadržaj)

Wazuh predstavlja centralnu SIEM/XDR komponentu laboratorije.

U okviru projekta koristi se za:

- prikupljanje endpoint telemetrije;
- analizu Windows Event Log događaja;
- analizu Sysmon događaja;
- prikupljanje Linux logova;
- File Integrity Monitoring;
- detekciju bezbednosno relevantnih aktivnosti;
- korelaciju događaja;
- primenu detection pravila;
- generisanje alertova;
- prosleđivanje relevantnih alertova u TheHive.

Wazuh deployment se sastoji od:

```text
Wazuh Manager
Wazuh Indexer
Wazuh Dashboard
```

### Wazuh Manager

Centralna komponenta koja prima događaje od agenata, obrađuje ih i primenjuje detection logiku.

### Wazuh Indexer

Čuva i indeksira događaje i alerte.

### Wazuh Dashboard

Web interfejs za pregled:

- agenata;
- događaja;
- alertova;
- security telemetry;
- MITRE ATT&CK informacija;
- File Integrity Monitoring podataka;
- security configuration podataka.

---

# 4.2 Sysmon

Sysmon je instaliran na Windows target sistemu radi generisanja detaljnije endpoint telemetrije.

Omogućava praćenje aktivnosti kao što su:

- kreiranje procesa;
- parent/child process odnosi;
- mrežne konekcije;
- kreiranje fajlova;
- promene Registry vrednosti;
- izvršavanje različitih sistemskih alata.

Sysmon događaji prosleđuju se kroz Wazuh agent ka Wazuh Manager-u.

Ovo je posebno značajno prilikom CALDERA testova jer omogućava da aktivnosti koje generiše adversary emulation platforma budu vidljive Blue Team strani laboratorije.

---

# 4.3 MITRE CALDERA

[↑ Nazad na sadržaj](#sadržaj)

MITRE CALDERA predstavlja adversary emulation komponentu projekta.

Koristi se za kontrolisano simuliranje aktivnosti napadača nad target sistemima.

CALDERA omogućava:

- deployment Sandcat agenata;
- izvršavanje abilities;
- kreiranje adversary profila;
- pokretanje operations;
- automatizovano izvršavanje više tehnika;
- simulaciju discovery aktivnosti;
- testiranje detection capability-a.

U projektu CALDERA prvenstveno služi kao generator aktivnosti koje bi Wazuh trebalo da detektuje.

Tipičan tok je:

```text
CALDERA Operation
       ↓
Sandcat Agent
       ↓
Windows Target
       ↓
Command / Process Execution
       ↓
Windows Event Log / Sysmon
       ↓
Wazuh Agent
       ↓
Wazuh Manager
       ↓
Detection
```

---

# 4.4 TheHive

TheHive predstavlja incident response i case management komponentu laboratorije.

Dok Wazuh generiše detekcije, TheHive omogućava njihovu dalju obradu u SOC workflow-u.

TheHive se koristi za:

- prijem Wazuh alertova;
- pregled alertova;
- triage;
- kategorizaciju;
- upravljanje incidentima;
- kreiranje case-ova;
- upravljanje zadacima;
- dokumentovanje istrage.

U okviru projekta koristi se sledeći tok:

```text
Wazuh Alert
      ↓
custom-thehive
      ↓
TheHive REST API
      ↓
TheHive Alert
```

---

# 4.5 Wazuh–TheHive integracija

[↑ Nazad na sadržaj](#sadržaj)

Jedan od ključnih implementacionih delova projekta je custom integracija između Wazuh i TheHive platformi.

Integracija se nalazi u:

```text
security-platform/integrations/thehive/
```

Glavna Python skripta:

```text
custom-thehive.py
```

Wazuh Manager pokreće integraciju za alerte koji zadovoljavaju definisani minimalni rule level.

Primer konfiguracije:

```xml
<integration>
    <name>custom-thehive</name>
    <level>10</level>
    <alert_format>json</alert_format>
    <hook_url>http://thehive:9000</hook_url>
</integration>
```

Na ovaj način alertovi visokog prioriteta automatski se prosleđuju u TheHive.

Integracija koristi poseban servisni nalog i API ključ.

API ključ se čuva izvan izvornog koda i dostupan je Wazuh kontejneru kao secret.

Primer putanje na host sistemu:

```text
secrets/thehive-wazuh-api-key
```

a unutar Wazuh Manager kontejnera:

```text
/run/secrets/thehive_api_key
```

API ključ ne treba commit-ovati u javni Git repozitorijum.

---

# 4.6 Enrichment Wazuh alertova

Pre slanja u TheHive, originalni Wazuh JSON događaj transformiše se u format pogodniji za SOC analizu.

TheHive alert sadrži informacije kao što su:

```text
Detection Summary
Timestamp
Rule ID
Rule Level
Rule Description

Affected Endpoint
Agent ID
Agent Name
Agent IP

Wazuh Metadata
Location
Rule Groups
```

Takođe se automatski generišu tagovi poput:

```text
wazuh
hcr
wazuh-rule-<RULE_ID>
wazuh-level-<LEVEL>
agent-<AGENT_NAME>
wazuh-group-<GROUP>
```

Primer:

```text
wazuh
hcr
wazuh-rule-100200
wazuh-level-10
agent-WIN-TARGET-01
wazuh-group-integration_test
```

Ovakav enrichment omogućava jednostavnije filtriranje i klasifikovanje alertova u TheHive platformi.

---

# 4.7 Prometheus

[↑ Nazad na sadržaj](#sadržaj)

Prometheus predstavlja centralni sistem za prikupljanje monitoring metrika.

U projektu se koristi za praćenje infrastrukture Cyber Range okruženja.

Prometheus periodično prikuplja metrike od:

- Node Exporter-a;
- cAdvisor-a;
- drugih dostupnih monitoring endpoint-a.

Podaci se čuvaju kao time-series metrike i mogu se analizirati korišćenjem PromQL upita.

---

# 4.8 Node Exporter

Node Exporter omogućava Prometheus-u da prikuplja metrike Ubuntu host sistema.

Primeri metrika:

- CPU usage;
- RAM usage;
- filesystem usage;
- disk I/O;
- network statistics;
- system load;
- uptime.

---

# 4.9 cAdvisor

cAdvisor omogućava monitoring Docker kontejnera.

Prikuplja informacije kao što su:

- CPU usage po kontejneru;
- memory usage;
- network I/O;
- filesystem usage;
- stanje kontejnera.

Na ovaj način moguće je pratiti koliko resursa troše:

```text
Wazuh Manager
Wazuh Indexer
Wazuh Dashboard
TheHive
Cassandra
Elasticsearch
Prometheus
Grafana
```

i ostale komponente.

---

# 4.10 Grafana

Grafana predstavlja vizuelizacioni sloj monitoring sistema.

Koristi Prometheus kao data source i omogućava prikaz infrastrukturnih metrika kroz dashboard-e.

Tipični podaci koji se mogu pratiti:

- CPU usage;
- memory usage;
- disk usage;
- Docker container utilization;
- stanje monitoring target-a;
- istorijske vrednosti performansi.

---

# 5. Mrežna arhitektura

[↑ Nazad na sadržaj](#sadržaj)

Cyber Range koristi segmentiranu Docker mrežnu arhitekturu.

Definisane su sledeće mreže:

| Network | Subnet | Namena |
|---|---|---|
| `hcr-management` | `10.10.10.0/24` | Management saobraćaj |
| `hcr-security` | `10.10.20.0/24` | Security komponente |
| `hcr-monitoring` | `10.10.30.0/24` | Interni monitoring |
| `hcr-corporate` | `10.10.40.0/24` | Simulirana corporate mreža |
| `hcr-dmz` | `10.10.50.0/24` | DMZ/server segment |
| `hcr-attacker` | `10.10.60.0/24` | Attack infrastructure |
| `hcr-case-management` | `10.10.70.0/24` | Wazuh–TheHive komunikacija |
| `hcr-monitoring-access` | `10.10.80.0/24` | Pristup monitoring servisima |

Mreže su definisane kao deo infrastrukture projekta i automatski se inicijalizuju prilikom deployment-a.

Provera:

```bash
docker network ls
```

Detaljna provera određene mreže:

```bash
docker network inspect hcr-security
```

---

# 6. Struktura repozitorijuma

Osnovna struktura projekta:

```text
hybrid-cyber-range/
│
├── compose/
│   ├── compose.attack.yaml
│   ├── compose.monitoring.yaml
│   ├── compose.security.yaml
│   ├── compose.targets.yaml
│   └── compose.yaml
│
├── documentation/
│   ├── 00-project-management/
│   ├── 01-requirements/
│   ├── 02-architecture/
│   ├── 03-deployment/
│   └── 04-wazuh/
│
├── monitoring/
│   ├── grafana/
│   │   ├── dashboards/
│   │   └── provisioning/
│   └── prometheus/
│       └── prometheus.yml
│
├── network/
│   └── addressing/
│       └── ip-plan.md
│
├── results/
│   ├── processed/
│   ├── raw/
│   ├── reports/
│   └── screenshots/
│
├── scripts/
│   ├── deploy/
│   ├── reset/
│   └── validate/
│
├── security-platform/
│   ├── caldera/
│   ├── integrations/
│   │   └── thehive/
│   ├── sysmon/
│   ├── thehive-vendor/
│   └── wazuh/
│
├── targets/
│   ├── windows/
│   └── linux/
│
├── tests/
│
├── .env.example
├── Makefile
├── PROJECT_MANIFEST.json
└── README.md
```

---

# 7. Automatizacija

Jedan od glavnih ciljeva projekta je automatizacija deployment procesa.

Umesto ručnog pokretanja:

```text
Wazuh
TheHive
CALDERA
Prometheus
Grafana
```

za svaku komponentu pojedinačno, projekat koristi centralni `Makefile`.

Glavne komande su:

```bash
make up
make down
make status
make validate
```

---

# 8. Sistemski zahtevi

Preporučeno je korišćenje Linux sistema ili Linux virtuelne mašine.

Razvojno okruženje projekta koristi:

```text
Ubuntu Server 24.04 LTS
Docker Engine
Docker Compose plugin
Git
Python 3
VMware Workstation
```

Za kompletno okruženje preporučuje se najmanje:

```text
CPU:       4 vCPU
RAM:       16 GB
Disk:      80 GB
Network:   VMware NAT / odgovarajuća izolovana laboratorijska mreža
```

TheHive, Cassandra, Elasticsearch, Wazuh Indexer i ostale Java/indeksirajuće komponente zahtevaju značajnu količinu memorije.

Pre pokretanja proveriti:

```bash
nproc
free -h
df -h
docker --version
docker compose version
git --version
python3 --version
```

---

# 9. Preuzimanje projekta

[↑ Nazad na sadržaj](#sadržaj)

Repozitorijum se klonira pomoću Git-a:

```bash
git clone <REPOSITORY_URL>
```

Zatim:

```bash
cd hybrid-cyber-range
```

Preporučena lokacija korišćena tokom razvoja je:

```text
/opt/hybrid-cyber-range
```

Ako se koristi ta lokacija:

```bash
sudo mv hybrid-cyber-range /opt/
sudo chown -R "$USER":"$USER" /opt/hybrid-cyber-range
cd /opt/hybrid-cyber-range
```

---

# 10. Provera preduslova

Pre deployment-a pokrenuti:

```bash
./scripts/validate/check-prerequisites.sh
```

Skripta proverava osnovne zahteve, uključujući:

- Docker;
- Docker daemon;
- Docker Compose;
- Git;
- RAM;
- CPU;
- slobodan disk prostor.

Provera se takođe automatski izvršava prilikom:

```bash
make up
```

---

# 11. Inicijalizacija mrežne infrastrukture

Mreže se automatski kreiraju kroz deployment workflow.

Ručno se mogu inicijalizovati komandom:

```bash
make networks-up
```

ili:

```bash
./scripts/deploy/networks-up.sh
```

Nakon toga:

```bash
docker network ls
```

treba da prikaže HCR mreže.

---

# 12. TheHive inicijalna konfiguracija

[↑ Nazad na sadržaj](#sadržaj)

TheHive zahteva inicijalnu konfiguraciju pre prvog standardnog pokretanja.

TheHive deployment nalazi se u:

```text
security-platform/thehive-vendor/prod1-thehive/
```

Tokom inicijalne konfiguracije kreiraju se potrebni environment parametri, password-i i ostale vrednosti koje TheHive stack koristi.

Nakon inicijalizacije mora postojati:

```text
security-platform/thehive-vendor/prod1-thehive/.env
```

Ovaj korak predstavlja **first-time setup** i ne izvršava se prilikom svakog `make up`.

TheHive koristi:

```text
TheHive
Cassandra
Elasticsearch
Nginx
```

Nginx predstavlja reverse proxy preko kojeg se pristupa web interfejsu.

---

# 13. TheHive organizacija i servisni nalog

Za Wazuh integraciju potrebno je kreirati odgovarajuću TheHive organizaciju.

U implementiranom laboratorijskom okruženju koristi se organizacija:

```text
HCR-SOC
```

Potrebno je kreirati servisni nalog namenjen Wazuh integraciji i za njega generisati API key.

API ključ se zatim čuva u:

```text
secrets/thehive-wazuh-api-key
```

Fajl treba zaštititi odgovarajućim filesystem dozvolama.

**API ključevi, lozinke i drugi secrets ne smeju se postavljati u javni Git repozitorijum.**

---

# 14. Wazuh–TheHive integration deployment

Deployment integracije automatizovan je skriptom:

```text
scripts/deploy/configure-thehive-integration.sh
```

Ručno pokretanje:

```bash
./scripts/deploy/configure-thehive-integration.sh
```

ili odgovarajući Make target:

```bash
make thehive-integration
```

Skripta:

1. proverava postojanje API secret-a;
2. proverava Wazuh Manager;
3. određuje Wazuh GID;
4. podešava filesystem permissions;
5. instalira custom integration skriptu;
6. proverava konfiguraciju;
7. proverava Docker DNS;
8. proverava dostupnost TheHive API-ja;
9. restartuje/reload-uje potrebne Wazuh komponente.

Validacija:

```bash
make validate-thehive-integration
```

---

# 15. Pokretanje kompletnog okruženja

[↑ Nazad na sadržaj](#sadržaj)

Nakon inicijalne konfiguracije, kompletan serverski deo laboratorije pokreće se jednom komandom:

```bash
make up
```

Ovo predstavlja glavni deployment entry point projekta.

Interno se izvršava:

```text
scripts/deploy/all-up.sh
```

Deployment se izvršava fazno.

## Faza 1 – Provera preduslova

```text
Checking prerequisites
```

Proveravaju se Docker, Git, resursi sistema i ostali osnovni zahtevi.

## Faza 2 – Mrežna infrastruktura

```text
Preparing network infrastructure
```

Kreiraju se/proveravaju HCR Docker mreže.

## Faza 3 – Wazuh

```text
Starting Wazuh
```

Pokreću se:

```text
Wazuh Manager
Wazuh Indexer
Wazuh Dashboard
```

Deployment proverava da su ključni Wazuh daemon-i aktivni.

Opciono neaktivni servisi, kao što su oni koji nisu konfigurisani za ovu laboratoriju, ne predstavljaju deployment failure.

## Faza 4 – TheHive

```text
Starting TheHive
```

Pokreću se:

```text
Cassandra
Elasticsearch
TheHive
Nginx
```

Deployment čeka da TheHive postane `healthy`.

## Faza 5 – Integracija

```text
Configuring Wazuh-TheHive integration
```

Proverava se i primenjuje Wazuh–TheHive integracija.

## Faza 6 – CALDERA

```text
Starting CALDERA
```

Pokreće se MITRE CALDERA servis.

## Faza 7 – Monitoring

```text
Starting monitoring stack
```

Pokreću se:

```text
Prometheus
Grafana
Node Exporter
cAdvisor
```

Nakon toga pokreće se finalna validacija kompletnog okruženja.

---

# 16. Pristup platformama

[↑ Nazad na sadržaj](#sadržaj)

U razvojnom deployment-u korišćena je adresa serverske VM:

```text
192.168.100.10
```

Ukoliko deployment koristi drugu adresu, zameniti je odgovarajućom adresom hosta.

Servisi su dostupni na sledećim portovima:

| Platforma | URL |
|---|---|
| Wazuh Dashboard | `https://192.168.100.10/` |
| TheHive | `https://192.168.100.10:9443/` |
| CALDERA | `http://192.168.100.10:8888/` |
| Prometheus | `http://192.168.100.10:9090/` |
| Grafana | `http://192.168.100.10:3000/` |

> Adrese predstavljaju laboratorijsku konfiguraciju i mogu se razlikovati između deployment-a.

---

# 17. Provera stanja okruženja

Za pregled trenutno pokrenutih servisa:

```bash
make status
```

Komanda prikazuje Docker servise i stanje CALDERA servisa.

Dodatno:

```bash
docker ps
```

može se koristiti za direktnu proveru Docker kontejnera.

---

# 18. Validacija kompletnog sistema

Kompletna validacija:

```bash
make validate
```

Ova komanda proverava:

```text
Wazuh
TheHive
Wazuh-TheHive integration
CALDERA
Prometheus/Grafana
```

Cilj je da se deployment ne smatra uspešnim samo zato što kontejner postoji, već zato što su ključne funkcionalnosti servisa dostupne.

---

# 19. Pojedinačna validacija

## Wazuh

```bash
make wazuh-validate
```

Proverava:

- Wazuh kontejnere;
- ključne Wazuh daemon-e;
- komunikacione portove;
- Wazuh Dashboard.

## TheHive

```bash
make thehive-validate
```

Proverava:

- Cassandra;
- Elasticsearch;
- TheHive;
- Nginx;
- TheHive health;
- TheHive API.

## Wazuh–TheHive

```bash
make validate-thehive-integration
```

Proverava:

- integratord;
- custom integration executable;
- API secret;
- permissions;
- Docker DNS;
- TheHive API connectivity.

## CALDERA

```bash
make caldera-validate
```

## Monitoring

```bash
make monitoring-validate
```

Proverava Prometheus/Grafana monitoring stack.

---

# 20. Pokretanje pojedinačnih komponenti

[↑ Nazad na sadržaj](#sadržaj)

Iako je preporučeni način:

```bash
make up
```

komponente se mogu pokretati pojedinačno.

## Wazuh

```bash
make wazuh-up
```

## TheHive

```bash
make thehive-up
```

## CALDERA

```bash
make caldera-up
```

## Monitoring

```bash
make monitoring-up
```

Ovo je korisno tokom razvoja i troubleshooting-a.

---

# 21. Zaustavljanje okruženja

Kompletno okruženje se zaustavlja komandom:

```bash
make down
```

Servisi se gase obrnutim redosledom:

```text
Monitoring
    ↓
CALDERA
    ↓
TheHive
    ↓
Wazuh
```

Normalni shutdown ne briše persistentne podatke.

To znači da ostaju sačuvani:

- Wazuh podaci;
- TheHive podaci;
- Cassandra podaci;
- Elasticsearch podaci;
- Grafana podaci;
- Prometheus podaci;
- Docker volumes;
- HCR mrežna infrastruktura.

Zbog toga je moguće ponovo pokrenuti laboratoriju pomoću:

```bash
make up
```

bez ponovne inicijalne konfiguracije.

---

# 22. Windows target sistem

Windows virtuelna mašina predstavlja glavni endpoint target za adversary emulation testove.

Na njoj se nalaze:

```text
Windows
Wazuh Agent
Sysmon
CALDERA Sandcat Agent
```

Windows VM omogućava testiranje realne Windows telemetrije i predstavlja značajan deo hibridnog karaktera laboratorije jer nije realizovana kao običan Docker kontejner.

Tipičan tok:

```text
CALDERA
   ↓
Sandcat
   ↓
Windows
   ↓
Sysmon / Event Log
   ↓
Wazuh Agent
   ↓
Wazuh Manager
```

## Automatizovana priprema Windows target sistema

Serverski deo Hybrid Cyber Range laboratorije automatizovan je putem
Docker Compose, shell skripti i Makefile-a.

Windows target koristi poseban PowerShell bootstrap proces.

Nakon instalacije čistog Windows sistema korisnik ne mora ručno da
konfiguriše sve bezbednosne komponente.

Windows deployment skripte nalaze se u:

```text
targets/windows/windows-target-01/
```

Glavni entry point:

```powershell
.\bootstrap.ps1
```

Bootstrap automatski izvršava:

1. proveru komunikacije sa HCR serverom;
2. konfiguraciju hostname-a;
3. Windows Audit Policy konfiguraciju;
4. uključivanje command-line auditing-a;
5. instalaciju i konfiguraciju Sysmon-a;
6. instalaciju i konfiguraciju Wazuh Agent-a;
7. pokretanje potrebnih Windows servisa;
8. proveru CALDERA server dostupnosti;
9. finalnu validaciju endpoint-a.

Nakon bootstrap procesa target treba da ima sledeće stanje:

```text
WIN-TARGET-01
│
├── Windows Audit Policy        configured
├── Sysmon                      running
├── Wazuh Agent                 running
├── Wazuh Manager connectivity  available
└── CALDERA connectivity        available
```

Ukoliko je bootstrap promenio hostname, Windows sistem treba restartovati.

Nakon restarta validacija se može ponovo pokrenuti:

```powershell
.\scripts\Validate-HCRWindows.ps1 `
    -HCRServer 192.168.100.10
```

CALDERA adversary agent nije deo permanentnog Windows baseline-a.

On se pokreće samo tokom adversary emulation scenarija, čime Windows
VM pre početka eksperimenta predstavlja čist monitored endpoint.

---

# 23. Wazuh Windows agent

[↑ Nazad na sadržaj](#sadržaj)

Windows target mora imati instaliran Wazuh Agent.

Agent mora biti konfigurisan tako da komunicira sa Wazuh Manager-om.

Relevantni portovi:

```text
1514/TCP – agent communication
1515/TCP – agent enrollment
55000/TCP – Wazuh API
```

Provera konekcije sa Windows sistema može se izvršiti PowerShell komandama:

```powershell
Test-NetConnection <WAZUH_SERVER_IP> -Port 1514
Test-NetConnection <WAZUH_SERVER_IP> -Port 1515
```

Nakon uspešnog enrollment-a agent treba da se pojavi kao `Active` u Wazuh Dashboard-u.

---

# 24. CALDERA Sandcat agent

Da bi CALDERA izvršavala abilities nad Windows target sistemom, Sandcat agent mora biti pokrenut na toj mašini.

Nakon povezivanja agent se pojavljuje u CALDERA interfejsu.

Pre pokretanja operation-a proveriti:

- da je agent aktivan;
- da je agent `trusted`;
- da target odgovara željenom sistemu;
- da je odgovarajuća adversary konfiguracija izabrana.

Status `untrusted` može sprečiti normalno izvršavanje operation-a.

---

# 25. Izvođenje CALDERA scenarija

Tipičan scenario izgleda ovako:

1. Pokrenuti kompletno okruženje:

```bash
make up
```

2. Proveriti:

```bash
make validate
```

3. Proveriti da je Windows Wazuh agent `Active`.

4. Proveriti da je CALDERA Sandcat agent:

```text
Active
Trusted
```

5. Otvoriti CALDERA GUI.

6. Izabrati odgovarajući adversary profil.

7. Kreirati operation.

8. Izabrati odgovarajuću grupu agenata.

9. Pokrenuti operation.

10. Posmatrati izvršavanje abilities.

---

# 26. Praćenje napada u Wazuh-u

[↑ Nazad na sadržaj](#sadržaj)

Nakon pokretanja CALDERA operation-a otvoriti Wazuh Dashboard.

Pratiti događaje sa Windows target sistema.

Posebno su značajni:

- process creation događaji;
- PowerShell aktivnosti;
- command shell aktivnosti;
- discovery komande;
- mrežne konekcije;
- Sysmon događaji;
- Wazuh rule match događaji.

Cilj testa je da se potvrdi:

```text
CALDERA activity
        ↓
Windows telemetry
        ↓
Wazuh ingestion
        ↓
Wazuh detection
```

---

# 27. Praćenje alertova u TheHive-u

Za Wazuh alerte koji zadovoljavaju definisani minimalni level, integracija automatski poziva TheHive API.

Tok:

```text
Wazuh rule
    ↓
Alert level >= configured threshold
    ↓
wazuh-integratord
    ↓
custom-thehive
    ↓
TheHive API
    ↓
Alert
```

U TheHive-u zatim proveriti:

- title;
- severity;
- rule ID;
- rule level;
- endpoint;
- agent;
- Wazuh groups;
- tags;
- description.

Alert zatim može biti predmet SOC triage procesa ili pretvoren u case.

---

# 28. Monitoring laboratorije

Prometheus GUI:

```text
http://<HCR_SERVER_IP>:9090
```

Primer PromQL upita:

```promql
up
```

Očekuje se da monitoring target-i imaju vrednost:

```text
1
```

što označava da su dostupni.

Grafana:

```text
http://<HCR_SERVER_IP>:3000
```

Grafana koristi Prometheus kao data source.

Monitoring omogućava praćenje resursa tokom adversary emulation testova, što je korisno i za procenu zahteva Cyber Range infrastrukture.

---

# 29. Troubleshooting

[↑ Nazad na sadržaj](#sadržaj)

## Pregled kontejnera

```bash
docker ps
```

Svi očekivani kontejneri treba da budu `Up`.

---

## Pregled resursa

```bash
docker stats
```

Posebno pratiti:

```text
wazuh-wazuh.manager-1
wazuh-wazuh.indexer-1
thehive
cassandra
elasticsearch
hcr-prometheus
hcr-grafana
hcr-cadvisor
```

---

## Wazuh log

```bash
docker exec wazuh-wazuh.manager-1 \
  tail -f /var/ossec/logs/ossec.log
```

---

## Wazuh integracija

```bash
docker exec wazuh-wazuh.manager-1 \
  sh -c "grep -Ei 'integrat|custom-thehive|thehive' \
  /var/ossec/logs/ossec.log | tail -n 100"
```

---

## TheHive log

```bash
cd security-platform/thehive-vendor/prod1-thehive

docker compose logs --tail=200 thehive
```

Za Wazuh API pozive:

```bash
docker compose logs --since 10m thehive |
grep -E 'POST /api/v1/alert|CreateError|AuthenticationError'
```

---

## CALDERA

Provera:

```bash
make caldera-validate
```

Ako CALDERA ne radi:

```bash
systemctl status hcr-caldera
```

i:

```bash
journalctl -u hcr-caldera -n 100
```

---

## Prometheus

```bash
curl http://127.0.0.1:9090/-/ready
```

Očekivano:

```text
Prometheus Server is Ready.
```

---

## Grafana

```bash
curl http://127.0.0.1:3000/api/health
```

Očekuje se da database status bude:

```text
ok
```

---

# 30. Korisne Make komande

[↑ Nazad na sadržaj](#sadržaj)

Prikaz dostupnih komandi:

```bash
make help
```

Glavne:

```bash
make up
make down
make status
make validate
```

Pojedinačne:

```bash
make networks-up

make wazuh-up
make wazuh-down
make wazuh-validate

make thehive-up
make thehive-down
make thehive-validate

make thehive-integration
make validate-thehive-integration

make caldera-up
make caldera-down
make caldera-validate

make monitoring-up
make monitoring-down
make monitoring-validate
```

---

# 31. Bezbednosne napomene

Ovo okruženje je namenjeno isključivo:

- edukaciji;
- istraživanju;
- laboratorijskim eksperimentima;
- kontrolisanom adversary emulation testiranju;
- Blue Team/SOC vežbama.

CALDERA i ostale adversary emulation funkcionalnosti treba koristiti isključivo nad sistemima za koje postoji eksplicitna dozvola.

Cyber Range treba držati izolovanim od produkcionih sistema.

Posebno voditi računa o:

- API ključevima;
- administratorskim nalozima;
- TheHive secrets;
- Wazuh credentials;
- Grafana credentials;
- CALDERA credentials;
- TLS private key fajlovima.

Secrets ne treba commit-ovati u Git.

Pre svakog:

```bash
git add .
git commit
git push
```

proveriti:

```bash
git status
```

i:

```bash
git diff --cached
```

kako bi se sprečilo slučajno postavljanje credentials-a u repozitorijum.

---

# 32. Reproduktivnost

Jedan od ključnih projektnih zahteva je reproduktivnost.

Serverski deo okruženja je zato organizovan kroz:

```text
Docker Compose
        +
deployment scripts
        +
validation scripts
        +
Makefile
```

Standardni životni ciklus laboratorije je:

```text
Git Repository
      ↓
Prerequisites
      ↓
Initial Setup
      ↓
make up
      ↓
make validate
      ↓
Security Experiment
      ↓
Results
      ↓
make down
```

Nakon što je initial setup završen, svakodnevni workflow svodi se na:

```bash
cd /opt/hybrid-cyber-range

make up
```

a nakon rada:

```bash
make down
```

---

# 33. Validation filozofija

[↑ Nazad na sadržaj](#sadržaj)

Deployment se ne smatra uspešnim samo zato što Docker prikazuje container kao `running`.

Validation sloj proverava stvarnu dostupnost ključnih funkcija.

Na primer, kod Wazuh-a proveravaju se daemon-i potrebni ovom projektu.

Neki Wazuh servisi mogu legitimno biti neaktivni zato što njihove funkcije nisu konfigurisane u ovoj laboratoriji.

Primeri opcionih/neaktivnih servisa:

```text
wazuh-clusterd
wazuh-maild
wazuh-agentlessd
wazuh-dbd
wazuh-csyslogd
```

Njihovo stanje `not running` samo po sebi ne znači da Wazuh nije funkcionalan.

Nasuprot tome, servisi potrebni za ingestion, analizu, agent komunikaciju i integracije moraju biti aktivni.

---

# 34. Primer kompletnog eksperimenta

Kompletan eksperiment može izgledati ovako.

## 1. Deployment

```bash
cd /opt/hybrid-cyber-range
make up
```

## 2. Validation

```bash
make validate
```

## 3. Endpoint validation

Proveriti:

```text
WIN-TARGET-01 → Wazuh Agent Active
CALDERA Sandcat → Active / Trusted
```

## 4. Attack simulation

U CALDERA platformi kreirati i pokrenuti operation.

Na primer, operation može sadržati discovery aktivnosti.

## 5. Detection

U Wazuh Dashboard-u proveriti događaje generisane na Windows target-u.

## 6. Alert forwarding

Za odgovarajući rule level proveriti da je alert automatski prosleđen u TheHive.

## 7. Incident analysis

U TheHive-u pregledati:

```text
Rule
Severity
Endpoint
Timestamp
Groups
Tags
Description
```

## 8. Infrastructure monitoring

U Grafana/Prometheus platformama proveriti stanje infrastrukture i korišćenje resursa tokom eksperimenta.

## 9. Dokumentovanje rezultata

Rezultati eksperimenta mogu se čuvati u:

```text
results/
├── raw/
├── processed/
├── reports/
└── screenshots/
```

## 10. Shutdown

```bash
make down
```

---

# 35. Glavni doprinos projekta

[↑ Nazad na sadržaj](#sadržaj)

Hybrid Cyber Range demonstrira kako se više open-source bezbednosnih tehnologija može povezati u funkcionalan sistem za izvođenje sajber bezbednosnih eksperimenata.

Ključni doprinos nije samo instalacija pojedinačnih alata, već njihova integracija u zajednički workflow:

```text
Adversary Emulation
        ↓
Endpoint Activity
        ↓
Telemetry Collection
        ↓
Detection Engineering
        ↓
SIEM/XDR
        ↓
Alert Enrichment
        ↓
Incident Management
        ↓
Infrastructure Monitoring
```

Na taj način okruženje može služiti kao osnova za:

- praktične SOC vežbe;
- Blue Team obuku;
- detection engineering;
- testiranje Wazuh pravila;
- MITRE ATT&CK eksperimente;
- incident response vežbe;
- analizu endpoint telemetrije;
- evaluaciju bezbednosnih kontrola;
- akademske eksperimente iz oblasti sajber bezbednosti.

---

# 36. Ograničenja

Cyber Range je projektovan kao laboratorijsko, a ne produkciono SOC okruženje.

Finalna implementacija namerno zadržava ograničen broj komponenti kako bi arhitektura ostala razumljiva, reproduktivna i dovoljno efikasna za izvršavanje na jednoj laboratorijskoj infrastrukturi.

Fokus projekta je na integraciji:

```text
CALDERA
Windows/Linux targets
Wazuh
TheHive
Prometheus
Grafana
```

a ne na izgradnji kompletnog enterprise SOC tehnološkog stack-a.

---

# 37. Budući razvoj

Arhitektura je modularna i omogućava naknadno proširenje.

Potencijalni pravci razvoja mogu uključivati:

- dodatne Windows i Linux target sisteme;
- Active Directory laboratoriju;
- dodatne CALDERA adversary profile;
- dodatna Wazuh detection pravila;
- naprednije Grafana dashboard-e;
- automatizovane alerting mehanizme;
- dodatne TheHive workflow-e;
- ranjive web aplikacije;
- dodatne DMZ servise;
- automatizovano kreiranje target virtuelnih mašina.

Ove komponente nisu neophodne za osnovnu funkcionalnost trenutne implementacije.

---

# 38. Zaključak

Hybrid Cyber Range predstavlja kompletno laboratorijsko okruženje koje povezuje ofanzivne i defanzivne bezbednosne tehnologije u jedinstven sistem.

Korisnik može pokrenuti adversary emulation scenario kroz MITRE CALDERA, izvršiti aktivnosti nad Windows target sistemom, prikupiti endpoint telemetriju pomoću Sysmon-a i Wazuh agenta, detektovati aktivnosti u Wazuh SIEM/XDR platformi i automatski proslediti relevantne alerte u TheHive.

Prometheus i Grafana omogućavaju paralelno praćenje stanja i potrošnje resursa same Cyber Range infrastrukture.

Automatizacijom deployment-a kroz Docker Compose, shell skripte i Makefile omogućeno je da se serverski deo laboratorije kontroliše kroz nekoliko standardizovanih komandi.

Osnovni operativni workflow projekta zato se svodi na:

```bash
make up
make validate
```

nakon čega se izvodi željeni bezbednosni eksperiment, a po završetku:

```bash
make down
```

Time je realizovano modularno, izolovano, ponovljivo i automatizovano Cyber Range okruženje pogodno za praktične eksperimente, SOC/Blue Team obuku i akademsko istraživanje u oblasti sajber bezbednosti.

[↑ Nazad na sadržaj](#sadržaj)
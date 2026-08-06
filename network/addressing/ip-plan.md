# IP plan laboratorije

| Zona | Docker/virtuelna mreža | Opseg | Gateway | Namena |
|---|---|---:|---:|---|
| Management | `hcr-management` | `10.10.10.0/24` | `10.10.10.1` | Administracija i kontrolisani pristup UI servisima |
| Security | `hcr-security` | `10.10.20.0/24` | `10.10.20.1` | Wazuh, TheHive, Cortex i integracioni servis |
| Monitoring | `hcr-monitoring` | `10.10.30.0/24` | `10.10.30.1` | Prometheus, Grafana, Alertmanager i exporter-i |
| Corporate | `hcr-corporate` | `10.10.40.0/24` | `10.10.40.1` | Active Directory, Windows i Linux poslovni sistemi |
| Server/DMZ | `hcr-dmz` | `10.10.50.0/24` | `10.10.50.1` | Aplikativni serveri i ranjive mete |
| Attacker | `hcr-attacker` | `10.10.60.0/24` | `10.10.60.1` | Caldera i napadačka stanica |

## Rezervisane adrese

| Adresa | Planirana komponenta |
|---|---|
| `10.10.10.10` | Privremeni network probe |
| `10.10.20.10` | Wazuh manager |
| `10.10.20.11` | Wazuh indexer |
| `10.10.20.12` | Wazuh dashboard |
| `10.10.20.20` | TheHive |
| `10.10.20.21` | Cortex |
| `10.10.20.30` | Wazuh–TheHive integration service |
| `10.10.30.10` | Prometheus |
| `10.10.30.11` | Grafana |
| `10.10.30.12` | Alertmanager |
| `10.10.40.10` | DC01 |
| `10.10.40.20` | WIN11-01 |
| `10.10.40.21` | WIN11-02 |
| `10.10.40.30` | SRV01 |
| `10.10.50.10` | LINUX01 |
| `10.10.50.20-29` | Ranjive aplikacije |
| `10.10.60.10` | Caldera |
| `10.10.60.20` | Kali/Attack VM |

## Napomena

Docker bridge mreže ne rešavaju same po sebi povezivanje sa virtuelnim mašinama.
U fazi projektovanja hibridne mreže biće definisan ruter/firewall ili odgovarajući
host-only/bridged segmenti koji povezuju kontejnere i VM-ove uz kontrolisana pravila.

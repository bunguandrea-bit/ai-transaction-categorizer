# Financial Data Automation Engine

### 🎯 Obiettivo
Progetto per l'automazione del parsing e della riconciliazione di estratti conto bancari (CSV/PDF), con focus sulla **Data Privacy**.

### 🛡️ Core Feature: Privacy-First
Il modulo `security.py` implementa un layer di **anonimizzazione preventiva**. I dati sensibili (IBAN, ID transazioni) vengono mascherati tramite Regex prima di qualsiasi elaborazione.

### 🛠️ Tech Stack
* **Python 3.12+**
* **Pandas:** Manipolazione dati.
* **Unittest:** Validazione della logica di sicurezza.
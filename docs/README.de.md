# Antigravity Quota

<p align="center">
  <img src="../assets/app_icon.png" alt="Antigravity Quota Symbol" width="128" height="128" />
</p>

<p align="center">
  <strong>Ein schlanker Echtzeit-Menüleistenmonitor & WidgetKit-Widgets für Google Antigravity unter macOS.</strong><br>
  <em>Behalten Sie Gemini-, Claude- und GPT-Modellkontingente, verbleibende Reset-Timer und Nutzungsprozentsätze direkt in Statusleiste, Desktop und Mitteilungszentrale im Blick.</em>
</p>

<p align="center">
  <a href="https://github.com/badugisoft/antigravity-quota/releases"><img src="https://img.shields.io/github/v/release/badugisoft/antigravity-quota?style=flat-square&color=blue" alt="Latest Release" /></a>
  <a href="https://github.com/badugisoft/antigravity-quota/releases"><img src="https://img.shields.io/github/downloads/badugisoft/antigravity-quota/total?style=flat-square&color=brightgreen" alt="Total Downloads" /></a>
  <img src="https://img.shields.io/badge/macOS-13.0%2B-black?style=flat-square&logo=apple" alt="macOS 13+" />
  <img src="https://img.shields.io/badge/Swift-5.9%2B-orange?style=flat-square&logo=swift" alt="Swift 5.9+" />
  <img src="https://img.shields.io/badge/WidgetKit-Ready-purple?style=flat-square&logo=apple" alt="WidgetKit" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="MIT License" />
</p>

<p align="center">
  <a href="../README.md">English</a> ·
  <a href="README.ko.md">한국어</a> ·
  <a href="README.zh.md">简体中文</a> ·
  <a href="README.ja.md">日本語</a> ·
  <strong>Deutsch</strong> ·
  <a href="README.fr.md">Français</a> ·
  <a href="README.es.md">Español</a>
</p>

<p align="center">
  <a href="https://github.com/badugisoft/antigravity-quota/releases/latest"><strong>⬇️ Neuestes DMG herunterladen</strong></a> ·
  <a href="https://badugisoft.github.io/antigravity-quota/?lang=de"><strong>🌐 Webseite</strong></a> ·
  <a href="#screenshots">Screenshots</a> ·
  <a href="#funktionen">Funktionen</a> ·
  <a href="#installation--build">Installation</a> ·
  <a href="#faq--fehlerbehebung">FAQ</a> ·
  <a href="#mitwirken">Mitwirken</a>
</p>

---

## Screenshots

<p align="center">
  <img src="../assets/menubar_summary.png" alt="Statusleisten-Übersicht" />
  <br>
  <em>Kreisdiagramm-Symbol & Kontingent-Übersicht in der Menüleiste</em>
</p>

<p align="center">
  <img src="../assets/popover_standard.png" alt="Standardmodus" width="340" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="../assets/popover_compact.png" alt="Kompaktmodus" width="340" />
  <br>
  <em>Menüleisten-Popover: Standardmodus (links) &nbsp;|&nbsp; Kompaktmodus (rechts)</em>
</p>

<p align="center">
  <img src="../assets/widget_small.png" alt="Kleines Widget (1x1)" width="165" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="../assets/widget_medium.png" alt="Mittleres Widget (1x2)" width="345" />
  <br>
  <em>macOS Widgets: Klein 1x1 (links) &nbsp;|&nbsp; Mittel 1x2 (rechts)</em>
</p>

> [!NOTE]
> **🤖 100% Built with Google Antigravity**
>
> Diese gesamte Anwendung – einschließlich lokaler RPC-Erkennung, Architektur, SwiftUI-Views, WidgetKit-Erweiterungen, adaptiver Abfragelogik, Mehrsprachigkeit, Icon-Design und Build-Skripten – wurde **zu 100 % im autonomen Pair-Programming mit Google Antigravity entworfen, implementiert und verifiziert**.

---

## Funktionen

- **Echtzeit-Kontingentüberwachung**:
  - Erkennt und zeigt dynamisch alle von Antigravity gelieferten Kontingentgruppen und -Buckets an (z. B. **Gemini Models**, **Claude and GPT models**, **Gemini 4 Argon** sowie zukünftige Modellgruppen).
  - Überwacht sowohl das **rollierende 5-Stunden-Limit** als auch das **wöchentliche Limit** für alle aktiven Gruppen.
- **Dynamisches Menüleisten-Kreisdiagramm-Symbol**:
  - Zeigt das Antigravity-Logo umgeben von einem dynamischen Kreisring für den verbleibenden Anteil des gewählten Ziel-Kontingents (und wechselt im Offline-Zustand zu einem gestrichelten Ring).
  - Unterstützt die Modi **Symbol & Kontingent** (mit dynamischen Gruppenkürzeln wie `G:75% · C:100% · A:85%`) oder **Nur Symbol** sowie freie Wahl des **Ziels für das Kreisdiagramm** unter **Einstellungen > Allgemein**.
- **macOS Desktop- & Mitteilungszentrale-Widgets (WidgetKit)**:
  - **Kleines Widget (`systemSmall` / 1x1)**: Minimalistische Übersicht mit Fortschrittsbalken aller aktiven Modellgruppen, Restprozenten, Online-Indikator und nächstem Reset-Countdown.
  - **Mittleres Widget (`systemMedium` / 1x2)**: Zweispalten-Ansicht für die primären Modellgruppen plus eine kompakte Zusatzzeile für weitere Gruppen (wie Gemini 4 Argon) inklusive Countdown und Live-Statusanzeige.
  - **Natives Milchglas-Material**: Verwendet `.regularMaterial` mit randloser Integration (`.contentMarginsDisabled()`), passend zu macOS-Systemwidgets und Hintergrundbildern im Dunkel- und Hellmodus.
  - Echtzeitsynchronisation über `QuotaDataStore` und unmittelbare `WidgetCenter.reloadAllTimelines()`-Aufrufe bei jeder Aktualisierung.
  - Vollständige Unterstützung für den macOS-Dunkelmodus und alle 7 Sprachen.
- **Live-Countdown-Timer**:
  - Sekundengenaue Anzeige der verbleibenden Zeit bis zur nächsten Kontingent-Auffüllung (z. B. `Noch 3 Std. 2 Min.`, `Noch 1 T. 19 Std.`).
  - **Unterdrückung bei 100 % ungenutztem Kontingent**: Bei vollständig vollem (100 %) Kontingent wird kein künstlicher rollierender Ablauf-Timer angezeigt, sondern sauber `"Ungenutzt"`.
- **Kontingent-Reset-Mitteilungen**:
  - Plant native macOS-Mitteilungen (`UNUserNotificationCenter`) im Voraus, um Sie sofort zu benachrichtigen, sobald ein verbrauchtes 5-Stunden- oder Wochenkontingent wieder auf 100 % aufgefüllt wurde.
  - Unter **Einstellungen > Mitteilungen** lassen sich Gesamtschalter, getrennte Schalter für **5-Stunden-Kontingent-Reset-Mitteilung** und **Wöchentliche Kontingent-Reset-Mitteilung**, Systemberechtigungsstatus sowie **Testmitteilung senden** verwalten.
- **Adaptives intelligentes Polling**:
  - **15-Sekunden-Aktiv-Polling**: Sobald KI-Aktivität (Token-Generierung, Tool-Aufrufe) Kontingent verbraucht, beschleunigt sich die Abfrage für ein 3-Minuten-Fenster automatisch auf 15 Sekunden – auch wenn Antigravity im Hintergrund läuft.
  - **60-Sekunden-Leerlauf-Polling**: Ohne KI-Verbrauch schaltet das Intervall automatisch auf 60 Sekunden zurück, um Akku und CPU zu schonen.
  - **Sofort-Aktualisierung bei Fokuswechsel**: Beim Wechsel zum Antigravity-Fenster wird unmittelbar eine Synchronisation ausgelöst.
  - **Automatische Pause**: Zeigt beim Beenden oder Offline-Status von Antigravity den Pausenzustand (`⏸`) und setzt beim Neustart nahtlos fort.
- **Remote-SSH-Fallback (Multi-Mac-Synchronisation)**:
  - Wenn auf mehreren Macs gearbeitet wird und Antigravity lokal nicht läuft, kann Antigravity Quota einen entfernten Rechner per SSH abfragen.
  - Vollständig konfigurierbar unter **Einstellungen > Remote**: **Remote-SSH-Kontingentabfrage aktivieren**, **SSH-Host** (`user@hostname` oder `~/.ssh/config`-Alias), **Remote-Abfrageintervall** (30 Sek., 1 Min., 2 Min., 5 Min.) und integrierte Funktion **Verbindung testen**.
  - Führt einmalige direkte RPC-Abfragen über `/usr/bin/ssh` ohne dauerhafte Tunnel-Daemons, externe Abhängigkeiten oder Dateisynchronisation aus.
- **Standard- / Kompaktmodus & Einstellungen**:
  - **Standard**: Ausführliche Karten mit Farbverlauf-Balken, verbleibenden/verbrauchten Prozenten und geplanten Reset-Zeiten.
  - **Kompakt**: Besonders schmale Ansicht ohne Scrollen für minimalen Platzbedarf.
  - **Natives Einstellungsfenster**: Öffnen Sie **Allgemein** (inkl. **Bei der Anmeldung starten** über `SMAppService`), **Remote** und **Mitteilungen** direkt über das Zahnradsymbol im Popover-Header.
- **Mehrsprachigkeit (7 Sprachen)**:
  - Unterstützt **English**, **한국어**, **简体中文**, **日本語**, **Deutsch**, **Français** und **Español**.
  - Übernimmt beim ersten Start automatisch Ihre macOS-Systemsprache.
  - Ein-Klick-Dropdown im Popover-Header oder Sprachauswahl in den Einstellungen.
  - Sämtliche Texte, Countdowns, Reset-Uhrzeiten, Mitteilungen und Zeitstempel werden gemäß der aktiven Sprache formatiert.
- **100 % lokal & datenschutzfreundlich**:
  - Fragt ausschließlich den lokalen `127.0.0.1`-Antigravity-Language-Server (oder Ihren explizit eingerichteten SSH-Host) ab – ganz ohne Telemetrie, Drittserver oder gespeicherte API-Keys. Details siehe [SECURITY.md](../SECURITY.md).
- **Natives macOS-Erlebnis**:
  - Zu 100 % in Swift, SwiftUI, AppKit und WidgetKit entwickelt.
  - Reiner Menüleisten-Daemon (`LSUIElement = true`) ohne Dock-Symbol.
  - macOS-Squircle-App-Symbol nach den Apple Human Interface Guidelines.
  - Keine externen Drittanbieter-Abhängigkeiten – reiner Swift Package Manager.

---

## Funktionsweise

Antigravity betreibt einen internen Language-Server-Daemon (`language_server`), der auf einem lokalen TCP-Port lauscht.

1. **Prozess- & CSRF-Token-Ermittlung**:
   Durchsucht `/bin/ps` nach dem aktiven `language_server`-Prozess und liest das Sitzungs-CSRF-Token aus CLI-Argumenten (`--csrf_token`) oder Umgebungsvariablen (`ANTIGRAVITY_SERVER_CSRF_TOKEN` ab Antigravity 2.34.0 via `ps eww -p <pid>`).
2. **Sofortige Port-Auflösung**:
   Nutzt `/usr/sbin/lsof` (mit Fallback auf `/usr/sbin/netstat`), um offene TCP-Listening-Sockets der PID in weniger als einer Millisekunde ohne Port-Scanning zu finden.
3. **Connect-RPC-Protokoll**:
   Sendet HTTP/HTTPS-POST-Anfragen mit dem Authentifizierungs-Header `x-codeium-csrf-token` an `127.0.0.1:<port>/exa.language_server_pb.LanguageServerService/RetrieveUserQuotaSummary`.
4. **Gemeinsamer Datenspeicher & Widget-Sync**:
   Speichert den aktuellen Snapshot via `QuotaDataStore` in `~/Library/Application Support/AntigravityQuota/shared_quota.json` und ruft `WidgetCenter.shared.reloadAllTimelines()` auf, sodass Sandbox-Widgets ohne TCC-Berechtigungsabfragen sofort aktualisiert werden.
5. **Reaktive Darstellung**:
   Parst `remainingFraction` und `resetTime` in typsichere Swift-Modelle und rendert sie nahtlos über SwiftUI, `NSStatusItem` und WidgetKit.

---

## Widgets zu macOS hinzufügen

1. Installieren Sie **Antigravity Quota.app** in `/Applications` (über DMG oder `make build`).
2. Klicken Sie mit der rechten Maustaste auf den macOS-Schreibtisch und wählen Sie **Widgets bearbeiten...** (oder öffnen Sie die **Mitteilungszentrale** und klicken unten auf **Widgets bearbeiten**).
3. Suchen Sie in der Widget-Galerie nach **Antigravity Quota**.
4. Wählen Sie das **kleine (1x1)** oder **mittlere (1x2)** Widget und ziehen Sie es auf den Schreibtisch oder in die Mitteilungszentrale.

---

## Systemanforderungen

- **macOS**: 13.0 (Ventura) oder neuer.
- **Hardware**: Apple Silicon (M1/M2/M3/M4) oder Intel Mac.
- **Antigravity**: Installiertes Google Antigravity (lokal oder auf einem erreichbaren SSH-Host).
- **Entwicklungswerkzeuge**: Xcode 15.0+ oder Swift 5.9+ Toolchain (nur zum Kompilieren aus dem Quellcode).

---

## Installation & Build

### 1. Vorkompilierte App herunterladen (DMG)

Laden Sie das neueste Disk-Image unter [GitHub Releases](https://github.com/badugisoft/antigravity-quota/releases) herunter:

1. Laden Sie **`Antigravity-Quota-<version>.dmg`** herunter und öffnen Sie das Image.
2. Ziehen Sie **Antigravity Quota.app** in den Ordner **Programme (Applications)**.
3. Starten Sie **Antigravity Quota** direkt aus dem Programme-Ordner (offizielle Releases sind mit Apple **Developer ID** signiert und **von Apple notarisiert**).
   > *(Bei älteren Releases `v1.3.1` und früher: Rechtsklick > **Öffnen** oder `xattr -cr "/Applications/Antigravity Quota.app"` ausführen.)*

### 2. Aus dem Quellcode per Skript bauen & installieren

Führen Sie das automatisierte Build-Skript im Repository-Stammverzeichnis aus:

```bash
git clone https://github.com/badugisoft/antigravity-quota.git
cd antigravity-quota
make build
```

Das Skript übernimmt automatisch:

1. Kompilierung aller Targets im `Release`-Modus (`swift build -c release`).
2. Paketierung der Haupt-App (`Antigravity Quota.app`) samt WidgetKit-Erweiterung (`Contents/PlugIns/AntigravityQuotaWidget.appex`).
3. Einbettung des hochauflösenden App-Icons (`AppIcon.icns`) und Konfiguration der `Info.plist` mit `LSUIElement=true`.
4. Code-Signierung (Inside-out) von Erweiterung und Haupt-Bundle (nutzt automatisch ein lokales Developer ID-Zertifikat, falls vorhanden, sonst Ad-hoc-Signierung).
5. Installation nach `/Applications/Antigravity Quota.app`.
6. Automatischer Start der Menüleisten-App.

### 3. Manueller Build mit SwiftPM

```bash
swift build -c release
```

Die ausführbaren Dateien werden unter `.build/release/AntigravityQuota` und `.build/release/AntigravityQuotaWidgetExtension` erstellt.

---

## Bei der Anmeldung starten (Optional)

Aktivieren Sie **Bei der Anmeldung starten** direkt in der App unter **Einstellungen > Allgemein > Bei der Anmeldung starten**, oder richten Sie es manuell in macOS ein:

1. Öffnen Sie die **Systemeinstellungen** auf Ihrem Mac.
2. Navigieren Sie zu **Allgemein** > **Anmeldeobjekte** (bzw. **Anmeldeobjekte & Erweiterungen**).
3. Klicken Sie unter **Bei der Anmeldung öffnen** auf die Schaltfläche **+**.
4. Wählen Sie `/Applications/Antigravity Quota.app` und klicken Sie auf **Öffnen**.

---

## FAQ & Fehlerbehebung

<details>
<summary><strong>macOS meldet, dass "Antigravity Quota" nicht geöffnet werden kann, da der Entwickler nicht verifiziert ist</strong></summary>

Aktuelle offizielle Releases (`v1.4.0+`) sind mit einem Apple Developer ID-Zertifikat signiert und von Apple notarisiert, sodass keine Gatekeeper-Warnung erscheint. Bei selbst erstellten Ad-hoc-Builds oder älteren Releases (`v1.3.1` und früher) klicken Sie mit der **rechten Maustaste** auf `Antigravity Quota.app` in `/Applications`, wählen Sie **Öffnen** und bestätigen Sie erneut mit **Öffnen**, oder führen Sie im Terminal aus:

```bash
xattr -cr "/Applications/Antigravity Quota.app"
```

</details>

<details>
<summary><strong>In der Menüleiste erscheint "Warten auf Antigravity" oder "Offline"</strong></summary>

Antigravity Quota liest die Daten direkt aus dem laufenden Google Antigravity `language_server`-Prozess. Prüfen Sie, ob Google Antigravity lokal geöffnet ist – oder aktivieren Sie bei Nutzung auf einem anderen Mac/Linux-Rechner Remote SSH unter **Einstellungen > Remote**.

</details>

<details>
<summary><strong>Warum zeigt ein zu 100 % volles Kontingent "Ungenutzt" statt eines Countdowns?</strong></summary>

Die 5-Stunden- und Wochenlimits arbeiten mit einem rollierenden Zeitfenster über verbrauchte Kontingente. Solange 100 % ungenutzt sind, verschiebt der Server den möglichen Reset-Zeitpunkt bei jeder Abfrage nach vorn (`jetzt + 5 Std.`). Daher unterdrückt die App den künstlichen Timer und zeigt bis zur ersten Nutzung `"Ungenutzt"`.

</details>

<details>
<summary><strong>Werden Telemetriedaten erfasst oder API-Keys benötigt?</strong></summary>

Nein. Antigravity Quota läuft zu 100 % lokal gegen `127.0.0.1` (bzw. Ihren konfigurierten SSH-Host), speichert keinerlei API-Keys oder Zugangsdaten und sendet keinerlei Telemetrie- oder Analysedaten. Details siehe [SECURITY.md](../SECURITY.md).

</details>

<details>
<summary><strong>Kann ich Antigravity auf einem anderen Mac überwachen?</strong></summary>

Ja. Richten Sie auf dem Zielrechner passwortlose SSH-Schlüssel-Authentifizierung (`BatchMode=yes`) ein, öffnen Sie **Einstellungen > Remote**, aktivieren Sie **Remote-SSH-Kontingentabfrage aktivieren**, geben Sie `user@hostname` oder Ihren `~/.ssh/config`-Alias ein und klicken Sie auf **Verbindung testen**.

</details>

---

## Mitwirken

Beiträge, Fehlerberichte und Funktionswünsche sind herzlich willkommen!

- In [CONTRIBUTING.md](../CONTRIBUTING.md) finden Sie Einrichtungshinweise, Pure-Swift-Regeln und Lokalisierungsvorgaben.
- Fehler und Vorschläge können über die [GitHub Issue-Vorlagen](https://github.com/badugisoft/antigravity-quota/issues/new/choose) eingereicht werden.
- Informationen zu Datenschutz und Sicherheitsmeldungen stehen in [SECURITY.md](../SECURITY.md).

---

## Projektstruktur

```
antigravity-quota/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md                        # Bug-Report-Vorlage
│   │   ├── feature_request.md                   # Feature-Request-Vorlage
│   │   └── config.yml                           # Issue-Auswahl & Release-Links
│   ├── PULL_REQUEST_TEMPLATE.md                 # Pull-Request-Checkliste
│   ├── release.yml                              # Regeln für Release Notes
│   └── workflows/
│       ├── release.yml                          # GitHub Actions CI/CD Release-Workflow
│       └── pages.yml                            # GitHub Pages Deployment-Workflow
├── Package.swift                                # SwiftPM Multi-Target-Konfiguration
├── LICENSE                                      # MIT-Lizenz
├── README.md                                    # Englische Dokumentation (Root)
├── CONTRIBUTING.md                              # Leitfaden für Mitwirkende
├── SECURITY.md                                  # Datenschutz- & Sicherheitsrichtlinie
├── AGENTS.md                                    # Richtlinien für KI-Agenten & Mitwirkende
├── site/                                        # GitHub Pages Projekt-Webseite (7 Sprachen)
│   ├── index.html                               # Landingpage-Struktur
│   ├── styles.css                               # Hell-/Dunkel-adaptives macOS-Styling
│   └── i18n.js                                  # 7-Sprachen-Übersetzung & Umschalter
├── docs/                                        # Mehrsprachige Dokumentation
│   ├── README.ko.md                             # 한국어
│   ├── README.zh.md                             # 简体中文
│   ├── README.ja.md                             # 日本語
│   ├── README.de.md                             # Deutsch
│   ├── README.fr.md                             # Français
│   └── README.es.md                             # Español
├── assets/                                      # Screenshots & Icon-Assets für die Dokumentation
│   ├── menubar_summary.png                      # Statusleisten-Kreisdiagramm & Übersicht
│   ├── popover_standard.png                     # Standardmodus-Popover
│   ├── popover_compact.png                      # Kompaktmodus-Popover
│   ├── widget_small.png                         # Kleines 1x1 macOS Widget
│   ├── widget_medium.png                        # Mittleres 1x2 macOS Widget
│   └── app_icon.png                             # 512x512 App-Icon
├── scripts/
│   ├── build_app.sh                             # Build-Skript für App & WidgetKit-Erweiterung
│   ├── package_release.sh                       # Automatisierter .dmg- & .zip-Release-Packer
│   └── entitlements/                            # macOS Sandbox- & App-Entitlements
│       ├── app.entitlements                     # Entitlements der Haupt-App
│       └── widget.entitlements                  # Entitlements der Widget-Erweiterung
├── Sources/
│   ├── AntigravityQuotaCore/                    # Gemeinsame Core-Bibliothek
│   │   ├── Models/
│   │   │   ├── QuotaModel.swift                 # Kontingent-Datenmodelle & Zeitformatierung
│   │   │   └── QuotaSnapshot.swift              # Snapshot-Struktur für Widgets
│   │   ├── Services/
│   │   │   ├── AppSettings.swift                # Persistente Einstellungen & Autostart
│   │   │   ├── QuotaDataStore.swift             # Application-Support-JSON & WidgetCenter-Sync
│   │   │   ├── NotificationManager.swift        # Geplante & sofortige Reset-Mitteilungen
│   │   │   ├── LocalizationManager.swift        # Sprachmanager & Dispatcher
│   │   │   └── Localization/                    # 7 Sprachwörterbücher
│   │   │       ├── LocalizedStrings+EN.swift
│   │   │       ├── LocalizedStrings+KO.swift
│   │   │       ├── LocalizedStrings+ZH.swift
│   │   │       ├── LocalizedStrings+JA.swift
│   │   │       ├── LocalizedStrings+DE.swift
│   │   │       ├── LocalizedStrings+FR.swift
│   │   │       └── LocalizedStrings+ES.swift
│   │   └── Views/
│   │       ├── SmallQuotaWidgetView.swift       # Kleines (1x1) Widget-Layout
│   │       ├── MediumQuotaWidgetView.swift      # Mittleres (1x2) Widget-Layout
│   │       └── WidgetBackgroundModifier.swift   # Versionsübergreifender Widget-Hintergrund
│   ├── AntigravityQuota/                        # Menüleisten-Anwendung
│   │   ├── main.swift                           # Einstiegspunkt
│   │   ├── App/
│   │   │   └── AppDelegate.swift                # NSStatusItem- & NSPopover-Lebenszyklus
│   │   ├── Services/
│   │   │   ├── LanguageServerDiscovery.swift    # PID-, CSRF- & Port-Erkennung
│   │   │   ├── MenuBarIconRenderer.swift        # Dynamisches Kreisdiagramm-Menüleisten-Icon
│   │   │   ├── QuotaService.swift               # Connect-RPC-Client & SSH-Fallback
│   │   │   └── RemoteSSHQuotaService.swift      # Einmalige Remote-SSH-Abfrage
│   │   ├── ViewModels/
│   │   │   └── QuotaViewModel.swift             # Haupt-ViewModel & adaptive Timer
│   │   ├── Views/
│   │   │   ├── MenuBarPopoverView.swift         # Popover-Root-View & Header-Steuerung
│   │   │   ├── QuotaGroupCardView.swift         # Standardmodus-Karte
│   │   │   ├── QuotaBucketRowView.swift         # Standardmodus-Zeile
│   │   │   ├── QuotaGroupCompactCardView.swift  # Kompaktmodus-Karte
│   │   │   ├── QuotaBucketCompactRowView.swift  # Kompaktmodus-Zeile
│   │   │   └── Settings/
│   │   │       ├── SettingsView.swift           # Tabs Allgemein, Remote & Mitteilungen
│   │   │       └── SettingsWindowController.swift # Einstellungsfenster-Controller
│   │   └── Resources/
│   │       └── AppIcon.icns                     # macOS Big Sur+ HIG Squircle-Icon
│   └── AntigravityQuotaWidget/                  # WidgetKit-Erweiterungs-Bundle
│       ├── AntigravityQuotaWidgetBundle.swift   # @main WidgetBundle-Definition
│       └── QuotaTimelineProvider.swift          # WidgetKit TimelineProvider
└── Tests/
    └── AntigravityQuotaTests/
        ├── QuotaModelTests.swift                # Modell-, Sprach- & Widget-Rendering-Tests
        └── QuotaServiceIntegrationTests.swift   # Live-RPC-Erkennungs-Integrationstest
```

---

## Lizenz

Dieses Projekt steht unter der **MIT-Lizenz** – siehe [LICENSE](../LICENSE) für Details.

---

<p align="center">
  Crafted with ❤️ by BadugiSoft & Google Antigravity.
</p>

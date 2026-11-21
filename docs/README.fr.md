# Antigravity Quota

<p align="center">
  <img src="../assets/app_icon.png" alt="Icône Antigravity Quota" width="128" height="128" />
</p>

<p align="center">
  <strong>Un moniteur de quota léger en temps réel pour la barre des menus macOS et des widgets WidgetKit pour Google Antigravity.</strong><br>
  <em>Suivez les limites des modèles Gemini, Claude et GPT, les minuteurs de réinitialisation et les pourcentages restants directement depuis la barre d'état, le bureau et le Centre de notifications.</em>
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
  <a href="README.de.md">Deutsch</a> ·
  <strong>Français</strong> ·
  <a href="README.es.md">Español</a>
</p>

<p align="center">
  <a href="https://github.com/badugisoft/antigravity-quota/releases/latest"><strong>⬇️ Télécharger le dernier DMG</strong></a> ·
  <a href="https://badugisoft.github.io/antigravity-quota/?lang=fr"><strong>🌐 Site web</strong></a> ·
  <a href="#captures-décran">Captures d'écran</a> ·
  <a href="#fonctionnalités">Fonctionnalités</a> ·
  <a href="#installation-et-compilation">Installation</a> ·
  <a href="#faq--dépannage">FAQ</a> ·
  <a href="#contribuer">Contribuer</a>
</p>

---

## Captures d'écran

<p align="center">
  <img src="../assets/menubar_summary.png" alt="Résumé de la barre d'état" />
  <br>
  <em>Jauge circulaire et résumé des quotas dans la barre d'état</em>
</p>

<p align="center">
  <img src="../assets/popover_standard.png" alt="Mode Standard" width="340" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="../assets/popover_compact.png" alt="Mode Compact" width="340" />
  <br>
  <em>Popover de la barre des menus : Mode Standard (gauche) &nbsp;|&nbsp; Mode Compact (droite)</em>
</p>

<p align="center">
  <img src="../assets/widget_small.png" alt="Petit widget (1x1)" width="165" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="../assets/widget_medium.png" alt="Widget moyen (1x2)" width="345" />
  <br>
  <em>Widgets macOS : Petit 1x1 (gauche) &nbsp;|&nbsp; Moyen 1x2 (droite)</em>
</p>

> [!NOTE]
> **🤖 100% Built with Google Antigravity**
>
> L'ensemble de cette application — découverte RPC locale, architecture, vues SwiftUI, extensions WidgetKit, logique d'interrogation adaptative, localisation multilingue, conception de l'icône et scripts de compilation — a été **conçu, implémenté et vérifié à 100 % en programmation en binôme autonome avec Google Antigravity**.

---

## Fonctionnalités

- **Suivi des quotas en temps réel** :
  - Découvre et affiche dynamiquement tous les groupes et compartiments de quotas renvoyés par Antigravity (p. ex. **Gemini Models**, **Claude and GPT models**, **Gemini 4 Argon**, et futurs groupes de modèles).
  - Surveille à la fois les **limites glissantes sur 5 heures** et les **limites hebdomadaires** pour tous les groupes actifs.
- **Icône dynamique à jauge circulaire dans la barre des menus** :
  - Affiche le logo Antigravity entouré d'un anneau de jauge reflétant le pourcentage restant du compartiment cible sélectionné (et passe à un anneau en pointillés hors ligne).
  - Prend en charge les modes **Icône et pourcentages de quota** (avec abréviations dynamiques par groupe, p. ex. `G:75% · C:100% · A:85%`) ou **Icône seule**, avec sélection de la **Cible de la jauge circulaire** dans **Paramètres > Général**.
- **Widgets macOS pour le bureau et le Centre de notifications (WidgetKit)** :
  - **Petit widget (`systemSmall` / 1x1)** : Vue minimaliste affichant dynamiquement tous les groupes actifs avec barres de progression, pourcentage restant, indicateur en ligne et prochain délai de réinitialisation.
  - **Widget moyen (`systemMedium` / 1x2)** : Carte à deux colonnes présentant côte à côte les groupes principaux, plus une ligne compacte en bas pour les groupes supplémentaires (tels que Gemini 4 Argon), avec comptes à rebours et statut en direct.
  - **Matériau verre dépoli natif** : Conçu avec `.regularMaterial` et intégration sans bordure (`.contentMarginsDisabled()`) pour s'harmoniser avec les widgets système macOS et le fond d'écran en modes Sombre et Clair.
  - Synchronisation instantanée via `QuotaDataStore` et `WidgetCenter.reloadAllTimelines()` à chaque mise à jour des quotas.
  - Prise en charge complète du mode Sombre de macOS et des 7 langues.
- **Comptes à rebours en direct** :
  - Comptes à rebours actualisés chaque seconde indiquant le temps exact avant la prochaine recharge (p. ex. `Reste 3h 2min`, `Reste 1j 19h`).
  - **Suppression du minuteur à 100 % inutilisé** : Lorsqu'un quota est plein à 100 % et non consommé, les fenêtres glissantes affichent proprement `"Inutilisé"` plutôt qu'un minuteur d'expiration artificiel.
- **Notifications de recharge de quota** :
  - Planifie à l'avance des notifications macOS natives (`UNUserNotificationCenter`) dès qu'un quota de 5 heures ou hebdomadaire redevient disponible à 100 %.
  - Gérez l'activation globale, les interrupteurs séparés **Alerte de réinitialisation du quota 5h** et **Alerte de réinitialisation du quota hebdomadaire**, l'autorisation système et **Envoyer une notification test** dans **Paramètres > Notifications**.
- **Interrogation adaptative intelligente** :
  - **Interrogation rapide de 15 s lors d'activité IA** : Lorsqu'une activité IA (génération de jetons, appels d'outils) consomme du quota, la fréquence passe automatiquement à 15 secondes pendant 3 minutes pour suivre l'évolution en temps réel même en arrière-plan.
  - **Interrogation au repos de 60 s** : En l'absence de consommation, la fréquence repasse à 60 secondes afin d'économiser batterie et CPU.
  - **Actualisation instantanée au focus** : Le passage sur la fenêtre Antigravity déclenche immédiatement une synchronisation.
  - **Mise en pause automatique** : Affiche un état en pause (`⏸`) lorsque Antigravity est fermé ou hors ligne, et reprend dès le redémarrage.
- **Repli SSH distant (Synchronisation multi-machines)** :
  - Sur plusieurs Mac, lorsque Antigravity ne tourne pas en local, l'application peut interroger votre machine distante via SSH.
  - Entièrement configurable dans **Paramètres > Distant** : **Activer la requête de quota SSH distante**, **Hôte SSH** (`user@hostname` ou alias `~/.ssh/config`), **Intervalle d'interrogation distante** (30 s, 1 min, 2 min, 5 min) et bouton **Tester la connexion**.
  - Exécute des requêtes RPC ponctuelles directes via `/usr/bin/ssh` sans démon de tunnel persistant, dépendance externe ni synchronisation de fichiers.
- **Modes Standard / Compact et Préférences** :
  - **Mode Standard** : Cartes détaillées avec barres de progression dégradées, pourcentages restants/utilisés et heures de réinitialisation prévues.
  - **Mode Compact** : Vue ultra-fine sans défilement pour un encombrement minimal.
  - **Fenêtre Paramètres native** : Accédez aux onglets **Général** (incluant **Lancer au démarrage** via `SMAppService`), **Distant** et **Notifications** depuis l'icône d'engrenage en haut du popover.
- **Support multilingue (7 langues)** :
  - Prend en charge **English**, **한국어**, **简体中文**, **日本語**, **Deutsch**, **Français** et **Español**.
  - Détecte automatiquement la langue système de macOS au premier lancement.
  - Menu déroulant en un clic dans l'en-tête du popover ou sélecteur dans les paramètres.
  - Tous les textes, comptes à rebours, heures de recharge, notifications et horodatages sont adaptés à la locale choisie.
- **100 % local et confidentiel** :
  - Interroge uniquement votre serveur de langage Antigravity local sur `127.0.0.1` (ou votre hôte SSH configuré explicitement), sans télémétrie, sans serveur tiers et sans stockage de clés API. Consultez [SECURITY.md](../SECURITY.md).
- **Expérience macOS native** :
  - 100 % Swift, SwiftUI, AppKit et WidgetKit.
  - Application uniquement dans la barre des menus (`LSUIElement = true`) sans encombrer le Dock.
  - Icône squircle conforme aux Apple Human Interface Guidelines.
  - Zéro dépendance tierce externe — Swift Package Manager pur.

---

## Fonctionnement

Antigravity exécute un démon serveur de langage interne (`language_server`) à l'écoute sur un port TCP local éphémère.

1. **Extraction du processus et du jeton CSRF** :
   Inspecte `/bin/ps` pour localiser le processus `language_server` actif et extrait le jeton CSRF de session depuis les arguments CLI (`--csrf_token`) ou les variables d'environnement (`ANTIGRAVITY_SERVER_CSRF_TOKEN` à partir d'Antigravity 2.34.0 via `ps eww -p <pid>`).
2. **Résolution instantanée du port** :
   Utilise `/usr/sbin/lsof` (avec repli sur `/usr/sbin/netstat`) pour détecter les sockets TCP en écoute du PID en moins d'une milliseconde sans balayage de ports.
3. **Protocole Connect-RPC** :
   Envoie des requêtes HTTP/HTTPS POST vers `127.0.0.1:<port>/exa.language_server_pb.LanguageServerService/RetrieveUserQuotaSummary` avec l'en-tête `x-codeium-csrf-token`.
4. **Stockage partagé et synchronisation des widgets** :
   Enregistre le dernier instantané via `QuotaDataStore` dans `~/Library/Application Support/AntigravityQuota/shared_quota.json` et appelle `WidgetCenter.shared.reloadAllTimelines()` pour mettre à jour instantanément les widgets en bac à sable sans invite TCC.
5. **Affichage réactif** :
   Analyse `remainingFraction` et `resetTime` dans des modèles Swift fortement typés et les restitue via SwiftUI, `NSStatusItem` et WidgetKit.

---

## Ajouter des widgets à macOS

1. Installez **Antigravity Quota.app** dans `/Applications` (via le DMG ou `./scripts/build_app.sh`).
2. Faites un clic droit sur votre bureau macOS et choisissez **Modifier les widgets...** (ou ouvrez le **Centre de notifications** puis cliquez sur **Modifier les widgets** en bas).
3. Recherchez **Antigravity Quota** dans la galerie de widgets.
4. Sélectionnez le widget **Petit (1x1)** ou **Moyen (1x2)** et faites-le glisser sur le bureau ou dans le Centre de notifications.

---

## Configuration requise

- **macOS** : 13.0 (Ventura) ou ultérieur.
- **Matériel** : Apple Silicon (M1/M2/M3/M4) ou Mac Intel.
- **Antigravity** : Google Antigravity installé (en local ou sur un hôte SSH accessible).
- **Outils de développement** : Xcode 15.0+ ou chaîne d'outils Swift 5.9+ (uniquement pour compiler depuis les sources).

---

## Installation et compilation

### 1. Télécharger l'application précompilée (DMG)

Téléchargez la dernière image disque depuis [GitHub Releases](https://github.com/badugisoft/antigravity-quota/releases) :

1. Téléchargez **`Antigravity-Quota-<version>.dmg`** et ouvrez-le.
2. Faites glisser **Antigravity Quota.app** dans le dossier **Applications**.
3. **Premier lancement (Gatekeeper)** :
   - Cette version open-source étant distribuée avec une signature ad-hoc, macOS peut afficher une alerte de développeur non identifié.
   - Faites un **clic droit** sur `Antigravity Quota.app` dans `/Applications`, cliquez sur **Ouvrir**, puis confirmez avec **Ouvrir**.
   - Ou exécutez dans le Terminal :
     ```bash
     xattr -cr "/Applications/Antigravity Quota.app"
     ```

### 2. Compiler et installer via script depuis les sources

Exécutez le script automatisé depuis la racine du dépôt :

```bash
git clone https://github.com/badugisoft/antigravity-quota.git
cd antigravity-quota
./scripts/build_app.sh
```

Le script effectue automatiquement les étapes suivantes :

1. Compilation de toutes les cibles en mode `Release` (`swift build -c release`).
2. Empaquetage de l'application principale (`Antigravity Quota.app`) et intégration de l'extension WidgetKit (`Contents/PlugIns/AntigravityQuotaWidget.appex`).
3. Intégration des icônes haute résolution (`AppIcon.icns`) et configuration de `Info.plist` avec `LSUIElement=true`.
4. Signature ad-hoc de l'extension puis du bundle principal (de l'intérieur vers l'extérieur).
5. Installation dans `/Applications/Antigravity Quota.app`.
6. Lancement automatique de l'application dans la barre des menus.

### 3. Compilation manuelle avec SwiftPM

```bash
swift build -c release
```

Les exécutables sont générés dans `.build/release/AntigravityQuota` et `.build/release/AntigravityQuotaWidgetExtension`.

---

## Lancer au démarrage (Optionnel)

Vous pouvez activer **Lancer au démarrage** directement dans l'application via **Paramètres > Général > Lancer au démarrage**, ou manuellement dans macOS :

1. Ouvrez **Réglages Système** sur votre Mac.
2. Accédez à **Général** > **Ouverture** (ou **Ouverture et extensions**).
3. Sous **Ouvrir avec la session**, cliquez sur le bouton **+**.
4. Sélectionnez `/Applications/Antigravity Quota.app` puis cliquez sur **Ouvrir**.

---

## FAQ & Dépannage

<details>
<summary><strong>macOS indique qu'« Antigravity Quota » ne peut pas être ouvert car le développeur ne peut pas être vérifié</strong></summary>

Cette version open-source utilisant une signature ad-hoc sans certificat de notarisation Apple Developer payant, macOS Gatekeeper bloque par défaut le premier lancement. Faites un **clic droit** sur `Antigravity Quota.app` dans `/Applications`, cliquez sur **Ouvrir**, puis confirmez avec **Ouvrir**, ou exécutez dans le Terminal :

```bash
xattr -cr "/Applications/Antigravity Quota.app"
```

</details>

<details>
<summary><strong>La barre des menus affiche « En attente d'Antigravity » ou « Hors ligne »</strong></summary>

Antigravity Quota lit les quotas directement depuis le processus `language_server` de Google Antigravity en cours d'exécution. Vérifiez que Google Antigravity est ouvert localement — ou activez le mode SSH distant dans **Paramètres > Distant** s'il tourne sur un autre Mac ou serveur Linux.

</details>

<details>
<summary><strong>Pourquoi un quota plein à 100 % affiche-t-il « Inutilisé » au lieu d'un compte à rebours ?</strong></summary>

Les limites de 5 heures et hebdomadaires fonctionnent selon une fenêtre glissante sur le quota consommé. Lorsqu'un compartiment est intact à 100 %, le serveur décale l'échéance théorique à chaque requête (`maintenant + 5h`). L'application masque donc ce minuteur artificiel et affiche `"Inutilisé"` jusqu'à la première consommation.

</details>

<details>
<summary><strong>L'application collecte-t-elle de la télémétrie ou demande-t-elle des clés API ?</strong></summary>

Non. Antigravity Quota fonctionne à 100 % localement vers `127.0.0.1` (ou votre hôte SSH configuré), ne stocke aucune clé API ni identifiant et n'envoie aucune télémétrie ni donnée analytique. Consultez [SECURITY.md](../SECURITY.md) pour plus de détails.

</details>

<details>
<summary><strong>Puis-je surveiller Antigravity exécuté sur un autre Mac ?</strong></summary>

Oui. Configurez une authentification par clé SSH sans mot de passe (`BatchMode=yes`) vers la machine cible, ouvrez **Paramètres > Distant**, activez **Activer la requête de quota SSH distante**, saisissez `user@hostname` ou votre alias `~/.ssh/config` puis cliquez sur **Tester la connexion**.

</details>

---

## Contribuer

Les contributions, signalements de bugs et suggestions sont les bienvenus !

- Consultez [CONTRIBUTING.md](../CONTRIBUTING.md) pour la configuration locale, les conventions Swift pur et les règles multilingues.
- Signalez un bug ou proposez une fonctionnalité via les [modèles d'issues GitHub](https://github.com/badugisoft/antigravity-quota/issues/new/choose).
- Consultez [SECURITY.md](../SECURITY.md) pour la confidentialité et le signalement de vulnérabilités.

---

## Structure du projet

```
antigravity-quota/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md                        # Modèle de rapport de bug
│   │   ├── feature_request.md                   # Modèle de demande de fonctionnalité
│   │   └── config.yml                           # Sélecteur d'issues et liens de version
│   ├── PULL_REQUEST_TEMPLATE.md                 # Liste de contrôle des Pull Requests
│   ├── release.yml                              # Règles de catégories des notes de version
│   └── workflows/
│       ├── release.yml                          # Workflow CI/CD de publication GitHub Actions
│       └── pages.yml                            # Workflow de déploiement GitHub Pages
├── Package.swift                                # Configuration multi-cibles SwiftPM
├── LICENSE                                      # Licence MIT
├── README.md                                    # Documentation anglaise (racine)
├── CONTRIBUTING.md                              # Guide du contributeur et conventions
├── SECURITY.md                                  # Politique de confidentialité et de sécurité
├── AGENTS.md                                    # Directives pour agents IA et contributeurs
├── site/                                        # Site promotionnel GitHub Pages (7 langues)
│   ├── index.html                               # Structure de la page d'accueil
│   ├── styles.css                               # Style macOS adaptatif clair/sombre
│   └── i18n.js                                  # Traductions et sélecteur 7 langues
├── docs/                                        # Documentation multilingue
│   ├── README.ko.md                             # 한국어
│   ├── README.zh.md                             # 简体中文
│   ├── README.ja.md                             # 日本語
│   ├── README.de.md                             # Deutsch
│   ├── README.fr.md                             # Français
│   └── README.es.md                             # Español
├── assets/                                      # Captures d'écran et icône pour la documentation
│   ├── menubar_summary.png                      # Jauge et résumé de la barre d'état
│   ├── popover_standard.png                     # Popover en mode standard
│   ├── popover_compact.png                      # Popover en mode compact
│   ├── widget_small.png                         # Petit widget macOS 1x1
│   ├── widget_medium.png                        # Widget macOS moyen 1x2
│   └── app_icon.png                             # Icône 512x512
├── scripts/
│   ├── build_app.sh                             # Script de compilation App & extension WidgetKit
│   ├── package_release.sh                       # Empaqueteur automatisé .dmg et .zip
│   └── entitlements/                            # Droits App Sandbox macOS
│       ├── app.entitlements                     # Droits de l'application hôte
│       └── widget.entitlements                  # Droits de l'extension widget en bac à sable
├── Sources/
│   ├── AntigravityQuotaCore/                    # Bibliothèque cœur partagée
│   │   ├── Models/
│   │   │   ├── QuotaModel.swift                 # Modèles de quotas et formatage temporel
│   │   │   └── QuotaSnapshot.swift              # Structure d'instantané pour widgets
│   │   ├── Services/
│   │   │   ├── AppSettings.swift                # Préférences persistantes et démarrage auto
│   │   │   ├── QuotaDataStore.swift             # Stockage JSON Application Support & WidgetCenter
│   │   │   ├── NotificationManager.swift        # Notifications planifiées et immédiates
│   │   │   ├── LocalizationManager.swift        # Gestionnaire et répartiteur multilingue
│   │   │   └── Localization/                    # 7 dictionnaires de langues supportées
│   │   │       ├── LocalizedStrings+EN.swift
│   │   │       ├── LocalizedStrings+KO.swift
│   │   │       ├── LocalizedStrings+ZH.swift
│   │   │       ├── LocalizedStrings+JA.swift
│   │   │       ├── LocalizedStrings+DE.swift
│   │   │       ├── LocalizedStrings+FR.swift
│   │   │       └── LocalizedStrings+ES.swift
│   │   └── Views/
│   │       ├── SmallQuotaWidgetView.swift       # Mise en page petit widget (1x1)
│   │       ├── MediumQuotaWidgetView.swift      # Mise en page widget moyen (1x2)
│   │       └── WidgetBackgroundModifier.swift   # Arrière-plan compatible multi-versions
│   ├── AntigravityQuota/                        # Application barre des menus
│   │   ├── main.swift                           # Point d'entrée
│   │   ├── App/
│   │   │   └── AppDelegate.swift                # Cycle de vie NSStatusItem & NSPopover
│   │   ├── Services/
│   │   │   ├── LanguageServerDiscovery.swift    # Découverte PID, CSRF et port
│   │   │   ├── MenuBarIconRenderer.swift        # Icône dynamique à jauge circulaire
│   │   │   ├── QuotaService.swift               # Client Connect-RPC & repli SSH
│   │   │   └── RemoteSSHQuotaService.swift      # Requête SSH distante ponctuelle
│   │   ├── ViewModels/
│   │   │   └── QuotaViewModel.swift             # ViewModel principal & minuteurs adaptatifs
│   │   ├── Views/
│   │   │   ├── MenuBarPopoverView.swift         # Vue racine du popover et contrôles d'en-tête
│   │   │   ├── QuotaGroupCardView.swift         # Carte en mode standard
│   │   │   ├── QuotaBucketRowView.swift         # Ligne de compartiment en mode standard
│   │   │   ├── QuotaGroupCompactCardView.swift  # Carte en mode compact
│   │   │   ├── QuotaBucketCompactRowView.swift  # Ligne de compartiment en mode compact
│   │   │   └── Settings/
│   │   │       ├── SettingsView.swift           # Onglets Général, Distant et Notifications
│   │   │       └── SettingsWindowController.swift # Contrôleur de la fenêtre Paramètres
│   │   └── Resources/
│   │       └── AppIcon.icns                     # Icône squircle HIG macOS Big Sur+
│   └── AntigravityQuotaWidget/                  # Bundle d'extension WidgetKit
│       ├── AntigravityQuotaWidgetBundle.swift   # Définition @main WidgetBundle
│       └── QuotaTimelineProvider.swift          # TimelineProvider WidgetKit
└── Tests/
    └── AntigravityQuotaTests/
        ├── QuotaModelTests.swift                # Tests modèles, langues et rendu widgets
        └── QuotaServiceIntegrationTests.swift   # Test d'intégration RPC en direct
```

---

## Licence

Ce projet est distribué sous **licence MIT** — consultez le fichier [LICENSE](../LICENSE) pour plus de détails.

---

<p align="center">
  Crafted with ❤️ by BadugiSoft & Google Antigravity.
</p>

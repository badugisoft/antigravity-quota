# Antigravity Quota

<p align="center">
  <img src="../assets/app_icon.png" alt="Antigravity Quota アイコン" width="128" height="128" />
</p>

<p align="center">
  <strong>Google Antigravity 向けの軽量・リアルタイム macOS メニューバークォータモニター＆WidgetKit ウィジェット。</strong><br>
  <em>Gemini、Claude、GPT モデルの使用上限、リセットまでの残り時間、残量割合をステータスバー・デスクトップ・通知センターから即座に確認できます。</em>
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
  <strong>日本語</strong> ·
  <a href="README.de.md">Deutsch</a> ·
  <a href="README.fr.md">Français</a> ·
  <a href="README.es.md">Español</a>
</p>

<p align="center">
  <a href="https://github.com/badugisoft/antigravity-quota/releases/latest"><strong>⬇️ 最新 DMG をダウンロード</strong></a> ·
  <a href="https://badugisoft.github.io/antigravity-quota/?lang=ja"><strong>🌐 公式サイト</strong></a> ·
  <a href="#スクリーンショット">スクリーンショット</a> ·
  <a href="#主な機能">主な機能</a> ·
  <a href="#インストールとビルド">インストール</a> ·
  <a href="#よくある質問とトラブルシューティング">FAQ</a> ·
  <a href="#コントリビュート">コントリビュート</a>
</p>

---

## スクリーンショット

<p align="center">
  <img src="../assets/menubar_summary.png" alt="ステータスバーサマリー" />
  <br>
  <em>ステータスバーの円形ゲージとクォータサマリー</em>
</p>

<p align="center">
  <img src="../assets/popover_standard.png" alt="標準モード" width="340" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="../assets/popover_compact.png" alt="コンパクトモード" width="340" />
  <br>
  <em>メニューバーポップオーバー：標準モード（左）&nbsp;|&nbsp; コンパクトモード（右）</em>
</p>

<p align="center">
  <img src="../assets/widget_small.png" alt="小ウィジェット (1x1)" width="165" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="../assets/widget_medium.png" alt="中ウィジェット (1x2)" width="345" />
  <br>
  <em>macOS ウィジェット：小 1x1（左）&nbsp;|&nbsp; 中 1x2（右）</em>
</p>

> [!NOTE]
> **🤖 100% Built with Google Antigravity**
>
> ローカル RPC 探索、アーキテクチャ設計、SwiftUI ビュー、WidgetKit 拡張、適応型ポーリングロジック、多言語ローカライズ、アイコンデザイン、ビルドスクリプトに至るまで、本アプリケーション全体が **Google Antigravity との自律的ペアプログラミングによって 100% 設計・実装・検証**されました。

---

## 主な機能

- **リアルタイムクォータ監視**:
  - Antigravity が返す全てのクォータグループとバケット（例：**Gemini Models**、**Claude and GPT models**、**Gemini 4 Argon**、および今後の新規モデルグループ）を動的に検出・表示します。
  - アクティブな全グループの **5時間周期上限** と **週間上限** の両方を監視します。
- **動的メニューバー円形ゲージアイコン**:
  - 選択した対象クォータバケットの残量割合を示す円形ゲージリング付きの Antigravity ロゴを描画します（オフライン時は破線リングに切り替わります）。
  - **アイコンとクォータ残量**（グループ別の動的略称表示、例：`G:75% · C:100% · A:85%`）と **アイコンのみ** の表示切り替えに対応し、**設定 > 一般** の **円形ゲージ表示対象** から任意のバケットを選択できます。
- **macOS デスクトップ＆通知センターウィジェット (WidgetKit)**:
  - **小ウィジェット (`systemSmall` / 1x1)**：すべてのアクティブなモデルグループのプログレスバー、残量 %、オンラインインジケーター、最短リセットカウントダウンをコンパクトに表示します。
  - **中ウィジェット (`systemMedium` / 1x2)**：主要2グループを2列で並列表示し、追加グループ（Gemini 4 Argon など）を下部のコンパクト行に配置してカウントダウンやオンライン状態を一覧表示します。
  - **ネイティブすりガラスマテリアル**：`.regularMaterial` とマージンレス統合（`.contentMarginsDisabled()`）により、ダーク・ライト両モードで macOS システムウィジェットや壁紙の色合いに自然に溶け込みます。
  - クォータ更新のたびに `QuotaDataStore` へ保存し `WidgetCenter.reloadAllTimelines()` を即座に呼び出すことでリアルタイム同期を実現します。
  - macOS ダークモードおよび全7言語に完全対応しています。
- **リアルタイムカウントダウンタイマー**:
  - 次のクォータ回復までの残り時間を1秒間隔でライブ表示します（例：`残り 3時間 2分`、`残り 1日 19時間`）。
  - **100% 未使用時のタイマー抑止**：クォータが 100% 残っている未使用状態では、見かけ上のローリング期限タイマーではなく `"未使用"` とシンプルに表示します。
- **クォータ回復通知**:
  - 消費された5時間または週間クォータバケットが 100% に回復するタイミングに合わせてネイティブ macOS 通知（`UNUserNotificationCenter`）を事前予約します。
  - **設定 > 通知** から全体の有効/無効、**5時間クォータリセット通知** と **週間クォータリセット通知** の個別設定、システム通知権限の確認/リクエスト、**テスト通知を送信** が行えます。
- **適応型スマートポーリング**:
  - **15秒 AI バーストポーリング**：トークン生成やツール呼び出しなどの AI アクティビティでクォータ消費を検知すると、3分間のクールダウン期間中ポーリング間隔を自動的に 15 秒へ短縮し、バックグラウンド動作中でもリアルタイムに更新します。
  - **60秒アイドルポーリング**：クォータ消費がない場合は自動的に 60 秒間隔へ戻り、バッテリーと CPU 負荷を抑えます。
  - **フォーカス時の即時更新**：Antigravity ウィンドウに切り替えると即座に 1 回同期を実行し、最新の変更をすぐ反映します。
  - **自動一時停止**：Antigravity の終了やオフライン時には一時停止状態（`⏸`）を表示し、再起動とともに即座に再開します。
- **リモート SSH フォールバック（複数マシン同期）**:
  - 複数の Mac を併用しておりローカルで Antigravity が起動していない場合でも、SSH 経由でリモートマシンのクォータを取得できます。
  - **設定 > リモート** で **リモートSSHクォータ照会を使用**、**SSHホスト**（`user@hostname` または `~/.ssh/config` のエイリアス）、**リモート照会間隔**（30秒、1分、2分、5分）、**接続テスト** を簡単に設定可能です。
  - 常駐トンネルプロセスや外部依存を使わず、`/usr/bin/ssh` によるワンショット RPC 照会で安全かつ軽量に動作します。
- **標準／コンパクト表示モード＆設定画面**:
  - **標準モード**：グラデーション付きプログレスバー、残量/使用割合、リセット予定時刻を含む詳細カード表示。
  - **コンパクトモード**：スクロール不要で画面占有を最小限に抑える超スリム表示。
  - **ネイティブ設定ウィンドウ**：ポップオーバー右上の歯車アイコンから **一般**（`SMAppService` による **ログイン時に自動起動** 対応）、**リモート**、**通知** の各設定タブへアクセスできます。
- **多言語サポート（7言語）**:
  - **English**、**한국어**、**简体中文**、**日本語**、**Deutsch**、**Français**、**Español** に対応しています。
  - 初回起動時に macOS のシステム言語設定に合わせて自動選択されます。
  - ポップオーバーヘッダーのドロップダウンメニューや設定画面からワンクリックで言語を切り替えられます。
  - UI 文字列、カウントダウン、リセット予定時刻、通知、最終更新時刻がすべて選択言語のロケールで表示されます。
- **100% ローカル動作＆プライバシー保護**:
  - ローカルの `127.0.0.1` Antigravity 言語サーバー（または明示的に設定した SSH ホスト）のみへアクセスし、テレメトリ送信、外部サーバー通信、API キーの保存は一切行いません。詳細は [SECURITY.md](../SECURITY.md) をご覧ください。
- **ネイティブ macOS エクスペリエンス**:
  - 100% Swift、SwiftUI、AppKit、WidgetKit で構築。
  - Dock に表示されないメニューバー専用常駐アプリ（`LSUIElement = true`）。
  - Apple Human Interface Guidelines（HIG）準拠の macOS スクワークルアイコン。
  - 外部サードパーティライブラリ依存なしの純粋な Swift Package Manager 構成。

---

## 動作の仕組み

Antigravity はローカルの一時 TCP ポートで待機する内部言語サーバーデーモン（`language_server`）を実行しています。

1. **プロセス＆CSRF トークン抽出**:
   `/bin/ps` を調べて稼働中の `language_server` プロセスを特定し、CLI 引数（`--csrf_token`）またはプロセス環境変数（Antigravity 2.34.0 以降は `ps eww -p <pid>` 経由の `ANTIGRAVITY_SERVER_CSRF_TOKEN`）からセッション CSRF トークンを抽出します。
2. **高速ポート解決**:
   ポートスキャンを行わず、`/usr/sbin/lsof`（`/usr/sbin/netstat` フォールバック付き）を使用して対象 PID の待ち受け TCP ソケットを 1 ミリ秒未満で特定します。
3. **Connect-RPC プロトコル**:
   認証ヘッダー `x-codeium-csrf-token` を付与して `127.0.0.1:<port>/exa.language_server_pb.LanguageServerService/RetrieveUserQuotaSummary` へ HTTP/HTTPS POST リクエストを送信します。
4. **共有データストア＆ウィジェット同期**:
   `QuotaDataStore` を通じて最新のスナップショットを `~/Library/Application Support/AntigravityQuota/shared_quota.json` に保存し、`WidgetCenter.shared.reloadAllTimelines()` を呼び出すことで、TCC プライバシーダイアログを出さずにサンドボックス化されたウィジェットを即座に更新します。
5. **リアクティブ表示**:
   `remainingFraction` と `resetTime` を型安全な Swift モデルへパースし、SwiftUI、`NSStatusItem`、WidgetKit でシームレスに描画します。

---

## macOS へのウィジェット追加手順

1. DMG または `./scripts/build_app.sh` で **Antigravity Quota.app** を `/Applications` にインストールします。
2. macOS のデスクトップを右クリックして **ウィジェットを編集...** を選択します（または **通知センター** を開いて下部の **ウィジェットを編集** をクリック）。
3. ウィジェットギャラリーで **Antigravity Quota** を検索します。
4. **小 (1x1)** または **中 (1x2)** ウィジェットを選び、デスクトップまたは通知センターへドラッグします。

---

## システム要件

- **macOS**: 13.0 (Ventura) 以降。
- **ハードウェア**: Apple Silicon (M1/M2/M3/M4) または Intel Mac。
- **Antigravity**: Google Antigravity がインストールされていること（ローカルまたは SSH 接続可能なリモートホスト）。
- **開発ツール**: ソースからビルドする場合のみ Xcode 15.0+ または Swift 5.9+ ツールチェインが必要。

---

## インストールとビルド

### 1. ビルド済みアプリをダウンロード (DMG)

[GitHub Releases](https://github.com/badugisoft/antigravity-quota/releases) から最新のディスクイメージをダウンロードします：

1. **`Antigravity-Quota-<version>.dmg`** をダウンロードして開きます。
2. **Antigravity Quota.app** を **Applications（アプリケーション）** フォルダにドラッグします。
3. **Applications（アプリケーション）** から **Antigravity Quota** をそのまま起動します（公式リリースは Apple **Developer ID** 署名および **Apple 公証**済みのため、Gatekeeper の警告なしで起動できます）。
   > *（`v1.3.1` 以前の旧バージョンをご利用の場合は、アプリを右クリック > **開く**、または `xattr -cr "/Applications/Antigravity Quota.app"` を実行してください。）*

### 2. スクリプトでソースからビルド＆インストール

リポジトリルートで自動ビルドスクリプトを実行します：

```bash
git clone https://github.com/badugisoft/antigravity-quota.git
cd antigravity-quota
./scripts/build_app.sh
```

スクリプトは以下の処理を自動実行します：

1. すべてのターゲットを `Release` モードでコンパイル（`swift build -c release`）。
2. メインアプリ（`Antigravity Quota.app`）をパッケージ化し、WidgetKit 拡張（`Contents/PlugIns/AntigravityQuotaWidget.appex`）を同梱。
3. 高解像度アイコン（`AppIcon.icns`）を組み込み、`LSUIElement=true` を設定した `Info.plist` を生成。
4. 拡張機能とメインアプリバンドルを内側からの順序（Inside-Out）でコード署名（ローカルに Developer ID 証明書があれば自動使用し、ない場合はアドホック署名にフォールバック）。
5. `/Applications/Antigravity Quota.app` へ自動インストール。
6. メニューバーアプリを自動起動。

### 3. SwiftPM による手動ビルド

```bash
swift build -c release
```

実行ファイルは `.build/release/AntigravityQuota` と `.build/release/AntigravityQuotaWidgetExtension` に生成されます。

---

## ログイン時の自動起動（任意）

アプリ内の **設定 > 一般 > ログイン時に自動起動** から有効化できるほか、macOS のシステム設定からも手動で設定できます：

1. Mac で **システム設定** を開きます。
2. **一般** > **ログイン項目**（または **ログイン項目と拡張機能**）へ進みます。
3. **ログイン時に開く** の下にある **+** ボタンをクリックします。
4. `/Applications/Antigravity Quota.app` を選択して **開く** をクリックします。

---

## よくある質問とトラブルシューティング

<details>
<summary><strong>macOS で「開発元を検証できないため開けません」と表示されます</strong></summary>

最新の公式リリース（`v1.4.0+`）は Apple Developer ID 証明書で署名され Apple の公証を受けているため、Gatekeeper にブロックされることなく起動できます。セルフビルドのアドホック版や旧リリース（`v1.3.1` 以前）をご利用の場合は、`/Applications` 内の `Antigravity Quota.app` を **右クリック > 開く** から **開く** を選択するか、ターミナルで次を実行してください：

```bash
xattr -cr "/Applications/Antigravity Quota.app"
```

</details>

<details>
<summary><strong>メニューバーに「Antigravity の接続待機中」または「オフライン」と表示されます</strong></summary>

Antigravity Quota は起動中の Google Antigravity `language_server` プロセスから直接クォータを取得します。ローカルで Google Antigravity が起動しているか確認するか、別の Mac／Linux マシンで動かしている場合は **設定 > リモート** でリモート SSH 照会を有効にしてください。

</details>

<details>
<summary><strong>残量 100% のバケットにカウントダウンではなく「未使用」と表示されるのはなぜですか？</strong></summary>

Antigravity の 5 時間・週間上限は消費分に対するローリングウィンドウ方式で動作しています。残量が 100% 未使用の状態では、リクエストごとにリセット予定時刻が現在時刻から 5 時間後へスライドするため、不自然なカウントダウンを抑止して実際に使用が開始されるまで `"未使用"` を表示します。

</details>

<details>
<summary><strong>テレメトリの収集や API キーの設定は必要ですか？</strong></summary>

いいえ。Antigravity Quota はローカルの `127.0.0.1`（または設定した SSH ホスト）に対して 100% ローカルで動作し、API キーや認証情報を保存せず、テレメトリや解析データも一切送信しません。プライバシー設計の詳細は [SECURITY.md](../SECURITY.md) をご覧ください。

</details>

<details>
<summary><strong>別の Mac で動作している Antigravity を監視できますか？</strong></summary>

はい。対象マシンへパスワードなしで接続できる SSH 鍵認証（`BatchMode=yes`）を設定したうえで、**設定 > リモート** から **リモートSSHクォータ照会を使用** を有効にし、`user@hostname` または `~/.ssh/config` のエイリアスを入力して **接続テスト** を実行してください。

</details>

---

## コントリビュート

バグ報告、機能提案、プルリクエストを歓迎します！

- ローカル開発手順、純粋 Swift 規約、多言語ガイドラインについては [CONTRIBUTING.md](../CONTRIBUTING.md) をご確認ください。
- バグ報告や機能要望は [GitHub Issue テンプレート](https://github.com/badugisoft/antigravity-quota/issues/new/choose) からお送りください。
- プライバシー設計や脆弱性の報告については [SECURITY.md](../SECURITY.md) をご確認ください。

---

## プロジェクト構成

```
antigravity-quota/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md                        # バグ報告テンプレート
│   │   ├── feature_request.md                   # 機能リクエストテンプレート
│   │   └── config.yml                           # Issue 選択画面＆リリースリンク
│   ├── PULL_REQUEST_TEMPLATE.md                 # Pull Request チェックリストテンプレート
│   ├── release.yml                              # リリースノート分類ルール
│   └── workflows/
│       ├── release.yml                          # GitHub Actions CI/CD リリースワークフロー
│       └── pages.yml                            # GitHub Pages 自動デプロイワークフロー
├── Package.swift                                # SwiftPM マルチターゲット構成
├── LICENSE                                      # MIT ライセンス
├── README.md                                    # 英語ドキュメント（ルート）
├── CONTRIBUTING.md                              # コントリビュートガイド＆規約
├── SECURITY.md                                  # プライバシー＆セキュリティポリシー
├── AGENTS.md                                    # AI エージェント＆コントリビューター向けガイド
├── site/                                        # GitHub Pages プロモーションサイト（7言語）
│   ├── index.html                               # ランディングページ構造
│   ├── styles.css                               # ライト／ダーク対応 macOS スタイル
│   └── i18n.js                                  # 7言語翻訳＆切り替えスクリプト
├── docs/                                        # 多言語ドキュメント
│   ├── README.ko.md                             # 한국어
│   ├── README.zh.md                             # 简体中文
│   ├── README.ja.md                             # 日本語
│   ├── README.de.md                             # Deutsch
│   ├── README.fr.md                             # Français
│   └── README.es.md                             # Español
├── assets/                                      # ドキュメント用スクリーンショット＆アイコン
│   ├── menubar_summary.png                      # ステータスバーゲージ＆サマリー
│   ├── popover_standard.png                     # 標準モードポップオーバー
│   ├── popover_compact.png                      # コンパクトモードポップオーバー
│   ├── widget_small.png                         # 小 1x1 macOS ウィジェット
│   ├── widget_medium.png                        # 中 1x2 macOS ウィジェット
│   └── app_icon.png                             # 512x512 アプリアイコン
├── scripts/
│   ├── build_app.sh                             # アプリ＆WidgetKit 拡張ビルドスクリプト
│   ├── package_release.sh                       # 自動 .dmg / .zip リリースパッケージャー
│   └── entitlements/                            # macOS サンドボックス＆権限設定
│       ├── app.entitlements                     # ホストアプリ entitlements
│       └── widget.entitlements                  # サンドボックス化ウィジェット拡張 entitlements
├── Sources/
│   ├── AntigravityQuotaCore/                    # 共有コアライブラリ
│   │   ├── Models/
│   │   │   ├── QuotaModel.swift                 # クォータデータモデル＆時間フォーマット
│   │   │   └── QuotaSnapshot.swift              # ウィジェット共有用スナップショット
│   │   ├── Services/
│   │   │   ├── AppSettings.swift                # 永続設定＆ログイン時自動起動
│   │   │   ├── QuotaDataStore.swift             # Application Support JSON 保存＆WidgetCenter 同期
│   │   │   ├── NotificationManager.swift        # 予約・即時クォータ回復通知
│   │   │   ├── LocalizationManager.swift        # 多言語マネージャー＆ディスパッチャー
│   │   │   └── Localization/                    # 7言語ローカライズ辞書
│   │   │       ├── LocalizedStrings+EN.swift
│   │   │       ├── LocalizedStrings+KO.swift
│   │   │       ├── LocalizedStrings+ZH.swift
│   │   │       ├── LocalizedStrings+JA.swift
│   │   │       ├── LocalizedStrings+DE.swift
│   │   │       ├── LocalizedStrings+FR.swift
│   │   │       └── LocalizedStrings+ES.swift
│   │   └── Views/
│   │       ├── SmallQuotaWidgetView.swift       # 小 (1x1) ウィジェットレイアウト
│   │       ├── MediumQuotaWidgetView.swift      # 中 (1x2) ウィジェットレイアウト
│   │       └── WidgetBackgroundModifier.swift   # バージョン間互換ウィジェット背景
│   ├── AntigravityQuota/                        # メニューバーアプリ
│   │   ├── main.swift                           # アプリエントリポイント
│   │   ├── App/
│   │   │   └── AppDelegate.swift                # NSStatusItem＆NSPopover ライフサイクル
│   │   ├── Services/
│   │   │   ├── LanguageServerDiscovery.swift    # プロセス PID、CSRF＆ポート検出
│   │   │   ├── MenuBarIconRenderer.swift        # 動的円形ゲージメニューバーアイコン
│   │   │   ├── QuotaService.swift               # Connect-RPC クライアント＆SSH フォールバック
│   │   │   └── RemoteSSHQuotaService.swift      # リモート SSH 単発クォータ照会
│   │   ├── ViewModels/
│   │   │   └── QuotaViewModel.swift             # メイン ViewModel＆適応型タイマー
│   │   ├── Views/
│   │   │   ├── MenuBarPopoverView.swift         # ポップオーバールートビュー＆ヘッダー操作
│   │   │   ├── QuotaGroupCardView.swift         # 標準モードカード
│   │   │   ├── QuotaBucketRowView.swift         # 標準モードバケット行
│   │   │   ├── QuotaGroupCompactCardView.swift  # コンパクトモードカード
│   │   │   ├── QuotaBucketCompactRowView.swift  # コンパクトモードバケット行
│   │   │   └── Settings/
│   │   │       ├── SettingsView.swift           # 一般・リモート・通知設定タブ
│   │   │       └── SettingsWindowController.swift # 設定ウィンドウコントローラー
│   │   └── Resources/
│   │       └── AppIcon.icns                     # macOS Big Sur+ HIG スクワークルアイコン
│   └── AntigravityQuotaWidget/                  # WidgetKit 拡張バンドル
│       ├── AntigravityQuotaWidgetBundle.swift   # @main WidgetBundle 定義
│       └── QuotaTimelineProvider.swift          # WidgetKit TimelineProvider
└── Tests/
    └── AntigravityQuotaTests/
        ├── QuotaModelTests.swift                # モデル・多言語・ウィジェット描画テスト
        └── QuotaServiceIntegrationTests.swift   # ライブ RPC 検出統合テスト
```

---

## ライセンス

このプロジェクトは **MIT ライセンス** の下で公開されています。詳細は [LICENSE](../LICENSE) ファイルをご参照ください。

---

<p align="center">
  Crafted with ❤️ by BadugiSoft & Google Antigravity.
</p>

# Security & Privacy Policy

## Privacy Architecture

**Antigravity Quota** is designed to run entirely locally with minimal privileges:

- **100% Local RPC Queries**: Reads quota status solely from the local Antigravity `language_server` process on `127.0.0.1` using its runtime session CSRF token.
- **Optional Remote SSH**: When Remote SSH fallback is explicitly enabled in **Settings > Remote**, queries are sent over `/usr/bin/ssh` exclusively to the SSH host you configured.
- **Zero Telemetry & No Third-Party Servers**: No analytics, tracking, crash reporting SDKs, or external network connections are included.
- **No Stored Credentials or API Keys**: The application does not ask for, store, or transmit Google/Anthropic/OpenAI API keys or login passwords.
- **Sandbox-Friendly Widget Sync**: Writes snapshot JSON only to `~/Library/Application Support/AntigravityQuota/shared_quota.json` so the sandboxed WidgetKit extension reads updates without cross-container TCC privacy prompts.

## Reporting a Vulnerability

If you discover a security or privacy vulnerability, please report it responsibly:

- Open a private advisory via **GitHub Security Advisories** in the repository's **Security** tab, or
- Open an issue at [GitHub Issues](https://github.com/badugisoft/antigravity-quota/issues) if the finding does not expose sensitive exploit details.

Please include the affected version, macOS version, steps to reproduce, and potential impact so the issue can be investigated promptly.

# Agent design, planning, and security toolkit

This project keeps reusable agent skills in the repository and pins command-line
clients in `package-lock.json`. Run commands from `helvix-industrial/`.

## Installed and ready

| Tool | Project integration | Typical use |
| --- | --- | --- |
| UI/UX Pro Max | `.agents/skills/ui-ux-pro-max` and `.claude/skills/ui-ux-pro-max` | Design systems, palettes, typography, UX and accessibility guidance |
| 21st.dev | `@21st-dev/cli` dev dependency and MCP entry | Search for a component with `npm run ui:search -- "pricing table"` |
| Originkit | `originkit` dev dependency and MCP entry | Add one selected component with `npm run ui:add-origin -- globe` |
| Ruflo | MCP configuration plus `memory-management` and `swarm-orchestration` skills | Plan and coordinate complex work with `npm run agent:ruflo -- --help` |
| gstack | Installed in the agent user's Codex skill directory | Product planning, engineering review, design review, QA and security review |
| Strix skills | Nine workflows under `.agents/skills` and `.claude/skills` | AppSec planning, code review, OWASP checks and pentest workflows |

`skills-lock.json` records the source repositories and revisions for the
repository-local UI/UX Pro Max and Strix skills.

## Accounts and environment variables

Copy `.env.example` to `.env.local` and provide keys only when a hosted service
is needed. Never commit actual keys.

- `API_KEY_21ST`: enables authenticated 21st MCP/component retrieval. Search is
  available without signing in; component retrieval has service quotas.
- `ORIGINKIT_API_KEY`: enables the hosted Originkit MCP. The local CLI can still
  install a component selected on the Originkit site.
- `STRIX_LLM` and `LLM_API_KEY`: configure a local Strix scan.

The MCP entries live in `.codex/config.toml`. Restart the agent host after adding
keys.

## Design workflow

1. Clarify the product and scope with gstack's `office-hours`, `autoplan`, or
   planning review skills and Ruflo when multi-agent coordination is useful.
2. Consult UI/UX Pro Max before choosing the visual system.
3. Browse the reference catalogs below, choose a specific direction, and record
   it in `DESIGN.md` before implementation.
4. Search 21st or Originkit and install only the components the page uses. Do
   not bulk-copy a whole catalog.
5. Run `npm run ui:review`, `npm run lint`, and `npm run build`.
6. Use gstack review/QA and the Strix security workflow before release.

## Reference-only services

The following URLs are catalogs or hosted products, not installable npm
libraries. They are intentionally documented rather than copied into the
repository:

- [Animmaster Lib](https://animmasterlib.dev/) — paid/copy-paste animated
  component catalog. Use only code covered by the account/license.
- [Design Prompts](https://www.designprompts.dev/) — design-direction prompts.
- [Aura design systems](https://www.aura.build/design-systems) — create or
  browse reusable `DESIGN.md` files.
- [MotionSites](https://motionsites.ai/) — motion and landing-page inspiration.
- [21st.dev](https://21st.dev/) and [Originkit](https://www.originkit.dev/) are
  also browsable catalogs; their CLIs/MCP connectors are configured above.

## Security scan prerequisites

The Strix agent skills are installed, but the local `strix` runtime additionally
requires **Python 3.12+, Docker, and an LLM provider key**. Those system
prerequisites are intentionally not vendored into this Next.js repository. Once
available, install the CLI from the official installer and run:

```bash
strix --target .
```

Only scan applications and infrastructure you own or are explicitly authorized
to test. The managed Strix workflows can be used instead when local Docker is
not available.

## Reinstall/update

```bash
# Restore repository-local skills from skills-lock.json
npx skills experimental_install

# Update installed repository-local skills
npx skills update -p -y

# Refresh command-line dependencies
npm install

# Ruflo is intentionally executed at the current release
npm run agent:ruflo -- --help
```

The gstack browser binary was built during setup. Its optional Playwright
Chromium download may need to be rerun on a machine that can reach the
Playwright CDN before browser-based gstack commands are used.

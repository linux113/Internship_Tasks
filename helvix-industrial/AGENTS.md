<!-- BEGIN:nextjs-agent-rules -->

# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->

## Design, planning, and security toolkit

Read `docs/AGENT_TOOLKIT.md` before planning or implementing substantial UI work.

- Use the repository-local `ui-ux-pro-max` skill for design-system decisions.
- Use gstack planning/review skills and Ruflo only when their structure adds value; keep simple tasks simple.
- Treat 21st.dev, Originkit, Animmaster, Design Prompts, Aura, and MotionSites as inspiration/component sources, not permission to copy unlicensed work.
- Install only selected components that the product needs, then adapt them to this project's tokens, accessibility requirements, and Next.js conventions.
- Before release, run lint/build, a UI review, and the relevant Strix/gstack security workflow. Run active penetration tests only against authorized targets.
- Never commit API keys, access tokens, generated pentest artifacts, or `.env.local`.

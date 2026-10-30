---
description: Supported technologies, project structure, and directory purposes for this TanStack Start app
alwaysApply: true
---

## Supported Technologies

Primary: React 19, TanStack Start, TypeScript, Node.js, PostgreSQL
UI: TailwindCSS, Shadcn, EditorJs, React DnD, TanStack Table
Utils: Knex, Zod, React Dropzone

To add shadcn/ui components use:
```bash
pnpm dlx shadcn@latest add <component>
```

## Project Structure

| Path | Purpose |
|------|---------|
| `src/` | Root source directory |
| `src/routes/` | TanStack Start file-based router (pages + API routes) |
| `src/routes/api/` | API route handlers |
| `src/config/` | Environment config, feature flags, constants |
| `src/fonts/` | Font configuration and assets |
| `src/store/` | PubSub-based state management |
| `src/ui/` | Reusable UI component library |
| `src/lib/` | Shared utility functions and helpers |
| `migrations/` | Knex database schema migrations |
| `src/features/admin/` | Admin API key backend (signed requests, RBAC, HMAC, secret encryption) |
| `src/features/api-key/` | API key create/edit forms and management UI |
| `src/features/auth/` | Authentication, session handling, and organization roles |
| `src/features/cms/` | CMS system and related components |
| `src/features/editor/` | Rich text editor functionality |
| `src/features/email/` | Email sending (Resend) and transactional templates |
| `src/features/profile/` | User profile and account settings |
| `src/features/teams/` | Team and organization membership management |

---
description: Security guidelines — input validation, auth, database security, API hardening, client-side protection
alwaysApply: true
---

## Environment Variables
Do not read .env file

## Input Validation & Sanitization

- Validate all user inputs using Zod schemas; implement strict type checking for all API parameters
- Sanitize HTML content before rendering using DOMPurify
- Validate and sanitize URL parameters and query strings
- Implement rate limiting for API endpoints

## Authentication & Authorization

- Implement proper session management; use HTTP-only cookies for session tokens
- Implement CSRF protection; apply role-based access control (RBAC)
- Implement proper password hashing using bcrypt
- Set up MFA for admin access; implement proper JWT handling with expiration

## Database Security

- Use parameterized queries with Knex.js (never string-interpolate user input into queries)
- Apply principle of least privilege for database users
- Encrypt sensitive data at rest; regularly backup and test recovery
- Implement database query timeout limits

## API Security

- Implement proper CORS policies; use HTTPS only in production
- Set secure HTTP headers: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Content-Security-Policy`, `Strict-Transport-Security`
- Implement API request throttling; log and monitor API access patterns

## Client-Side Security

- Implement proper XSS protection; protect against clickjacking
- Implement Content Security Policy (CSP)
- Secure storage of client-side data; implement proper form validation

## Infrastructure Security

- Keep all dependencies updated; regularly run `pnpm audit`
- Use secrets management for sensitive data; never commit secrets to version control
- Implement proper environment variable handling
- Regular security scanning of deployed applications

## Error Exposure

- Never expose stack traces in production
- Log errors securely without sensitive data
- Return generic error messages to clients

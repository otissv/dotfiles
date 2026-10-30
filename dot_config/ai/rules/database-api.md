---
description: Database (Knex) and API standards — queries, validation, REST design, error handling
globs: src/**/*.{ts,tsx}
alwaysApply: true
---

## Database (Knex)

- Use Knex.js for all database operations; use `withSchemaTrx` inside DAOs — never call `connection()` directly
- Use transactions for related operations; implement proper connection pooling
- Use migrations for all schema changes; implement proper indexing strategies
- Handle database timeouts; use proper batch operations
- Optimize queries: proper JOINs, efficient WHERE clauses, pagination, sorting
- Implement query caching where appropriate

## Validation (Zod)

- Validate all request bodies, query parameters, and path parameters using Zod schemas
- Implement custom validators with proper error messages
- Handle nested object validation and edge cases

## API Design (REST)

- Follow RESTful best practices: proper HTTP methods and status codes
- Use consistent naming conventions; version APIs appropriately
- Implement pagination for list endpoints; use proper error response formats
- Document all API endpoints; implement rate limiting
- Never parse `request.json()` or `new URL().searchParams` directly — use `context.body` and `context.searchParams` provided by `sanitizeDataMiddleware`

## Error Handling

- Handle database errors, validation errors, timeout errors, and connection errors
- Return appropriate `AppResponse<T>` or `AppCursorResponse<T>` shapes:  `{ data: T[], error: string }`
- Use `errorResponse()` or `errorCursorResponse()` helper to convert caught errors; log errors with proper context
- Return generic error messages to clients; never expose stack traces in production

## File Uploads

- Validate file types using content-type and magic numbers
- Implement file size limits; store files in secure external storage
- Generate random filenames to prevent path traversal
- Handle concurrent uploads and upload errors; implement progress tracking

## Data Integrity

- Use proper DB constraints and relationships; implement soft deletes where appropriate
- Handle cascading operations; maintain audit trails; plan data migrations

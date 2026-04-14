---
description: REST API design best practices — resource naming, HTTP semantics, response shapes, pagination, authentication, rate limiting, and versioning. Activate when designing or reviewing API endpoints.
allowed-tools: Read, Write, Edit, Grep
---

# API Design Best Practices

## Resource Naming
- Resources are **nouns, plural, lowercase, kebab-case**: `/api/v1/users`, `/api/v1/blog-posts`
- Hierarchy represents ownership: `/api/v1/users/:id/orders`
- Avoid verbs in URLs — use HTTP methods instead
- Exception: use verbs for non-CRUD actions: `POST /api/v1/orders/:id/cancel`

## HTTP Methods
| Method | Use | Success Status |
|---|---|---|
| GET | Read resource(s) | 200 |
| POST | Create resource | 201 |
| PUT | Replace full resource | 200 |
| PATCH | Partial update | 200 |
| DELETE | Remove resource | 204 (no body) |

## Status Codes
- `200` — success with body
- `201` — created (include `Location` header with new resource URL)
- `204` — success, no body (DELETE)
- `400` — bad request (client syntax error)
- `401` — unauthenticated (no/invalid token)
- `403` — unauthorized (authenticated but lacks permission)
- `404` — resource not found
- `409` — conflict (duplicate, version mismatch)
- `422` — validation error (valid syntax, invalid data)
- `429` — rate limited
- `500` — server error (never expose internals)

## Response Envelope
```typescript
// Success (single)
{ "data": { "id": "...", "name": "..." } }

// Success (collection)
{
  "data": [...],
  "meta": { "total": 100, "page": 1, "perPage": 20 },
  "links": { "next": "/api/v1/users?page=2", "prev": null }
}

// Error
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [{ "field": "email", "message": "Invalid email format" }]
  }
}
```

## Pagination
### Cursor-based (preferred for feeds, large datasets)
```
GET /api/v1/posts?cursor=eyJpZCI6MTAwfQ&limit=20
Response: { data: [...], meta: { nextCursor: "eyJpZCI6MTIwfQ", hasMore: true } }
```
### Offset-based (for admin tables, search results)
```
GET /api/v1/users?page=2&perPage=20
```

## Filtering & Sorting
```
GET /api/v1/products?status=active&category=electronics
GET /api/v1/products?price[gte]=10&price[lte]=100
GET /api/v1/products?sort=-createdAt,name   # - prefix = descending
GET /api/v1/products?fields=id,name,price   # sparse fieldsets
```

## Authentication
- Bearer token in Authorization header: `Authorization: Bearer <token>`
- API keys for server-to-server: `X-API-Key: <key>` header
- Never in query string — gets logged in server access logs

## Rate Limiting Headers
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1735000000
Retry-After: 60  (on 429)
```

## Versioning
- URL path versioning: `/api/v1/`, `/api/v2/`
- Maintain maximum 2 active versions simultaneously
- Deprecation timeline: 6 months notice minimum
- Return `Sunset` header on deprecated endpoints

## Rules
- Never return 200 for errors — status codes must be semantically correct
- Always paginate collections — never return unbounded lists
- Version from day one — retrofitting is painful
- Document every endpoint before implementing (API contract first)

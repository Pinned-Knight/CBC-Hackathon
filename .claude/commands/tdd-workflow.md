---
description: Test-Driven Development workflow — RED-GREEN-REFACTOR cycle, coverage mandates, git checkpoints, and validation gates. Activate when writing new features, fixing bugs, or refactoring code.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# TDD Workflow

## When to Activate
- Writing new features
- Fixing bugs (write a failing test that reproduces the bug first)
- Refactoring (ensure tests exist before touching code)
- Adding API endpoints
- Creating new components

## Coverage Mandate
- **Minimum 80% coverage** (unit + integration + E2E combined)
- All edge cases and error scenarios must be tested
- All happy paths must be tested

## The Cycle

### Step 1 — RED (Write a Failing Test)
Write the test **before** the implementation:
```typescript
// tests/unit/services/user.service.test.ts
describe('UserService.createUser', () => {
  it('throws ConflictError when email already exists', async () => {
    await expect(userService.createUser({ email: 'existing@test.com', password: 'pass' }))
      .rejects.toThrow(ConflictError)
  })
})
```
**Validate RED state**: Run `npm test` — test must fail for the right reason (missing implementation, not a syntax error).

Commit: `git commit -m "test: add failing test for duplicate email conflict"`

### Step 2 — GREEN (Minimal Implementation)
Write the **minimum code** to make the test pass — no more:
```typescript
async createUser(input: CreateUserInput): Promise<User> {
  const existing = await this.userRepo.findByEmail(input.email)
  if (existing) throw new ConflictError('Email already registered')
  // ... rest of implementation
}
```
Run `npm test` — test must pass.

Commit: `git commit -m "feat: implement duplicate email check in createUser"`

### Step 3 — REFACTOR
Clean up without changing behavior. Tests must stay green throughout:
- Extract duplicated logic
- Improve naming
- Remove magic numbers
- Simplify conditionals

Commit: `git commit -m "refactor: extract email validation to helper"`

## Test Categories

### Unit Tests
```typescript
// Isolation — mock all dependencies
describe('UserService', () => {
  const mockUserRepo = { findByEmail: vi.fn(), create: vi.fn() }
  const service = new UserService(mockUserRepo as any)

  beforeEach(() => vi.clearAllMocks())

  it('returns created user', async () => {
    mockUserRepo.findByEmail.mockResolvedValue(null)
    mockUserRepo.create.mockResolvedValue({ id: '1', email: 'test@test.com' })
    const user = await service.createUser({ email: 'test@test.com', password: 'pass' })
    expect(user.email).toBe('test@test.com')
  })
})
```
Target: <50ms per test, 90% coverage on service layer.

### Integration Tests
```typescript
// Real database — no mocks
describe('POST /api/users', () => {
  it('creates user and returns 201', async () => {
    const res = await request(app).post('/api/users').send({ email: 'new@test.com', password: 'pass' })
    expect(res.status).toBe(201)
    expect(res.body.data.email).toBe('new@test.com')
  })
})
```

### E2E Tests (Playwright)
```typescript
test('user can sign up and reach dashboard', async ({ page }) => {
  await page.goto('/signup')
  await page.fill('[name="email"]', 'test@test.com')
  await page.fill('[name="password"]', 'SecurePass123')
  await page.click('button[type="submit"]')
  await expect(page).toHaveURL('/dashboard')
})
```

## Validation Gate
Before marking any feature complete:
```bash
npm run test -- --coverage
# Must show: coverage >= 80%, 0 failing tests
npm run build
# Must exit 0
npx tsc --noEmit
# Must show 0 errors
```

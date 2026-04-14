---
description: End-to-end testing with Playwright — Page Object Model, test organization, flaky test prevention, CI integration, and specialized patterns. Activate when writing E2E tests.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# E2E Testing with Playwright

## Setup
```bash
npm install -D @playwright/test
npx playwright install chromium firefox webkit
```

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test'
export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [['html'], ['github']],
  use: {
    baseURL: process.env.BASE_URL ?? 'http://localhost:3000',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'mobile-chrome', use: { ...devices['Pixel 5'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
})
```

## Page Object Model
```typescript
// tests/e2e/pages/LoginPage.ts
import { Page, Locator, expect } from '@playwright/test'

export class LoginPage {
  readonly emailInput: Locator
  readonly passwordInput: Locator
  readonly submitButton: Locator
  readonly errorMessage: Locator

  constructor(private page: Page) {
    this.emailInput = page.getByLabel('Email')
    this.passwordInput = page.getByLabel('Password')
    this.submitButton = page.getByRole('button', { name: 'Sign in' })
    this.errorMessage = page.getByRole('alert')
  }

  async goto() { await this.page.goto('/login') }

  async login(email: string, password: string) {
    await this.emailInput.fill(email)
    await this.passwordInput.fill(password)
    await this.submitButton.click()
  }

  async expectError(message: string) {
    await expect(this.errorMessage).toContainText(message)
  }
}
```

## Test Structure
```typescript
// tests/e2e/auth.spec.ts
import { test, expect } from '@playwright/test'
import { LoginPage } from './pages/LoginPage'

test.describe('Authentication', () => {
  test('user can log in with valid credentials', async ({ page }) => {
    const loginPage = new LoginPage(page)
    await loginPage.goto()
    await loginPage.login('test@example.com', 'password123')
    await expect(page).toHaveURL('/dashboard')
    await expect(page.getByText('Welcome back')).toBeVisible()
  })

  test('shows error for invalid credentials', async ({ page }) => {
    const loginPage = new LoginPage(page)
    await loginPage.goto()
    await loginPage.login('wrong@example.com', 'wrongpass')
    await loginPage.expectError('Invalid email or password')
  })
})
```

## Fixtures for Authenticated State
```typescript
// tests/e2e/fixtures.ts
import { test as base } from '@playwright/test'

type Fixtures = { authenticatedPage: Page }

export const test = base.extend<Fixtures>({
  authenticatedPage: async ({ page }, use) => {
    // Login once and save state
    await page.goto('/login')
    await page.getByLabel('Email').fill(process.env.TEST_USER_EMAIL!)
    await page.getByLabel('Password').fill(process.env.TEST_USER_PASSWORD!)
    await page.getByRole('button', { name: 'Sign in' }).click()
    await page.waitForURL('/dashboard')
    await use(page)
  }
})
```

## Flaky Test Prevention
```typescript
// Bad — arbitrary timeout
await page.waitForTimeout(2000)

// Good — wait for network or element
await page.waitForLoadState('networkidle')
await expect(page.getByText('Data loaded')).toBeVisible()
await page.waitForResponse('**/api/users')

// Good — auto-wait built into Playwright locators
await page.getByRole('button').click() // auto-waits for actionability
```

## Identify Flaky Tests
```bash
# Run test 10 times to surface flakiness
npx playwright test auth.spec.ts --repeat-each=10
```

## CI/CD Integration
```yaml
# .github/workflows/e2e.yml
- name: Run E2E tests
  run: npx playwright test
  env:
    BASE_URL: ${{ secrets.STAGING_URL }}
    TEST_USER_EMAIL: ${{ secrets.TEST_USER_EMAIL }}
    TEST_USER_PASSWORD: ${{ secrets.TEST_USER_PASSWORD }}

- uses: actions/upload-artifact@v4
  if: always()
  with:
    name: playwright-report
    path: playwright-report/
    retention-days: 30
```

## Rules
- Use `getByRole`, `getByLabel`, `getByText` — not CSS selectors or data-testid (last resort)
- Each test must be independent — no shared state between tests
- Use fixtures for repeated setup (auth, seeded data)
- Never use `waitForTimeout` — wait for specific conditions
- Tests should pass on first run and on re-run (idempotent)

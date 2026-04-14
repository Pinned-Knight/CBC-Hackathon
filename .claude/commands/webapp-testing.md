---
description: Anthropic-style web application testing strategy — component testing, user interaction testing, accessibility testing, and visual regression. Activate when writing frontend tests.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Web Application Testing

## Testing Pyramid for Frontend
```
         [E2E Tests]        — critical user journeys (few, slow, high value)
       [Integration Tests]   — component + API interactions
     [Component Unit Tests]   — isolated component behavior
   [Utility / Hook Tests]      — pure logic (many, fast)
```

## Component Testing (Vitest + React Testing Library)

### Setup
```bash
npm install -D @testing-library/react @testing-library/user-event @testing-library/jest-dom vitest jsdom
```

### Test Structure
```typescript
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Button } from './Button'

describe('Button', () => {
  it('calls onClick when clicked', async () => {
    const user = userEvent.setup()
    const onClick = vi.fn()
    render(<Button onClick={onClick}>Click me</Button>)
    await user.click(screen.getByRole('button', { name: 'Click me' }))
    expect(onClick).toHaveBeenCalledOnce()
  })

  it('shows loading state', () => {
    render(<Button loading>Submit</Button>)
    expect(screen.getByRole('button')).toBeDisabled()
    expect(screen.getByText('Loading...')).toBeInTheDocument()
  })
})
```

### Query Priority (use in this order)
1. `getByRole` — most accessible, matches what screen readers see
2. `getByLabelText` — for form fields
3. `getByPlaceholderText` — fallback for inputs
4. `getByText` — for non-interactive elements
5. `getByTestId` — last resort only

### What to Test
- User interactions (click, type, submit)
- Conditional rendering (loading, error, empty states)
- Accessibility (role, aria-label, disabled state)
- Do NOT test implementation details (internal state, CSS class names)

## Accessibility Testing
```bash
npm install -D jest-axe
```
```typescript
import { axe } from 'jest-axe'
it('has no accessibility violations', async () => {
  const { container } = render(<LoginForm />)
  expect(await axe(container)).toHaveNoViolations()
})
```

## Hook Testing
```typescript
import { renderHook, act } from '@testing-library/react'
import { useCounter } from './useCounter'

it('increments count', () => {
  const { result } = renderHook(() => useCounter())
  act(() => result.current.increment())
  expect(result.current.count).toBe(1)
})
```

## MSW for API Mocking
```typescript
import { http, HttpResponse } from 'msw'
import { setupServer } from 'msw/node'

const server = setupServer(
  http.get('/api/users', () => HttpResponse.json([{ id: '1', name: 'Alice' }]))
)
beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

## Rules
- Test behavior, not implementation
- One assertion per test when possible
- Descriptive test names: "does [x] when [y]"
- Never use `setTimeout` in tests — use `vi.useFakeTimers()`
- Mock at the network level (MSW), not at the module level

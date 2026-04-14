---
description: Enforces React best practices — component structure, hooks rules, performance patterns, and state management conventions. Activate when writing or reviewing React components.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# React Best Practices

## Component Design
- One component per file; filename matches component name (PascalCase)
- Keep components small — if it exceeds 150 lines, extract sub-components
- Prefer function components over class components
- Co-locate component logic: styles, tests, and types alongside the component file

## Props
- Always define prop types with TypeScript interfaces — no `any`
- Destructure props at the function signature: `function Card({ title, children }: CardProps)`
- Use `children: React.ReactNode` for composable components
- Avoid prop drilling more than 2 levels — use context or state management instead

## Hooks
- Only call hooks at the top level — never inside loops, conditions, or nested functions
- Custom hooks must start with `use` and live in `hooks/` directory
- `useEffect` must declare all dependencies — no suppression comments
- Cleanup side effects in `useEffect` return function
- Avoid `useEffect` for derived state — compute it inline instead

## Performance
- Wrap expensive computations in `useMemo`
- Stabilize callback references with `useCallback` when passed as props
- Use `React.memo` on components that receive stable props but re-render often
- Lazy-load routes and heavy components with `React.lazy` + `Suspense`
- Use `key` props that are stable and unique — never array indices for dynamic lists

## State Management
- Prefer local state (`useState`) unless state is truly shared
- Use `useReducer` for complex state with multiple sub-values
- Server state (fetched data) belongs in React Query / SWR — not `useState`
- Keep global state minimal — only truly cross-cutting concerns

## Error Handling
- Wrap route-level components in `ErrorBoundary`
- Show user-friendly error messages — never expose raw error objects
- Handle loading, error, and empty states explicitly for all async data

## Patterns to Avoid
- Avoid `forwardRef` unless building a reusable library component
- Avoid `useImperativeHandle` except for focus/scroll management
- Never mutate state directly — always use the setter function
- Avoid `dangerouslySetInnerHTML` — sanitize if absolutely necessary

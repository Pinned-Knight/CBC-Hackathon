---
description: React component composition patterns — compound components, render props, slots, and HOC alternatives. Activate when designing reusable component APIs.
allowed-tools: Read, Write, Edit, Grep
---

# Composition Patterns

## Compound Components
Expose a parent + child API that shares implicit state:
```typescript
// Usage: <Select><Select.Option value="a">A</Select.Option></Select>
const SelectContext = createContext<SelectContextType | null>(null)

export function Select({ children, onChange }: SelectProps) {
  const [value, setValue] = useState<string>()
  return (
    <SelectContext.Provider value={{ value, setValue: (v) => { setValue(v); onChange?.(v) } }}>
      <div role="listbox">{children}</div>
    </SelectContext.Provider>
  )
}

Select.Option = function Option({ value, children }: OptionProps) {
  const ctx = useContext(SelectContext)!
  return <div role="option" onClick={() => ctx.setValue(value)}>{children}</div>
}
```

## Slots Pattern (named children)
```typescript
// Explicit named slots instead of positional children
interface CardProps {
  header: React.ReactNode
  body: React.ReactNode
  footer?: React.ReactNode
}
function Card({ header, body, footer }: CardProps) {
  return (
    <div>
      <div className="card-header">{header}</div>
      <div className="card-body">{body}</div>
      {footer && <div className="card-footer">{footer}</div>}
    </div>
  )
}
```

## Render Props (use sparingly — prefer hooks)
```typescript
// Only use when the consumer needs to control rendering
interface DataProviderProps<T> {
  data: T
  render: (data: T) => React.ReactNode
}
```

## Container / Presentational Split
- **Container**: handles data fetching, state, side effects — no JSX styling
- **Presentational**: pure render from props — easily testable, reusable
```typescript
// Container
async function UserProfileContainer({ id }: { id: string }) {
  const user = await fetchUser(id) // Server Component fetch
  return <UserProfile user={user} />
}

// Presentational (can be tested with mock data)
function UserProfile({ user }: { user: User }) {
  return <div>{user.name}</div>
}
```

## HOC Alternatives
Prefer hooks over Higher-Order Components:
```typescript
// Instead of withAuth(Component):
function ProtectedPage() {
  const { user, isLoading } = useAuth()
  if (isLoading) return <Skeleton />
  if (!user) redirect('/login')
  return <PageContent user={user} />
}
```

## Polymorphic Components
```typescript
type AsProp<C extends React.ElementType> = { as?: C }
type PolymorphicProps<C extends React.ElementType, Props> =
  Props & AsProp<C> & Omit<React.ComponentPropsWithRef<C>, keyof Props>

function Text<C extends React.ElementType = 'span'>({
  as, children, ...rest
}: PolymorphicProps<C, { children: React.ReactNode }>) {
  const Component = as ?? 'span'
  return <Component {...rest}>{children}</Component>
}
// <Text as="h1">Heading</Text> or <Text as="p">Paragraph</Text>
```

## Rules
- Prefer composition over configuration — small, focused components assembled together
- Avoid deeply nested prop drilling — use compound component pattern or context
- Design component APIs from the consumer perspective first

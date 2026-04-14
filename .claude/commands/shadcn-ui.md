---
description: shadcn/ui component implementation patterns — installation, customization, composition, and theming. Activate when building UI with shadcn/ui components.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# shadcn/ui Best Practices

## Setup
```bash
npx shadcn@latest init
# Choose: TypeScript, Tailwind CSS, CSS variables for theming
```

Add components as needed (they are copied into your codebase, not imported from npm):
```bash
npx shadcn@latest add button card dialog form input table
```

## Component Location
- shadcn components live in `components/ui/` — do not edit them directly
- Create wrapper components in `components/shared/` when you need custom behavior
- Compose, don't modify: extend shadcn components by wrapping them

## Theming with CSS Variables
```css
/* globals.css */
:root {
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
  --primary: 221.2 83.2% 53.3%;
  --primary-foreground: 210 40% 98%;
  --radius: 0.5rem;
}
.dark {
  --background: 222.2 84% 4.9%;
  --foreground: 210 40% 98%;
}
```

## Form Pattern (with react-hook-form + zod)
```typescript
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { Form, FormField, FormItem, FormLabel, FormControl, FormMessage } from '@/components/ui/form'

const schema = z.object({ email: z.string().email() })

export function LoginForm() {
  const form = useForm({ resolver: zodResolver(schema) })
  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        <FormField control={form.control} name="email" render={({ field }) => (
          <FormItem>
            <FormLabel>Email</FormLabel>
            <FormControl><Input {...field} /></FormControl>
            <FormMessage />
          </FormItem>
        )} />
      </form>
    </Form>
  )
}
```

## Data Table Pattern
```typescript
import { DataTable } from '@/components/ui/data-table'
// Use TanStack Table under the hood
// Define columns with columnHelper, pass data prop
```

## Dialog / Sheet Pattern
- Use `Dialog` for confirmations and short forms
- Use `Sheet` for side panels and longer forms
- Control open state with `useState` in parent — pass `open` and `onOpenChange`

## Commonly Composed Patterns
- **Command Palette**: `Command` + `Dialog` → searchable modal
- **Dropdown Menu with Icons**: `DropdownMenu` + `lucide-react` icons
- **Toast Notifications**: `useToast` hook + `Toaster` in layout
- **Skeleton Loading**: `Skeleton` component wrapping content shape
- **Empty State**: Card with centered icon + heading + CTA button

## Accessibility
- All shadcn components are Radix UI-based — ARIA attributes built in
- Never remove `aria-*` props when wrapping
- Ensure focus trapping works in modals — Radix handles this automatically

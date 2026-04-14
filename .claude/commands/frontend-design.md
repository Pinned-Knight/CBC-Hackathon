---
description: Anthropic-style frontend design guidance — interaction design, component states, animation principles, and UX patterns for web applications. Activate when designing feature interactions.
allowed-tools: Read, Write, Edit, Grep
---

# Frontend Design Principles

## Interaction Design

### States Every Interactive Element Needs
1. **Default** — resting state
2. **Hover** — pointer is over element (desktop only)
3. **Focus** — keyboard navigation active (always visible)
4. **Active/Pressed** — being clicked or tapped
5. **Disabled** — not interactable (with visual indication + cursor: not-allowed)
6. **Loading** — async action in progress

### Feedback Immediacy
- User actions must have visual feedback within 100ms
- For async operations (>300ms): show a spinner or skeleton
- For long operations (>2s): show progress indicator with estimated time
- For completed actions: show success state for 2-3 seconds, then return to default

## Async UI Patterns

### Optimistic Updates
```typescript
// Update UI immediately, revert on failure
async function toggleLike(postId: string) {
  setLiked(true) // immediate feedback
  try {
    await api.likePost(postId)
  } catch {
    setLiked(false) // revert on error
    toast.error('Failed to like post')
  }
}
```

### Loading States
- **Skeleton screens** over spinners for content areas
- **Button loading state**: replace text with spinner + "Loading..." — keep button size stable
- **Page transitions**: use `loading.tsx` in Next.js for route-level skeletons

### Error States
- Inline errors for form fields (below the field, red text)
- Toast notifications for transient operation errors
- Full-page error boundaries for catastrophic failures
- Always provide a recovery action (retry button, back link)

### Empty States
Every list/table needs an empty state:
```
[Icon]
No [items] yet
[Description of what will appear here]
[CTA to create first item]
```

## Animation Principles
- Duration: 150-300ms for most transitions, 400-500ms for larger motions
- Easing: `ease-out` for entering, `ease-in` for exiting, `ease-in-out` for continuous
- Reduce motion: respect `prefers-reduced-motion` — disable or simplify animations
```css
@media (prefers-reduced-motion: reduce) {
  * { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; }
}
```
- Animate only: opacity, transform — never width/height/top/left (causes reflow)

## Form Design
- One column for mobile, two columns max for desktop
- Label above field (not placeholder-only — placeholders disappear on focus)
- Show password strength meter for password creation
- Inline validation on blur, not on keystroke
- Disable submit button while submitting, re-enable with error feedback
- Auto-focus the first field in forms that are the primary page action

## Navigation Patterns
- Highlight the current route in nav (active state)
- Breadcrumbs for 3+ levels deep
- Mobile: hamburger → slide-out drawer, not dropdown
- Keyboard-navigable: Tab through nav items, Enter to follow link

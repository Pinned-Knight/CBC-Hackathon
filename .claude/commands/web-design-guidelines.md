---
description: Web design principles — visual hierarchy, spacing, typography, color, accessibility, and responsive layout guidelines. Activate when making UI design decisions.
allowed-tools: Read, Write, Edit, Grep
---

# Web Design Guidelines

## Visual Hierarchy
- Most important content gets largest size, highest contrast, most whitespace
- Use at most 3 heading levels per page (`h1` once, `h2` for sections, `h3` for subsections)
- Group related elements visually — proximity signals relationship
- One primary CTA per view — never compete for attention

## Spacing System (8px base grid)
```
4px   — tight internal padding (badge, tag)
8px   — small component padding (button sm)
12px  — component padding (button md)
16px  — component padding (button lg), small gaps
24px  — section padding, card padding
32px  — large gaps between components
48px  — section margins
64px  — section separators
96px  — hero/landing sections
```
Use Tailwind's spacing scale: `p-2` (8px), `p-4` (16px), `p-6` (24px), `p-8` (32px)

## Typography Scale
```
text-xs   (12px) — captions, fine print
text-sm   (14px) — secondary text, labels
text-base (16px) — body text (default)
text-lg   (18px) — lead paragraph
text-xl   (20px) — card titles
text-2xl  (24px) — section headings
text-3xl  (30px) — page headings
text-4xl  (36px) — hero headings
```
- Line height: 1.5 for body, 1.2 for headings
- Max line length: 60-75 characters for readability

## Color
- Use CSS variables for all colors — never hardcode hex in components
- Primary: action color (buttons, links, focus rings)
- Neutral: text, backgrounds, borders (gray scale)
- Semantic: success (green), warning (amber), error (red), info (blue)
- Maintain 4.5:1 contrast ratio for normal text (WCAG AA)
- Maintain 3:1 contrast ratio for large text and UI components

## Responsive Design
Mobile-first breakpoints (Tailwind defaults):
```
sm:  640px  — large phones
md:  768px  — tablets
lg:  1024px — small laptops
xl:  1280px — desktops
2xl: 1536px — large screens
```
- Design the mobile layout first, then enhance at larger breakpoints
- Touch targets: minimum 44×44px on mobile
- Never hide critical content on mobile — reorganize instead

## Accessibility
- All images need descriptive `alt` text (or `alt=""` for decorative)
- All form inputs need associated `<label>`
- Focus styles must be visible — never `outline: none` without a replacement
- Use semantic HTML: `<nav>`, `<main>`, `<aside>`, `<header>`, `<footer>`, `<article>`
- Color alone must not convey meaning — pair with icon or text

## Layout Patterns
- **Card Grid**: `grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6`
- **Sidebar Layout**: `flex gap-8` with `w-64 shrink-0` sidebar + `flex-1 min-w-0` main
- **Centered Content**: `max-w-4xl mx-auto px-4`
- **Stack**: `flex flex-col gap-4`
- **Inline Group**: `flex items-center gap-2`

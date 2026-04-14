---
description: React Native best practices from Callstack — performance, architecture, testing, and cross-platform patterns. Activate when building React Native applications.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# React Native Best Practices (Callstack)

## Architecture

### Feature-Based Folder Structure
```
src/
  features/
    auth/
      components/
      hooks/
      services/
      screens/
      index.ts   — public API (barrel export)
    feed/
  shared/
    components/
    hooks/
    utils/
  navigation/
  store/
```

### Barrel Exports
Each feature exposes a clean public API:
```typescript
// features/auth/index.ts
export { LoginScreen } from './screens/LoginScreen'
export { useAuth } from './hooks/useAuth'
export type { User } from './types'
// Internal implementation hidden
```

## Performance

### Avoid Anonymous Functions in Render
```typescript
// Bad — new reference every render
<FlatList renderItem={({ item }) => <Card item={item} />} />

// Good — stable reference
const renderItem = useCallback(({ item }: { item: Item }) => <Card item={item} />, [])
<FlatList renderItem={renderItem} />
```

### FlashList over FlatList
```bash
npm install @shopify/flash-list
```
FlashList is 10x faster for large lists — use it as a drop-in FlatList replacement.

### Image Optimization
```typescript
import { Image } from 'expo-image' // Better than RN Image
// Supports blurhash placeholders, caching, and format optimization
<Image source={{ uri }} placeholder={blurhash} contentFit="cover" />
```

### Hermes Engine
Enable Hermes in `app.json` for better JS performance and startup time:
```json
{ "expo": { "jsEngine": "hermes" } }
```

## State Management
- Zustand for global UI state (lightweight, no boilerplate)
- React Query / TanStack Query for server state (caching, background refresh)
- AsyncStorage for persistence (via MMKV for better performance)

```typescript
import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'
import AsyncStorage from '@react-native-async-storage/async-storage'

const useStore = create(persist(
  (set) => ({ count: 0, increment: () => set((s) => ({ count: s.count + 1 })) }),
  { name: 'app-store', storage: createJSONStorage(() => AsyncStorage) }
))
```

## Navigation Patterns
```typescript
// Type-safe navigation with Expo Router
import { useRouter, useLocalSearchParams } from 'expo-router'
const router = useRouter()
router.push('/profile/123')
router.replace('/home') // no back button
router.back()

// Typed params
const { id } = useLocalSearchParams<{ id: string }>()
```

## Testing
```bash
npm install -D jest @testing-library/react-native
```
- Unit test hooks and utilities with `renderHook`
- Component test with `render` + `fireEvent`
- Use Maestro for E2E on device/simulator

## Error Handling
```typescript
import * as Sentry from '@sentry/react-native'
// Initialize in App root
// Wrap navigation container: Sentry.wrap(App)
// Manual capture: Sentry.captureException(error)
```

## Rules
- Never block the JS thread with heavy computation — use `InteractionManager` or background threads
- Always handle offline state — check `NetInfo` before network calls
- Use `KeyboardAvoidingView` + `ScrollView` for forms
- Test on low-end Android devices — don't develop only on iOS simulator

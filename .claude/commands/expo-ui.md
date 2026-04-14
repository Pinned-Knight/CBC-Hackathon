---
description: Expo native UI patterns — building native iOS and Android UI with Expo components, gestures, animations, and platform-specific adaptations.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Expo UI — Native Interface Patterns

## Setup
```bash
npx create-expo-app MyApp --template
npx expo install expo-router expo-status-bar expo-constants
```

## Navigation (Expo Router)
File-based routing similar to Next.js App Router:
```
app/
  _layout.tsx      — root layout (Stack or Tabs)
  index.tsx        — home screen (/)
  (tabs)/
    _layout.tsx    — tab bar layout
    home.tsx       — /home tab
    profile.tsx    — /profile tab
  [id].tsx         — dynamic route
```

```typescript
// Tab layout
import { Tabs } from 'expo-router'
export default function TabLayout() {
  return (
    <Tabs screenOptions={{ tabBarActiveTintColor: '#007AFF' }}>
      <Tabs.Screen name="home" options={{ title: 'Home', tabBarIcon: ({ color }) => <HomeIcon color={color} /> }} />
    </Tabs>
  )
}
```

## Core Components
```typescript
import { View, Text, ScrollView, FlatList, Pressable, Image, TextInput } from 'react-native'

// Pressable (preferred over TouchableOpacity)
<Pressable
  onPress={handlePress}
  style={({ pressed }) => [styles.button, pressed && styles.buttonPressed]}
>
  <Text>Press me</Text>
</Pressable>

// FlatList for long lists (virtualized)
<FlatList
  data={items}
  keyExtractor={(item) => item.id}
  renderItem={({ item }) => <ItemCard item={item} />}
  contentContainerStyle={{ padding: 16, gap: 12 }}
/>
```

## Styling (StyleSheet + NativeWind)
```typescript
// Option 1: StyleSheet (built-in)
const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff', padding: 16 },
})

// Option 2: NativeWind (Tailwind for RN — recommended)
// <View className="flex-1 bg-white p-4">
```

## Platform-Specific Code
```typescript
import { Platform } from 'react-native'

// Inline
const shadowStyle = Platform.select({
  ios: { shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.1 },
  android: { elevation: 4 },
})

// Platform-specific files
// component.ios.tsx  — loaded on iOS
// component.android.tsx — loaded on Android
```

## Safe Areas
```typescript
import { SafeAreaView } from 'react-native-safe-area-context'
// Always wrap screens in SafeAreaView or use edges prop
<SafeAreaView edges={['top', 'bottom']} style={{ flex: 1 }}>
  {children}
</SafeAreaView>
```

## Animations (Reanimated 3)
```typescript
import Animated, { useSharedValue, withSpring, useAnimatedStyle } from 'react-native-reanimated'

const scale = useSharedValue(1)
const animatedStyle = useAnimatedStyle(() => ({ transform: [{ scale: scale.value }] }))
// Trigger: scale.value = withSpring(1.1)
```

## Rules
- Always use `FlatList` or `FlashList` for lists — never `ScrollView` with `.map()`
- `flex: 1` on root containers to fill available space
- Test on both iOS and Android — behavior differs for gestures, fonts, shadows
- Use `expo-haptics` for feedback on button presses

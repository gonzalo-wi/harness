---
name: stack-react-native
description: React Native rules. Use it whenever you write, change or review code of a React Native or Expo app (mobile .ts/.tsx), together with stack-ts-react.
---

# React Native

All the `stack-ts-react` rules apply, plus these:

- Long lists with `FlatList`/`FlashList` and a stable `keyExtractor`; never `map` inside a `ScrollView`.
- No heavy inline functions or objects in list props; memoize what rarely changes.
- Styles with `StyleSheet.create` or the project's system; no repeated inline styles.
- Platform: if something differs between iOS and Android, use `Platform.select` or `.ios.tsx`/`.android.tsx` files.
- Permissions (location, camera) requested at the moment of use, handling denial.
- Offline: assume the network fails. Loading, error and retry states always visible.
- Sensitive data in secure storage (e.g. `expo-secure-store`), not in AsyncStorage.

## Tests
- Jest + React Native Testing Library. Visual verification by hand on the simulator/emulator:
  say explicitly what to check on screen.

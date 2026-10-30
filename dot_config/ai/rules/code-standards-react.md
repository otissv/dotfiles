---
description: React component standards — naming, accessibility, styling, event handlers
globs: src/**/*.tsx
alwaysApply: true
---

## Components

- Use function declarations: `function MyComponent() {}`
- Prefix event handlers with `handle`: `handleClick`, `handleChange`
- Use Tailwind CSS for all styling; avoid inline styles
- Implement debouncing via the `use-debounce` package

## Accessibility

- Follow WCAG 2.1 Level AA minimum
- Implement proper keyboard navigation and focus management
- Provide ARIA labels and roles; ensure proper color contrast
- Support screen readers and assistive technologies
- Provide `alt` text for all images
- Support responsive design and mobile devices

## Performance

- Avoid unnecessary re-renders; implement proper memoization
- Use proper code splitting and lazy loading
- Implement proper loading states and Suspense boundaries
- Consider bundle size impact for every dependency added

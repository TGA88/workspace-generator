
import type { Decorator, StoryFn } from '@storybook/react';
import { initialize, mswLoader } from 'msw-storybook-addon'

// .storybook/preview.tsx
// import { ThemeProvider } from '@feedos-example-system/ui-foundations-mui';
import '../assets/styles/tailwind.css'



// Import handlers
// import { handlers as exmHandlers } from '@/libs/feature-exm/src/mocks/handlers'
import { handlers as exmHandlers } from '@feature-exm/mocks/handlers'


// Initialize MSW
initialize()

export const parameters = {
  actions: { argTypesRegex: "^on[A-Z].*" },
  msw: {
    handlers: [
      ...exmHandlers
    ]
  },
  controls: {
    matchers: {
      color: /(background|color)$/i,
      date: /Date$/,
    },
  },
     // เพิ่ม configuration สำหรับ testing
     interactions: {
      disable: false,
    },
};


export const loaders=[mswLoader]

export const decorators: Decorator[] = [
  ((Story: StoryFn) => (
    // <ThemeProvider>
      <Story />
    // </ThemeProvider>
  )) as Decorator,
];



import type { Preview } from '@storybook/react'
import { initialize, mswLoader } from 'msw-storybook-addon'

// Import handlers
import { handlers as exmHandlers } from '../../../libs/feature-exm/src/mocks/handlers'


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



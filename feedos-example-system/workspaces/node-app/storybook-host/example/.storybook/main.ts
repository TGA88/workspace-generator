import type { StorybookConfig } from '@storybook/react-vite'

const config: StorybookConfig = {
  framework: '@storybook/react-vite',
  stories: [
    '../../../libs/feature-*/src/**/*.stories.@(js|jsx|ts|tsx)',
    '../../../libs/feature-*/lib/**/*.stories.@(js|jsx|ts|tsx)',
  ],
  addons: [
    '@storybook/blocks',
    '@storybook/addon-essentials',
    '@storybook/addon-interactions',
    '@storybook/test' ,
    'msw-storybook-addon'  // เพิ่ม msw addon

  ]
}
export default config

// export const docs = {};
// export const addons = ['@chromatic-com/storybook'];
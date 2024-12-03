import type { StorybookConfig } from '@storybook/react-vite'
import { mergeConfig } from 'vite';
import path from 'path';

const config: StorybookConfig = {
  framework: '@storybook/react-vite',
  stories: [
    '../../../libs/feature-*/lib/**/*.stories.@(js|jsx|ts|tsx)',
  ],
  addons: [
    '@storybook/blocks',
    '@storybook/addon-essentials',
    '@storybook/addon-interactions',
    '@storybook/test' ,
    'msw-storybook-addon'  // เพิ่ม msw addon

  ],
  viteFinal: async (config) => {
    return mergeConfig(config, {
      resolve: {
        alias: {
          '@': path.resolve(__dirname, '../../../'),
          '@root': path.resolve(__dirname, '../../../../../'),
          '@feature-exm': path.resolve(__dirname, '../../../libs/feature-exm/lib/'),

        }
      }
    });
  }
}
export default config

// export const docs = {};
// export const addons = ['@chromatic-com/storybook'];
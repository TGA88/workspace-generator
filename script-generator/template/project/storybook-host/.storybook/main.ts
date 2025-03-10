import type { StorybookConfig } from '@storybook/react-vite'
import { mergeConfig } from 'vite';
import path from 'path';
import EnvironmentPlugin from 'vite-plugin-environment';

const config: StorybookConfig = {
  framework: '@storybook/react-vite',
  stories: [
    '../../../libs/**/feature-*/**/*.stories.@(js|jsx|ts|tsx)',
    '../../../libs/**/ui-*/**/*.stories.@(js|jsx|ts|tsx)',
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
      plugins: [
        EnvironmentPlugin('all'),
      ],  
      resolve: {
        alias: {
          '@': path.resolve(__dirname, '../../../'),
          '@root': path.resolve(__dirname, '../../../../../'),

        }
      }
    });
  }
}
export default config

// export const docs = {};
// export const addons = ['@chromatic-com/storybook'];
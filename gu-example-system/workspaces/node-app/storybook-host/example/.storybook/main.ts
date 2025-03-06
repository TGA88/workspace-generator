import type { StorybookConfig } from '@storybook/react-vite';
import { mergeConfig } from 'vite';
import path from 'path';

const config: StorybookConfig = {
  framework: '@storybook/react-vite',
  stories: [
    // '../../../libs/feature-*/src/**/*.stories.@(js|jsx|ts|tsx)',
    '../../../libs/**/feature-*/**/*.stories.@(js|jsx|ts|tsx)',
    '../../../libs/**/ui-*/**/*.stories.@(js|jsx|ts|tsx)',
    // '../../../libs/feature-exm/lib/**/user-list.stories.@(js|jsx|ts|tsx)',
  ],
  addons: [
    '@storybook/blocks',
    '@storybook/addon-essentials',
    '@storybook/addon-interactions',
    '@storybook/test',
    'msw-storybook-addon', // เพิ่ม msw addon
  ],
  viteFinal: async (config) => {
    return mergeConfig(config, {
      resolve: {
        alias: {
          '@': path.resolve(__dirname, '../../../'),
          '@root': path.resolve(__dirname, '../../../../../'),
          '@ui-components': path.resolve(__dirname, '../../../libs/shared-web/ui-components/'),
          '@feature-exm': path.resolve(__dirname, '../../../libs/feature-exm/lib/'),
          '@feature-demo1': path.resolve(__dirname, '../../../libs/exm-web/lib/feature-demo1/'),
          '@feature-funny': path.resolve(__dirname, '../../../libs/exm-modules/lib/feature-funny/'),
        },
      },
    });
  },
};
export default config;

// export const docs = {};
// export const addons = ['@chromatic-com/storybook'];

import type { StorybookConfig } from '@storybook/react-vite'
import { mergeConfig } from 'vite';
import path from 'path';
import EnvironmentPlugin from 'vite-plugin-environment';

const config: StorybookConfig = {
  framework: '@storybook/react-vite',
  // ⚠️ SSOT ของ "host นี้ครอบ lib ไหน" — `tools/update_storybookhost_alias.sh` อ่าน alias จากบล็อกนี้
  //    ⇒ อยากให้ host ครอบ lib เพิ่ม/เปลี่ยน base = แก้ที่นี่ที่เดียว alias ตามให้เอง
  //    เขียนเป็น `libs/**` = ครอบทุก base (เดิมเป็นแบบนี้) → story ของ base อื่นจะทำให้ผลเทสเขียวปลอม
  stories: [
    '../../../libs/example-lib/**/feature-*/**/*.stories.@(js|jsx|ts|tsx)',
    '../../../libs/example-lib/**/ui-*/**/*.stories.@(js|jsx|ts|tsx)',
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
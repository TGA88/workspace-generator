import type { Meta, StoryObj } from '@storybook/react';
import { expect, within } from '@storybook/test';
import { http, HttpResponse } from 'msw';

import { UserManagementPage } from '../user-management.page';

// page-level story = acceptance ของ flow ที่ compose แล้ว (storybook-testing §4)
// feature นี้ fetch เอง → จำลอง network ด้วย MSW handlers (ชุดเดียวกับ mocks/ ของ feature)
const meta: Meta<typeof UserManagementPage> = {
  title: 'feature-user-management/pages/UserManagementPage',
  component: UserManagementPage,
  tags: ['autodocs'],
  parameters: {
    msw: {
      handlers: [
        http.get('/api/users', () => {
          return HttpResponse.json([
            { id: 1, name: 'John Doe', role: 'admin', isActive: true, isDeleted: false, isPremium: true, lastLoginDate: '2024-01-01' },
            { id: 2, name: 'Jane Smith', role: 'user', isActive: false, isDeleted: false, isPremium: false, lastLoginDate: '2024-01-01' },
            { id: 3, name: 'Bob Johnson', role: 'user', isActive: true, isDeleted: false, isPremium: true, lastLoginDate: '2024-01-01' },
          ])
        })
      ]
    }
  }
};

export default meta;
type Story = StoryObj<typeof UserManagementPage>;

// demonstration states
export const Default: Story = {};

export const Loading: Story = {
  parameters: {
    msw: {
      handlers: [
        http.get('/api/users', async () => {
          await new Promise(resolve => setTimeout(resolve, 2000));
          return HttpResponse.json([])
        })
      ]
    }
  }
};

export const Error: Story = {
  parameters: {
    msw: {
      handlers: [
        http.get('/api/users', () => {
          return new HttpResponse(null, { status: 500 })
        })
      ]
    }
  }
};

export const Empty: Story = {
  parameters: {
    msw: {
      handlers: [
        http.get('/api/users', () => {
          return HttpResponse.json([])
        })
      ]
    }
  }
};

// acceptance: fetch ผ่าน MSW แล้วผู้ใช้เห็นรายชื่อจริงบนหน้า — เคสสำคัญเข้า CI gate (storybook-testing §7)
export const ShowsFetchedUsers: Story = {
  tags: ['ci'],
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement);
    await expect(await canvas.findByText('John Doe')).toBeInTheDocument();
    await expect(await canvas.findByText('Bob Johnson')).toBeInTheDocument();
  },
};

import type { Meta, StoryObj } from '@storybook/react';
import { UserManagementContainer } from '@feature-funny/containers/user-management-container';
import { http, HttpResponse } from 'msw';

const meta: Meta<typeof UserManagementContainer> = {
  title: 'Feature-Funny/Containers/UserManagementContainer',
  component: UserManagementContainer,
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
type Story = StoryObj<typeof UserManagementContainer>;

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
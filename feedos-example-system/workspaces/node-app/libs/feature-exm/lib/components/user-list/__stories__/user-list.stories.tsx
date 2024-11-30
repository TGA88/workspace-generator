import type { Meta, StoryObj } from '@storybook/react';
import { UserList } from '../user-list';
import { User } from '../../../types/user.type';
import { within ,userEvent} from '@storybook/testing-library'

const meta = {
  title: 'Components/UserList',
  component: UserList,
  parameters: {
    layout: 'padded',
  },
  tags: ['autodocs'],
} satisfies Meta<typeof UserList>;

export default meta;
type Story = StoryObj<typeof UserList>;

// Mock data
const mockUsers: User[] = [
  {
    id: 1,
    name: 'John Doe',
    role: 'admin',
    isActive: true,
    isDeleted: false,
    isPremium: true,
    lastLoginDate: '2024-01-15'
  },
  {
    id: 2,
    name: 'Jane Smith',
    role: 'user',
    isActive: true,
    isDeleted: false,
    isPremium: false,
    lastLoginDate: '2024-01-10'
  },
  {
    id: 3,
    name: 'Bob Wilson',
    role: 'user',
    isActive: false,
    isDeleted: false,
    isPremium: false,
    lastLoginDate: '2023-12-25'
  }
];

// Base args that will be used by all stories
const baseArgs = {
  onFilterChange: (field: string, value: string) => console.log('Filter changed:', field, value),
  onSelectUser: (user: User) => console.log('Selected user:', user),
  onDeleteUser: (userId: number) => console.log('Delete user:', userId),
};

export const Default: Story = {
  args: {
    ...baseArgs,
    users: mockUsers,
    filters: {
      status: 'all',
      role: ''
    }
  }
};

export const Empty: Story = {
  args: {
    ...baseArgs,
    users: [],
    filters: {
      status: 'all',
      role: ''
    }
  }
};

export const OnlyActiveUsers: Story = {
  args: {
    ...baseArgs,
    users: mockUsers.filter(user => user.isActive),
    filters: {
      status: 'active',
      role: ''
    }
  }
};

export const FilteredByRole: Story = {
  args: {
    ...baseArgs,
    users: mockUsers.filter(user => user.role === 'admin'),
    filters: {
      status: 'all',
      role: 'admin'
    }
  }
};

export const PremiumUsers: Story = {
  args: {
    ...baseArgs,
    users: mockUsers.filter(user => user.isPremium),
    filters: {
      status: 'all',
      role: ''
    }
  }
};

export const LongList: Story = {
  args: {
    ...baseArgs,
    users: Array.from({ length: 10 }, (_, index) => ({
      ...mockUsers[index % mockUsers.length],
      id: index + 1,
      name: `User ${index + 1}`
    })),
    filters: {
      status: 'all',
      role: ''
    }
  }
};

// Story with play function to demonstrate interactions
export const InteractiveFilters: Story = {
  args: {
    ...Default.args,
  },
  play: async ({ canvasElement, step }) => {
    const canvas = within(canvasElement);
    
    await step('Change status filter', async () => {
      const statusSelect = canvas.getByLabelText('Status filter');
      await userEvent.click(statusSelect);
      const activeOption = await canvas.findByText('Active');
      await userEvent.click(activeOption);
    });
    
    await step('Change role filter', async () => {
      const roleSelect = canvas.getByLabelText('Role filter');
      await userEvent.click(roleSelect);
      const adminOption = await canvas.findByText('Admin');
      await userEvent.click(adminOption);
    });
  }
};
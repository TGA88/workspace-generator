import type { Meta, StoryObj } from '@storybook/react';
import { UserList } from '@feature-exm/components/user-list/user-list';
import { User } from '@feature-exm/types/user.type';
import { within ,userEvent, waitFor} from '@storybook/testing-library'
import { fn, expect } from '@storybook/test'; 


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
    ...baseArgs,
    ...Default.args,
    onFilterChange: fn(),
  },
  play: async ({ args, canvasElement, step }) => {
    const canvas = within(canvasElement);
    
    await step('Change status filter', async () => {
      const statusSelect = await canvas.findByLabelText('Status');
      await userEvent.click(statusSelect);

      // เพิ่ม type assertion เป็น HTMLElement
      const listbox = document.querySelector('[role="listbox"]') as HTMLElement;
      if (!listbox) throw new Error('Listbox not found');
      
      const activeOption = within(listbox).getByText('Active');
      await userEvent.click(activeOption);

      await expect(args.onFilterChange).toHaveBeenCalledWith('status', 'active');
    });
    await step('Change role filter', async () => {
      const roleSelect = await canvas.findByLabelText('Role');
      await userEvent.click(roleSelect);
     
      // รอให้ dropdown menu ปรากฏใน DOM
      await waitFor(() => {
        expect(within(document.body).getByText('Admin')).toBeInTheDocument();
      });
     
      const adminOption = within(document.body).getByText('Admin');
      await userEvent.click(adminOption);
     
      await expect(args.onFilterChange).toHaveBeenCalledWith('role', 'admin');
     });
    
  }
};
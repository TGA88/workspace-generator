import type { Meta, StoryObj } from '@storybook/react';
import { UserStats } from '@feature-exm/components/user-stats';

const meta: Meta<typeof UserStats> = {
  title: 'Feature-Exm/Components/UserStats',
  component: UserStats,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof UserStats>;

export const Default: Story = {
  args: {
    stats: {
      total: 100,
      active: 75,
      premium: 30,
      recentlyActive: 50
    }
  }
};

export const Empty: Story = {
  args: {
    stats: {
      total: 0,
      active: 0,
      premium: 0,
      recentlyActive: 0
    }
  }
};

export const HighActivity: Story = {
  args: {
    stats: {
      total: 1000,
      active: 950,
      premium: 800,
      recentlyActive: 900
    }
  }
};
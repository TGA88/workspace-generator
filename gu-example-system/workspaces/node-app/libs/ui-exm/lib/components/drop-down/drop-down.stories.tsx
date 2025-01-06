import type { Meta, StoryObj } from '@storybook/react';
import  Dropdown  from './drop-down';

const meta: Meta<typeof Dropdown> = {
  title: 'Components/Dropdown',
  component: Dropdown,
  tags: ['autodocs'],
  parameters: {
    layout: 'centered',
  },
  argTypes: {
    items: {
      control: { type: 'object' }, // แก้จาก 'array' เป็น { type: 'object' }
      description: 'Array of items to be displayed in the dropdown'
    },
    onSelect: { 
      action: 'selected',
      description: 'Callback function when an item is selected' 
    }
  }
};

export default meta;
type Story = StoryObj<typeof Dropdown>;

export const Default: Story = {
  args: {
    items: ['Option 1', 'Option 2', 'Option 3']
  }
};

export const WithLongItems: Story = {
  args: {
    items: [
      'Really Long Option Text 1',
      'Really Long Option Text 2',
      'Really Long Option Text 3'
    ]
  }
};

export const WithManyItems: Story = {
  args: {
    items: Array.from({ length: 10 }, (_, i) => `Option ${i + 1}`)
  }
};

export const Empty: Story = {
  args: {
    items: []
  }
};
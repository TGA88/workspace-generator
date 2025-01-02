import type { Meta, StoryObj } from '@storybook/react';
import  Popover  from './pop-over';

const meta: Meta<typeof Popover> = {
  title: 'Components/Popover',
  component: Popover,
  tags: ['autodocs'],
  parameters: {
    layout: 'centered',
  },
  argTypes: {
    trigger: {
      description: 'Element that triggers the popover'
    },
    content: {
      description: 'Content to be displayed in the popover'
    }
  }
};

export default meta;
type Story = StoryObj<typeof Popover>;

export const Default: Story = {
  args: {
    trigger: <button className="px-4 py-2 bg-blue-500 text-white rounded">
      Click me
    </button>,
    content: (
      <div>
        <h3 className="font-bold mb-2">Popover Title</h3>
        <p>This is popover content</p>
      </div>
    )
  }
};

export const WithList: Story = {
  args: {
    trigger: <button className="px-4 py-2 bg-green-500 text-white rounded">
      Show List
    </button>,
    content: (
      <div>
        <h3 className="font-bold mb-2">Quick Links</h3>
        <ul className="space-y-2">
          <li>Profile</li>
          <li>Settings</li>
          <li>Help</li>
          <li>Logout</li>
        </ul>
      </div>
    )
  }
};

export const WithCustomTrigger: Story = {
  args: {
    trigger: (
      <div className="flex items-center space-x-2 cursor-pointer">
        <img 
          src="https://via.placeholder.com/40" 
          className="rounded-full"
          alt="avatar"
        />
        <span>User Menu</span>
      </div>
    ),
    content: (
      <div className="min-w-[200px]">
        <div className="p-2 border-b">
          <p className="font-bold">John Doe</p>
          <p className="text-sm text-gray-500">john@example.com</p>
        </div>
        <div className="p-2">
          <button className="w-full text-left p-2 hover:bg-gray-100 rounded">
            Sign Out
          </button>
        </div>
      </div>
    )
  }
};
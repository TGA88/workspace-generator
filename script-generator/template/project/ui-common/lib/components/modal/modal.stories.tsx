import type { Meta, StoryObj } from '@storybook/react';
import  Modal  from './modal';

const meta: Meta<typeof Modal> = {
  title: 'Components/Modal',
  component: Modal,
  tags: ['autodocs'],
  parameters: {
    layout: 'centered',
  },
  argTypes: {
    isOpen: {
      control: 'boolean',
      description: 'Controls modal visibility'
    },
    onClose: {
      action: 'closed',
      description: 'Callback function when modal is closed'
    },
    children: {
      control: 'text',
      description: 'Modal content'
    }
  }
};

export default meta;
type Story = StoryObj<typeof Modal>;

export const Default: Story = {
  args: {
    isOpen: true,
    children: (
      <div>
        <h2 className="text-xl font-bold mb-4">Modal Title</h2>
        <p>This is the modal content.</p>
      </div>
    )
  }
};

export const WithForm: Story = {
  args: {
    isOpen: true,
    children: (
      <div>
        <h2 className="text-xl font-bold mb-4">Contact Form</h2>
        <form className="space-y-4">
          <input 
            type="text" 
            placeholder="Name" 
            className="w-full p-2 border rounded"
          />
          <input 
            type="email" 
            placeholder="Email" 
            className="w-full p-2 border rounded"
          />
          <button className="w-full p-2 bg-blue-500 text-white rounded">
            Submit
          </button>
        </form>
      </div>
    )
  }
};

export const LongContent: Story = {
  args: {
    isOpen: true,
    children: (
      <div>
        <h2 className="text-xl font-bold mb-4">Long Content</h2>
        {Array.from({ length: 5 }, (_, i) => (
          <p key={i} className="mb-4">
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
            Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          </p>
        ))}
      </div>
    )
  }
};
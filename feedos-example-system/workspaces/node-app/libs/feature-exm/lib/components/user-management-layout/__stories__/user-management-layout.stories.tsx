import type { Meta, StoryObj } from '@storybook/react';
import { UserManagementLayout } from '../user-management-layout';
import Paper from '@mui/material/Paper';
import Typography from '@mui/material/Typography';

const meta: Meta<typeof UserManagementLayout> = {
  title: 'Components/Layout/UserManagementLayout',
  component: UserManagementLayout,
  parameters: {
    layout: 'padded',
  },
  tags: ['autodocs'],
  decorators: [
    (Story) => (
      <div style={{ maxWidth: '1200px', margin: '0 auto' }}>
        <Story />
      </div>
    )
  ]
};

export default meta;
type Story = StoryObj<typeof UserManagementLayout>;

// Mock components
const MockStats = () => (
  <Paper sx={{ p: 3, bgcolor: '#f5f5f5' }}>
    <Typography variant="h6">Stats Component</Typography>
    <Typography>Sample statistics would appear here</Typography>
  </Paper>
);

const MockList = () => (
  <Paper sx={{ p: 3, bgcolor: '#f5f5f5' }}>
    <Typography variant="h6">List Component</Typography>
    <Typography>Sample list items would appear here</Typography>
  </Paper>
);

export const Default: Story = {
  args: {
    statsComponent: <MockStats />,
    listComponent: <MockList />
  }
};

export const WithoutStats: Story = {
  args: {
    statsComponent: null,
    listComponent: <MockList />
  }
};

export const WithoutList: Story = {
  args: {
    statsComponent: <MockStats />,
    listComponent: null
  }
};

export const CustomSpacing: Story = {
  render: () => (
    <UserManagementLayout
      statsComponent={
        <Paper sx={{ p: 2, bgcolor: 'primary.light', color: 'white' }}>
          <Typography>Custom Stats Component</Typography>
        </Paper>
      }
      listComponent={
        <Paper sx={{ p: 2, bgcolor: 'secondary.light', color: 'white' }}>
          <Typography>Custom List Component</Typography>
        </Paper>
      }
    />
  )
};
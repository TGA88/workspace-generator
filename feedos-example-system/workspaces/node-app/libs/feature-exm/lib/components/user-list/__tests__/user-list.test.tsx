import { render, screen, fireEvent, within } from '@testing-library/react';
import { UserList } from '../user-list';

describe('UserList', () => {
  const mockUsers = [
    { id: 1, name: 'John', role: 'admin', isActive: true, isDeleted: false, isPremium: true, lastLoginDate: '2024-01-01' },
    { id: 2, name: 'Jane', role: 'user', isActive: false, isDeleted: false, isPremium: false, lastLoginDate: '2024-01-01' }
  ];

  const defaultProps = {
    users: mockUsers,
    filters: { status: 'all' as const, role: '' },
    onFilterChange: jest.fn(),
    onSelectUser: jest.fn(),
    onDeleteUser: jest.fn()
  };

  it('renders users correctly', () => {
    render(<UserList {...defaultProps} />);
    
    expect(screen.getByText('John')).toBeInTheDocument();
    expect(screen.getByText('Jane')).toBeInTheDocument();
  });

  it('calls onFilterChange when status filter changes', () => {
    render(<UserList {...defaultProps} />);
    
    // หา Select component จาก text ที่แสดงค่าปัจจุบัน
    const statusSelect = screen.getByRole('button', { name: /all/i });
    fireEvent.mouseDown(statusSelect);

    // หา option จาก popover menu
    const listbox = screen.getByRole('listbox');
    const option = within(listbox).getByText('Active');
    fireEvent.click(option);
    
    expect(defaultProps.onFilterChange).toHaveBeenCalledWith('status', 'active');
  });

  it('calls onFilterChange when role filter changes', () => {
    render(<UserList {...defaultProps} />);
    
    const roleSelect = screen.getByRole('button', { name: /all/i });
    fireEvent.mouseDown(roleSelect);

    const listbox = screen.getByRole('listbox');
    const option = within(listbox).getByText('Admin');
    fireEvent.click(option);
    
    expect(defaultProps.onFilterChange).toHaveBeenCalledWith('role', 'admin');
  });

  it('calls onSelectUser when user row is clicked', () => {
    render(<UserList {...defaultProps} />);
    
    fireEvent.click(screen.getByText('John'));
    
    expect(defaultProps.onSelectUser).toHaveBeenCalledWith(mockUsers[0]);
  });

  it('calls onDeleteUser when delete button is clicked', () => {
    render(<UserList {...defaultProps} />);
    
    const deleteButtons = screen.getAllByRole('button', { name: /delete/i });
    fireEvent.click(deleteButtons[0]);
    
    expect(defaultProps.onDeleteUser).toHaveBeenCalledWith(mockUsers[0].id);
  });
});
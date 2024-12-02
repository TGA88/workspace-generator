import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { http, HttpResponse } from 'msw';
// import { server } from '@mocks/server';
import { server } from '@root/workspaces/node-app/libs/feature-exm/lib/mocks/server';
import { UserManagementContainer } from '@feature-exm/containers/user-management-container';

describe('UserManagementContainer', () => {
  const mockUsers = [
    { id: 1, name: 'John', role: 'admin', isActive: true, isDeleted: false, isPremium: true, lastLoginDate: '2024-01-01' },
    { id: 2, name: 'Jane', role: 'user', isActive: false, isDeleted: false, isPremium: false, lastLoginDate: '2024-01-01' }
  ];

  beforeAll(() => server.listen());
  afterEach(() => server.resetHandlers());
  afterAll(() => server.close());

  it('should display users and stats', async () => {
    server.use(
      http.get('/api/users', () => {
        return HttpResponse.json(mockUsers);
      })
    );

    render(<UserManagementContainer />);

    await waitFor(() => {
      expect(screen.getByText('John')).toBeInTheDocument();
    });

    expect(screen.getByText('Total Users')).toBeInTheDocument();
  });

  it('should filter users', async () => {
    server.use(
      http.get('/api/users', () => {
        return HttpResponse.json(mockUsers);
      })
    );

    render(<UserManagementContainer />);

    await waitFor(() => {
      expect(screen.getByText('John')).toBeInTheDocument();
    });

    fireEvent.mouseDown(screen.getByLabelText('Status'));
    fireEvent.click(screen.getByText('Active'));

    expect(screen.getByText('John')).toBeInTheDocument();
    expect(screen.queryByText('Jane')).not.toBeInTheDocument();
  });
});
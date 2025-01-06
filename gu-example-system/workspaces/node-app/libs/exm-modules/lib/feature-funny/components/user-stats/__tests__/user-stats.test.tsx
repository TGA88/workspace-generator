import { render, screen } from '@testing-library/react';
import { UserStats } from '../user-stats';

describe('UserStats', () => {
  const mockStats = {
    total: 100,
    active: 80,
    premium: 30,
    recentlyActive: 50
  };

  it('renders all stats correctly', () => {
    render(<UserStats stats={mockStats} />);
    
    expect(screen.getByText('100')).toBeInTheDocument();
    expect(screen.getByText('80')).toBeInTheDocument();
    expect(screen.getByText('30')).toBeInTheDocument();
    expect(screen.getByText('50')).toBeInTheDocument();
  });

  it('renders all stat labels', () => {
    render(<UserStats stats={mockStats} />);
    
    expect(screen.getByText('Total Users')).toBeInTheDocument();
    expect(screen.getByText('Active Users')).toBeInTheDocument();
    expect(screen.getByText('Premium Users')).toBeInTheDocument();
    expect(screen.getByText('Recently Active')).toBeInTheDocument();
  });
});
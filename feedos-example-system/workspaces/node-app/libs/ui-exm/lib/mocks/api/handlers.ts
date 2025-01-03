import { http, HttpResponse } from 'msw';
// import { User } from '@ui-exm/types/user.type';


const mockUsers: unknown[] = [
  {
    id: 1,
    name: 'John Doe',
    role: 'admin',
    isActive: true,
    isDeleted: false,
    isPremium: true,
    lastLoginDate: '2024-01-01'
  },
  {
    id: 2,
    name: 'Jane Smith',
    role: 'user',
    isActive: false,
    isDeleted: false,
    isPremium: false,
    lastLoginDate: '2024-01-01'
  }
];

export const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json(mockUsers);
  }),

  
  http.put('/api/users/:id', async ({ params, request }) => {
    console.log("params",params)
    const updatedUser = await request.json() ;
    return HttpResponse.json(updatedUser);
  }),

  
  http.delete('/api/users/:id', ({ params }) => {
    console.log("params",params)
    return HttpResponse.json({ success: true });
  })
];
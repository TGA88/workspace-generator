import { http, HttpResponse } from 'msw';
import { SendEmailRequest,SendEmailResponse } from '@exm-api-client/command/send-email/send-email.types';


const mockUsers: SendEmailRequest = {
  to: ['test@example.com'],
  subject: 'Test Subject',
  template: 'default-template'
}

export const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json(mockUsers);
  }),

  
  http.post('/api/notify/:id', async ({ params, request }) => {
    console.log("params",params)
    const updatedUser = await request.json() as SendEmailResponse;
    return HttpResponse.json(updatedUser);
  }),

  
  http.delete('/api/users/:id', ({ params }) => {
    console.log("params",params)
    return HttpResponse.json({ success: true });
  })
];
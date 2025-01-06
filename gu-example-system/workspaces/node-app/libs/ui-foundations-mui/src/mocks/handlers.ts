// src/mocks/handlers.ts
import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json([
      { id: 1, name: 'John' },
      { id: 2, name: 'Jane' }
    ])
  }),
  
  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json({
      id: Number(params.id),
      name: 'John'
    })
  })
]
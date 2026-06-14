import { http, HttpResponse } from 'msw';

// generic mock handlers — เพิ่ม mock ของแต่ละ endpoint ที่ scaffold ได้ที่นี่
export const handlers = [
  http.get('/api/health', () => HttpResponse.json({ ok: true })),
];

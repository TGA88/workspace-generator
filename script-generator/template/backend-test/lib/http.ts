// httpRequest — ยิง HTTP เข้า service ที่รันจริง (out-of-process) จาก contract.withRequest
// ใช้ global fetch (Node 18+) · base URL จาก env API_BASE_URL (default = compose api port)
export type WithRequest = {
  method: string;
  path: string;
  headers?: Record<string, string>;
  body?: unknown;
  query?: Record<string, string | number | boolean>;
  params?: Record<string, string>;
};

export type HttpResult = { status: number; headers: Record<string, string>; body: unknown };

const BASE_URL = process.env.API_BASE_URL ?? 'http://localhost:3010';

export async function httpRequest(req: WithRequest): Promise<HttpResult> {
  const url = new URL(req.path, BASE_URL);
  for (const [k, v] of Object.entries(req.query ?? {})) url.searchParams.set(k, String(v));

  const method = (req.method ?? 'get').toUpperCase();
  const hasBody = method !== 'GET' && method !== 'HEAD' && req.body != null;

  const res = await fetch(url, {
    method,
    headers: { 'content-type': 'application/json', ...(req.headers ?? {}) },
    body: hasBody ? JSON.stringify(req.body) : undefined,
  });

  const text = await res.text();
  let body: unknown = text || undefined;
  try {
    body = text ? JSON.parse(text) : undefined;
  } catch {
    /* non-json → คง text ไว้ */
  }

  const headers: Record<string, string> = {};
  res.headers.forEach((v, k) => {
    headers[k] = v;
  });
  return { status: res.status, headers, body };
}

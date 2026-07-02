// httpRequest — ยิง HTTP เข้า service ที่รันจริง (out-of-process) จาก contract.withRequest
// lib = pure: รับ target (baseUrl+prefix) เป็น parameter · ไม่แตะ process.env (test file เป็นคนกำหนด)
export type WithRequest = {
  method: string;
  path: string;
  headers?: Record<string, string>;
  body?: unknown;
  query?: Record<string, string | number | boolean>;
  params?: Record<string, string>;
};

export type HttpResult = { status: number; headers: Record<string, string>; body: unknown };

// Target = ปลายทางของ service (ต่าง service คนละ baseUrl/prefix) · prefix = mount prefix ของ app (เช่น /demo-shop-webapi)
// contract.path เป็น service-relative (/product-api/..) → prepend prefix ให้ตรง mount จริง
export type Target = { baseUrl: string; prefix?: string };

export async function httpRequest(req: WithRequest, target: Target): Promise<HttpResult> {
  const url = new URL((target.prefix ?? '') + req.path, target.baseUrl);
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

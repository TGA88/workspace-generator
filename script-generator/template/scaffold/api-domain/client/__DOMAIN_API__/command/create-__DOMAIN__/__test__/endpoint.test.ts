import { InhHttpClient } from '@inh-lib/common';
import { create__Domain__ } from '../endpoint';

describe('create__Domain__ (client)', () => {
  it('returns data on success', async () => {
    const payload = {
      statusCode: 200,
      isSuccess: true,
      codeResult: 'SUCCESS',
      message: 'ok',
      dataResult: { id: 'p1', sku: 'SKU-1' },
    };
    const client = { post: jest.fn().mockResolvedValue({ data: payload, status: 200 }) } as unknown as InhHttpClient;
    const res = await create__Domain__({ name: 'Shirt', sku: 'SKU-1', price: 100 }, client, { 'x-tenant': 't1' });
    expect(res.isSuccess).toBe(true);
    expect(res.dataResult).toEqual({ id: 'p1', sku: 'SKU-1' });
  });

  it('returns error response when request throws', async () => {
    const client = { post: jest.fn().mockRejectedValue(new Error('network')) } as unknown as InhHttpClient;
    const res = await create__Domain__({ name: 'Shirt', sku: 'SKU-1', price: 100 }, client);
    expect(res.isSuccess).toBe(false);
    expect(res.codeResult).toBe('create__Domain___ERROR');
    expect(res.dataResult).toBeNull();
  });
});

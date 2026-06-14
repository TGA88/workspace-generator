import { InhHttpClient } from '@inh-lib/common';
import { get__Domain__ } from '../endpoint';

describe('get__Domain__ (client)', () => {
  it('returns data on success', async () => {
    const payload = {
      statusCode: 200,
      isSuccess: true,
      codeResult: 'SUCCESS',
      message: 'ok',
      dataResult: { id: 'p1', name: 'Shirt', sku: 'SKU-1', price: 100 },
    };
    const client = { get: jest.fn().mockResolvedValue({ data: payload, status: 200 }) } as unknown as InhHttpClient;
    const res = await get__Domain__({ id: 'p1' }, client);
    expect(res.isSuccess).toBe(true);
    expect(res.dataResult?.id).toBe('p1');
  });

  it('returns error response when request throws', async () => {
    const client = { get: jest.fn().mockRejectedValue(new Error('network')) } as unknown as InhHttpClient;
    const res = await get__Domain__({ id: 'p1' }, client);
    expect(res.isSuccess).toBe(false);
    expect(res.codeResult).toBe('get__Domain___ERROR');
  });
});

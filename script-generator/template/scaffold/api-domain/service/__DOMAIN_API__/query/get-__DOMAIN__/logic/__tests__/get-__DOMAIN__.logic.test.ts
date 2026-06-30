import { ResultV2 as Result, CommonFailures } from '@inh-lib/common';
import { __DOMAINUP___API_CONTEXT_KEY } from '@__WS__/__API__-core/__DOMAIN_API__';
import { setupProcess } from '../routeSteps.logic';
import { processGet__Domain__Handler } from '../routeSteps.logic';
import { buildContext } from '../../../../command/create-__DOMAIN__/logic/__tests__/test-helper';

const __domain__ = { id: 'p1', name: 'Shirt', sku: 'SKU-1', price: 100 };

describe('setupProcess (get-__DOMAIN__)', () => {
  it('wires preHandlers + handler', () => {
    const { preHandlers, handler } = setupProcess();
    expect(preHandlers).toHaveLength(2);
    expect(typeof handler).toBe('function');
  });
});

describe('processGet__Domain__Handler', () => {
  it('returns __domain__ on success', async () => {
    const repo = { get__Domain__: jest.fn().mockResolvedValue(Result.ok(__domain__)) };
    const { ctx, captured } = buildContext({
      inputRequest: { id: 'p1' },
      [__DOMAINUP___API_CONTEXT_KEY.REPO_GET___DOMAINUP__]: repo,
    });
    await processGet__Domain__Handler(ctx);
    expect(repo.get__Domain__).toHaveBeenCalledWith(ctx, { id: 'p1' });
    expect(captured.body).toBeDefined();
  });
  it('sends failure when repo fails', async () => {
    const repo = { get__Domain__: jest.fn().mockResolvedValue(Result.fail(new CommonFailures.NotFoundFail('nf'))) };
    const { ctx, captured } = buildContext({
      inputRequest: { id: 'p1' },
      [__DOMAINUP___API_CONTEXT_KEY.REPO_GET___DOMAINUP__]: repo,
    });
    await processGet__Domain__Handler(ctx);
    expect(captured.statusCode).toBeGreaterThanOrEqual(400);
  });
});

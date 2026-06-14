import { ResultV2 as Result, CommonFailures } from '@inh-lib/common';
import { __DOMAINUP___API_CONTEXT_KEY } from '@__WS__/__API__-core';
import { validateCreate__Domain__Input } from '../business.logic';
import { setupProcess } from '../routeSteps.logic';
import {
  processCheckRequiredFieldPreHandler,
  processCheckDuplicateInRepoPreHandler,
  processCreate__Domain__InRepoHandler,
} from '../routeSteps.logic';
import { buildContext } from './test-helper';

const validInput = { name: 'Shirt', sku: 'SKU-1', price: 100 };

describe('validateCreate__Domain__Input (pure)', () => {
  it('passes for valid input', () => {
    expect(validateCreate__Domain__Input(validInput).isValid).toBe(true);
  });
  it('fails when required field missing', () => {
    const r = validateCreate__Domain__Input({ name: '', sku: 'x', price: 1 });
    expect(r.isValid).toBe(false);
    expect(r.missingFields).toContain('name');
  });
  it('fails when price negative', () => {
    const r = validateCreate__Domain__Input({ name: 'a', sku: 'b', price: -1 });
    expect(r.isValid).toBe(false);
    expect(r.message).toMatch(/price/);
  });
});

describe('setupProcess (create-__DOMAIN__)', () => {
  it('wires preHandlers + handler', () => {
    const { preHandlers, handler } = setupProcess();
    expect(preHandlers).toHaveLength(4);
    expect(typeof handler).toBe('function');
  });
});

describe('processCheckRequiredFieldPreHandler', () => {
  it('sends ParseFail when invalid', async () => {
    const { ctx, captured } = buildContext({ inputRequest: { name: '', sku: 's', price: 1 } });
    await processCheckRequiredFieldPreHandler(ctx);
    expect(captured.statusCode).toBeGreaterThanOrEqual(400);
  });
  it('passes through when valid', async () => {
    const { ctx, captured } = buildContext({ inputRequest: validInput });
    await processCheckRequiredFieldPreHandler(ctx);
    expect(captured.body).toBeUndefined();
  });
});

describe('processCheckDuplicateInRepoPreHandler', () => {
  it('passes when not duplicate', async () => {
    const repo = {
      checkDuplicateSku: jest.fn().mockResolvedValue(Result.ok({ isDuplicate: false })),
      create__Domain__: jest.fn(),
    };
    const { ctx, captured } = buildContext({
      inputRequest: validInput,
      [__DOMAINUP___API_CONTEXT_KEY.REPO_CREATE___DOMAINUP__]: repo,
    });
    await processCheckDuplicateInRepoPreHandler(ctx);
    expect(captured.body).toBeUndefined();
    expect(repo.checkDuplicateSku).toHaveBeenCalled();
  });
  it('sends Conflict when duplicate', async () => {
    const repo = {
      checkDuplicateSku: jest.fn().mockResolvedValue(Result.ok({ isDuplicate: true })),
      create__Domain__: jest.fn(),
    };
    const { ctx, captured } = buildContext({
      inputRequest: validInput,
      [__DOMAINUP___API_CONTEXT_KEY.REPO_CREATE___DOMAINUP__]: repo,
    });
    await processCheckDuplicateInRepoPreHandler(ctx);
    expect(captured.statusCode).toBeGreaterThanOrEqual(400);
  });
  it('sends failure when repo fails', async () => {
    const repo = {
      checkDuplicateSku: jest.fn().mockResolvedValue(Result.fail(new CommonFailures.InternalFail('db'))),
      create__Domain__: jest.fn(),
    };
    const { ctx, captured } = buildContext({
      inputRequest: validInput,
      [__DOMAINUP___API_CONTEXT_KEY.REPO_CREATE___DOMAINUP__]: repo,
    });
    await processCheckDuplicateInRepoPreHandler(ctx);
    expect(captured.statusCode).toBeGreaterThanOrEqual(400);
  });
});

describe('processCreate__Domain__InRepoHandler', () => {
  it('creates and returns ok payload', async () => {
    const repo = {
      checkDuplicateSku: jest.fn(),
      create__Domain__: jest.fn().mockResolvedValue(Result.ok({ id: 'p1', sku: 'SKU-1' })),
    };
    const { ctx, captured } = buildContext({
      inputRequest: validInput,
      [__DOMAINUP___API_CONTEXT_KEY.REPO_CREATE___DOMAINUP__]: repo,
    });
    await processCreate__Domain__InRepoHandler(ctx);
    expect(repo.create__Domain__).toHaveBeenCalled();
    expect(captured.body).toBeDefined();
  });
  it('sends failure when repo fails', async () => {
    const repo = {
      checkDuplicateSku: jest.fn(),
      create__Domain__: jest.fn().mockResolvedValue(Result.fail(new CommonFailures.InternalFail('db'))),
    };
    const { ctx, captured } = buildContext({
      inputRequest: validInput,
      [__DOMAINUP___API_CONTEXT_KEY.REPO_CREATE___DOMAINUP__]: repo,
    });
    await processCreate__Domain__InRepoHandler(ctx);
    expect(captured.statusCode).toBeGreaterThanOrEqual(400);
  });
});

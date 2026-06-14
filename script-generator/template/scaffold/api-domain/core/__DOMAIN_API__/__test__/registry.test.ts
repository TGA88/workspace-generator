import { __DOMAINUP___API_CONTEXT_KEY } from '../registry.const';

describe('__DOMAINUP___API_CONTEXT_KEY', () => {
  it('exposes stable DI keys', () => {
    expect(__DOMAINUP___API_CONTEXT_KEY.REPO_CREATE___DOMAINUP__).toBe('__Domain__Api.Repository.Create__Domain__');
    expect(__DOMAINUP___API_CONTEXT_KEY.REPO_GET___DOMAINUP__).toBe('__Domain__Api.Repository.Get__Domain__');
  });
  it('keys are unique', () => {
    const vals = Object.values(__DOMAINUP___API_CONTEXT_KEY);
    expect(new Set(vals).size).toBe(vals.length);
  });
});

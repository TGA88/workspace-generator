// DI context keys for __DOMAIN_API__ repositories.
// แต่ละ key ใช้ addRegistryItem ตอน composition root และ getRegistryItem ใน routeSteps
export const __DOMAINUP___API_CONTEXT_KEY = {
  REPO_CREATE___DOMAINUP__: '__Domain__Api.Repository.Create__Domain__',
  REPO_GET___DOMAINUP__: '__Domain__Api.Repository.Get__Domain__',
} as const;

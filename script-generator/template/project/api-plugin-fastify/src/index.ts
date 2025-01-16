import { FastifyCustomHookRequest } from './type.fastify-custom-hook'

export * from './plugins/support/support'

export * from './get-psc-account'
export * from './get-permission-and-role'
export * from './type.fastify-custom-hook'
export * from './check-role'
export * from './get-permission-and-role-from-get-me'
declare module 'fastify' {
    interface FastifyRequest extends FastifyCustomHookRequest { }
}
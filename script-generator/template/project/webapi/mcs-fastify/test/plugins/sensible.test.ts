import Fastify from 'fastify'
import Sensible from '@self/src/plugins/sensible'

// plugin-load test (แบบ support.test.ts) — ให้ plugins/ coverage ผ่าน gate โดยไม่ต้อง unit-test telemetry (bootstrap)
test('sensible plugin loads (adds httpErrors decorator)', async () => {
  const fastify = Fastify()
  void fastify.register(Sensible)
  await fastify.ready()

  // @fastify/sensible decorate fastify.httpErrors (notFound/badRequest/...)
  expect(fastify.httpErrors).toBeDefined()
  expect(typeof fastify.httpErrors.notFound).toBe('function')
})

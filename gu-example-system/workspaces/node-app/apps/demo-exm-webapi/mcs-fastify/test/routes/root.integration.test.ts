import { build } from '../helper'
// import App from '../../src/app'
import App from '@self/src/app'


const app = build(App)
test('default root route', async () => {

  const res = await app.inject({
    url: '/'
  })

  expect(res.statusCode).toBe(200)
  expect(res.json()).toEqual({ root: true, message: 'Welcome to the GU PSC Web API' })
})

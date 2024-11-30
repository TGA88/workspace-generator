import type { Meta, StoryObj } from '@storybook/react'
import { http, HttpResponse } from 'msw'
import  MyComponent  from '../../../lib/my-component/my-component'

const meta: Meta<typeof MyComponent> = {
  title: 'Features/MyComponent/S1U1',
  component: MyComponent,
//   parameters: {
//     msw: {
//       handlers: [
//         http.get('/api/users', () => {
//           return HttpResponse.json({
//             message: 'Success'
//           })
//         })
//       ]
//     }
//   }
}

export default meta
type Story = StoryObj<typeof MyComponent>

export const Error: Story = {
  parameters: {
    msw: {
      handlers: [
        http.get('/api/users', () => {
          return new HttpResponse(null, { status: 500 })
        })
      ]
    }
  }
}
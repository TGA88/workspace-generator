import { InhHttpClient } from '@inh-lib/common';
import { Get__Domain__Request, Get__Domain__Response } from './types';
import { CustomHeader } from '../../types';

export async function get__Domain__(
  input: Get__Domain__Request,
  inhClient: InhHttpClient,
  customHeader?: CustomHeader,
): Promise<Get__Domain__Response> {
  try {
    const response = await inhClient.get<Get__Domain__Response>(
      `/__DOMAIN_API__/get-__DOMAIN__/${input.id}`,
      { headers: customHeader },
    );
    return response.data;
  } catch (error) {
    return {
      statusCode: 400,
      isSuccess: false,
      codeResult: 'get__Domain___ERROR',
      message: `${error}`,
      dataResult: null,
    };
  }
}

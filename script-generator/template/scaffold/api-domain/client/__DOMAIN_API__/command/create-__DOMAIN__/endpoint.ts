import { InhHttpClient } from '@inh-lib/common';
import { Create__Domain__Request, Create__Domain__Response } from './types';
import { CustomHeader } from '../../types';

export async function create__Domain__(
  input: Create__Domain__Request,
  inhClient: InhHttpClient,
  customHeader?: CustomHeader,
): Promise<Create__Domain__Response> {
  try {
    const response = await inhClient.post<Create__Domain__Response>(
      `/__DOMAIN_API__/create-__DOMAIN__`,
      input,
      { headers: customHeader },
    );
    return response.data;
  } catch (error) {
    return {
      statusCode: 400,
      isSuccess: false,
      codeResult: 'create__Domain___ERROR',
      message: `${error}`,
      dataResult: null,
    };
  }
}

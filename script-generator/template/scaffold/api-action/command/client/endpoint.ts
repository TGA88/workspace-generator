import { InhHttpClient } from '@inh-lib/common';
import { __Verb____Domain__Request, __Verb____Domain__Response } from './types';
import { CustomHeader } from '../../types';

export async function __verb____Domain__(
  input: __Verb____Domain__Request,
  inhClient: InhHttpClient,
  customHeader?: CustomHeader,
): Promise<__Verb____Domain__Response> {
  try {
    const response = await inhClient.post<__Verb____Domain__Response>(
      `/__domain__-api/__verb__-__domain__`,
      input,
      { headers: customHeader },
    );
    return response.data;
  } catch (error) {
    return {
      statusCode: 400,
      isSuccess: false,
      codeResult: '__verb____Domain___ERROR',
      message: `${error}`,
      dataResult: null,
    };
  }
}

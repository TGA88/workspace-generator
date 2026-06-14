import { InhHttpClient } from '@inh-lib/common';
import { CustomHeader } from './types';
import { Create__Domain__Request, create__Domain__ } from './command/create-__DOMAIN__';
import { Get__Domain__Request, get__Domain__ } from './query/get-__DOMAIN__';

export class __Domain__Client {
  private readonly inhClient: InhHttpClient;
  private readonly customHeader?: CustomHeader;
  constructor(inhClient: InhHttpClient, customHeader?: CustomHeader) {
    this.inhClient = inhClient;
    this.customHeader = customHeader;
  }

  create__Domain__ = async (input: Create__Domain__Request): ReturnType<typeof create__Domain__> => {
    return await create__Domain__(input, this.inhClient, this.customHeader);
  };

  get__Domain__ = async (input: Get__Domain__Request): ReturnType<typeof get__Domain__> => {
    return await get__Domain__(input, this.inhClient, this.customHeader);
  };
}

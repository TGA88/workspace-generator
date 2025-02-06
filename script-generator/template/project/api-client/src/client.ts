
import { sendEmail, SendEmailRequest } from '@exm-api-client/command/send-email/send-email';
import { SendEmailRequest } from '@exm-api-client/command/send-email/send-email.types';
import { InhHttpClient } from '@inh-lib/common';


export class ExmApiClient {

private inhClient: InhHttpClient;
    constructor(inhClient: InhHttpClient) {
        this.inhClient = inhClient;
      
    }

    sendEmail = async (input: SendEmailRequest):ReturnType<typeof sendEmail> => {
        return await sendEmail(input, this.inhClient);
    };
}

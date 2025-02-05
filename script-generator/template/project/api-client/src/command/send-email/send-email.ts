
import { InhHttpClient, Result } from '@inh-lib/common';
import { sendEmailModel } from '@exm-api-client/command/send-email/send-email.model';
import { SendEmailRequest, SendEmailResponse } from '@exm-api-client/command/send-email/send-email.types';



export async function sendEmail(input: SendEmailRequest, inhClient: InhHttpClient): Promise<Result<sendEmailModel>> {
  try {
    const response = await inhClient.post<SendEmailResponse>(`/notify`, input);
    const data: sendEmailModel = {
      success: response.data.success,
    };
    return Result.ok(data);
  } catch (error) {
    console.log(error);
    return Result.fail(error);
  }
}

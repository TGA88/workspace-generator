import { sendEmailModel } from "./send-email.model";

export type SendEmailRequest = {
  to: string[];
  subject: string;
  template: string;
  attachments?: {
    content: string
    encoding: string
    filename: string
  }[]
};

export type SendEmailResponse = {
  data: sendEmailModel;
  success: boolean;
};

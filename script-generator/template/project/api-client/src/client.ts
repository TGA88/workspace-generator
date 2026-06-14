import { InhHttpClient } from '@inh-lib/common';

// Base aggregate client. เพิ่ม domain client ของแต่ละ domain ที่ scaffold ได้ที่นี่
// เช่น:  readonly product = new ProductClient(this.inhClient, this.customHeader);
export class ApiClient {
  protected readonly inhClient: InhHttpClient;
  constructor(inhClient: InhHttpClient) {
    this.inhClient = inhClient;
  }
}

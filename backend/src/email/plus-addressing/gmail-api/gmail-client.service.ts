import { Injectable, OnModuleInit } from '@nestjs/common';
import { gmail_v1, google } from 'googleapis';

const token = '1//03ozBv9bZgJGZCgYIARAAGAMSNgF-L9IrCSA4g3dbSO_iuV-qzD6HZENBCNHHC2d6NCot7qbyhvP4QGa4T2wGaIbkNw8GwnQJAg';

@Injectable()
export class GmailClientService implements OnModuleInit {
  readonly authClient = new google.auth.OAuth2(
    process.env.GOOGLE_CLIENT_ID,
    process.env.GOOGLE_CLIENT_SECRET,
    process.env.GOOGLE_REDIRECT_URI,
  );

  gmail: gmail_v1.Gmail;

  async onModuleInit() {
    this.authClient.setCredentials({ refresh_token: token });
    this.gmail = google.gmail({ version: 'v1', auth: this.authClient });
  }

  setCredentials(tokens: Parameters<typeof this.authClient.setCredentials>[0]) {
    this.authClient.setCredentials(tokens);
  }
}

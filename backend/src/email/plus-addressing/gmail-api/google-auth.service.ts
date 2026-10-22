import { Injectable } from '@nestjs/common';
import { GmailClientService } from './gmail-client.service.ts';

const OAUTH_SCOPES = ['https://www.googleapis.com/auth/gmail.readonly'];

@Injectable()
export class GoogleAuthService {
  constructor(private readonly gmailClient: GmailClientService) {}

  getAuthUrl(): string {
    return this.gmailClient.authClient.generateAuthUrl({
      access_type: 'offline',
      scope: OAUTH_SCOPES,
      prompt: 'consent',
    });
  }

  async handleCallback(authorizationCode: string) {
    const { tokens } =
      await this.gmailClient.authClient.getToken(authorizationCode);
    this.gmailClient.setCredentials(tokens);
    return tokens;
  }
}

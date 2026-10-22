import { Injectable, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { gmail_v1, google } from 'googleapis';
import { FlightUpdateEmail } from './flight-update-email.entity.ts';
import { Repository } from 'typeorm';
import { GmailClientService } from './gmail-api/gmail-client.service.ts'; // move to same plus-addressing feature folder

const token = '1//03ozBv9bZgJGZCgYIARAAGAMSNgF-L9IrCSA4g3dbSO_iuV-qzD6HZENBCNHHC2d6NCot7qbyhvP4QGa4T2wGaIbkNw8GwnQJAg'; 
// TODO: store refresh token somewhere secure

@Injectable()
export class PlusAddressingEmailObserverService implements OnModuleInit {
  constructor(
    private readonly gmailClient: GmailClientService,
    @InjectRepository(FlightUpdateEmail)
    private mailRepository: Repository<FlightUpdateEmail>,
  ) {}

  private readonly authClient = new google.auth.OAuth2(
    process.env.GOOGLE_CLIENT_ID,
    process.env.GOOGLE_CLIENT_SECRET,
    process.env.GOOGLE_REDIRECT_URI,
  );

  private gmail: gmail_v1.Gmail;
  private baseEmail: string = process.env.BASE_EMAIL as string;

  async onModuleInit() {
    this.authClient.setCredentials({ refresh_token: token });
    this.gmail = google.gmail({ version: 'v1', auth: this.authClient });
  }

  async checkForNewMail(id: string) {
    const { data: { messages } } = await this.gmail.users.messages.list({
      userId: `${this.baseEmail}`,
      q: `to:${this.baseEmail.split('@')[0]}+${id}@${this.baseEmail.split('@')[1]}`,
    });

    if (!messages) {
      return [];
    }

    const unprocessed: gmail_v1.Schema$Message[] = [];

    for (const message of messages) {
      if (!message.id) {
        continue;
      }

      const emailProcessed = await this.mailRepository.findOneBy({ id: message.id });

      if (!emailProcessed) {
        unprocessed.push(message);
      }
    }

    return unprocessed;
  }
}

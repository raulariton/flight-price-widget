import { Controller, Get, Query } from '@nestjs/common';
import { PlusAddressingEmailGenerationService } from './plus-addressing-email-generation.service.ts';
import { PlusAddressingEmailObserverService } from './plus-addressing-email-observer.service.ts';
import { PlusAddressingEmailParsingService } from './plus-addresing-email-parsing.service.ts';

@Controller('email')
export class EmailController {
  constructor(
    private readonly plusAddressingEmailGeneration: PlusAddressingEmailGenerationService,
    private readonly plusAddressingEmailObserver: PlusAddressingEmailObserverService,
    private readonly plusAddressingEmailParser: PlusAddressingEmailParsingService,
  ) {}

  @Get()
  getEmail(): string {
    return this.plusAddressingEmailGeneration.generatePlusAddressingEmail();
  }

  @Get('inbox')
  async getEmailInbox(@Query('id') id: string) {
    const messagesToBeProcessed = await this.plusAddressingEmailObserver.checkForNewMail(id);

    if (!messagesToBeProcessed) {
      return;
    }

    const content = await Promise.all(messagesToBeProcessed.map((message) => this.plusAddressingEmailParser.getMessageData(message.id!)))

    return content;
  }
}

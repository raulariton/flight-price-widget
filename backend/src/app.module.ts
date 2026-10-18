import { Module } from '@nestjs/common';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { EmailController } from './email/email.controller.js';
import { PlusAddressingEmailGenerationService } from './email/plus-addressing/plusAddressingEmailGeneration.service.ts';

// Each feature receives its own route and its own module
@Module({
  imports: [],
  controllers: [AppController, EmailController],
  providers: [AppService, PlusAddressingEmailGenerationService],
})
export class AppModule {}

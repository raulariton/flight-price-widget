import { Controller, Get } from '@nestjs/common';
import { PlusAddressingEmailGenerationService } from './plus-addressing/plusAddressingEmailGeneration.service.js';

@Controller('email')
export class AppController {
  @Get()
  getEmail(): string {
    return new PlusAddressingEmailGenerationService().generatePlusAddressingEmail();
  }
}

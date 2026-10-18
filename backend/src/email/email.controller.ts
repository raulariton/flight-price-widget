import { Controller, Get } from '@nestjs/common';
import { PlusAddressingEmailGenerationService } from './plus-addressing/plusAddressingEmailGeneration.service.js';

@Controller('email')
export class EmailController {
  constructor(
    private readonly plusAddressingEmailGeneration: PlusAddressingEmailGenerationService,
  ) {}

  @Get()
  getEmail(): string {
    return this.plusAddressingEmailGeneration.generatePlusAddressingEmail();
  }
}

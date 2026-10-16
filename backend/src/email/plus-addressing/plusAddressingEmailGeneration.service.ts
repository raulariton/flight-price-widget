import { Injectable } from '@nestjs/common';
process.loadEnvFile();

@Injectable() // WHY? 
export class PlusAddressingEmailGenerationService {

  baseEmail: string = process.env.BASE_EMAIL || 'raul.spending@gmail.com';

  generatePlusAddressingEmail(): string {
    const randomId = Math.random().toString(36).substring(2, 15);

    return `${this.baseEmail.split('@')[0]}+${randomId}@${this.baseEmail.split('@')[1]}`;
  }
}

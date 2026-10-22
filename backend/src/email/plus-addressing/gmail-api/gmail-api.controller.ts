import { Controller, Get, Query, Res } from '@nestjs/common';
import { GoogleAuthService } from './google-auth.service.ts';
import type { Response } from 'express';

@Controller('email/google')
export class GoogleAuthController {
  constructor(private readonly googleAuth: GoogleAuthService) {}

  @Get('auth')
  redirectToGoogle(@Res() res: Response) {
    res.redirect(this.googleAuth.getAuthUrl());
  }

  @Get('callback')
  async handleCallback(@Query('code') authorizationCode: string) {
    const tokens = await this.googleAuth.handleCallback(authorizationCode);
    return tokens;
  }
}

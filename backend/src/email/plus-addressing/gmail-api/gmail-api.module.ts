import { Module } from "@nestjs/common";
import { GoogleAuthController } from "./gmail-api.controller.ts";
import { GoogleAuthService } from "./google-auth.service.ts";
import { GmailClientService } from "./gmail-client.service.ts";

@Module({
    controllers: [GoogleAuthController],
    providers: [GoogleAuthService, GmailClientService],
    exports: [GmailClientService],
})
export class GmailApiModule {}

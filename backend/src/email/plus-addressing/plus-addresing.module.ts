import { Module } from "@nestjs/common";
import { EmailController } from "./plus-addressing-email.controller.ts";
import { PlusAddressingEmailGenerationService } from "./plus-addressing-email-generation.service.ts";
import { PlusAddressingEmailObserverService } from "./plus-addressing-email-observer.service.ts";
import { TypeOrmModule } from "@nestjs/typeorm";
import { FlightUpdateEmail } from "./flight-update-email.entity.ts";
import { GmailApiModule } from "./gmail-api/gmail-api.module.ts";
import { PlusAddressingEmailParsingService } from "./plus-addresing-email-parsing.service.ts";

@Module({
    imports: [TypeOrmModule.forFeature([FlightUpdateEmail]), GmailApiModule],
    controllers: [EmailController],
    providers: [PlusAddressingEmailGenerationService, PlusAddressingEmailObserverService, PlusAddressingEmailParsingService]
})

export class PlusAddressingModule {}
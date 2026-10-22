import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { FlightUpdateEmail } from './flight-update-email.entity.ts';
import { Repository } from 'typeorm';
import { GmailClientService } from './gmail-api/gmail-client.service.ts';
import { gmail_v1 } from 'googleapis';
import * as cheerio from 'cheerio';
import { z } from 'zod';
import { FlightUpdateEmail as FlightUpdateEmailSchema } from './flight-update-email.schema.ts';
import { DateTime } from 'luxon';
import parseCurrency from 'parsecurrency';

const localeConfig = {
  locale: 'en',
  to: 'to',
  at: 'at',
  pricesUpdated: 'Prices updated',
};

@Injectable()
export class PlusAddressingEmailParsingService {
  constructor(
    private readonly gmailClient: GmailClientService,
    @InjectRepository(FlightUpdateEmail)
    private mailRepository: Repository<FlightUpdateEmail>,
  ) {}

  private baseEmail: string = process.env.BASE_EMAIL as string;

  async getMessageData(messageId: string) {
    const {
      data: { internalDate, payload },
    } = await this.gmailClient.gmail.users.messages.get({
      userId: `${this.baseEmail}`,
      id: messageId,
      format: 'full',
    });

    if (!payload) {
      return;
    }

    // Recursive extraction
    function getHtmlParts(
      part: gmail_v1.Schema$MessagePart,
      htmlParts: string[] = [],
    ) {
      if (part.mimeType === 'text/html' && part.body?.data) {
        htmlParts.push(part.body.data);
      }

      for (const child of part.parts ?? []) {
        getHtmlParts(child, htmlParts);
      }

      return htmlParts;
    }

    const htmlBody = getHtmlParts(payload)
      .map((encoded) => Buffer.from(encoded, 'base64url').toString('utf8'))
      .join('');

    return FlightUpdateEmailSchema.parse(this.parseFlightUpdateEmail(cheerio.load(htmlBody)));
  }

  

  parseFlightUpdateEmail(
    $: cheerio.CheerioAPI,
  ): z.infer<typeof FlightUpdateEmailSchema> {
    // "Prices updated October 22, 2026 at 05:44 GMT" -> reference for missing years
    // The footer div sits right after the div wrapping the flights table
    const pricesUpdatedText = $('table[bgcolor="#ffffff"]')
      .first()
      .parent()
      .next('div')
      .find(`div:contains("${localeConfig.pricesUpdated}"):not(:has(div))`)
      .first()
      .text()
      .trim();
    const priceLastUpdatedDateTime = this.parseWithFormat(
      pricesUpdatedText,
      `'${localeConfig.pricesUpdated}' DDD '${localeConfig.at}' HH:mm 'GMT'`,
    ).toISO();
    // TODO:

    const titleEl = $('div[style*="font-weight:700"]').first();
    const summaryRow = titleEl.closest('tr');
    const summaryDivs = titleEl.parent().children('div');

    const [originCityFullLocalized, destinationCityFullLocalized] = titleEl
      .text()
      .split(new RegExp(`\\s+${localeConfig.to}\\s+`, 'i'))
      .map((s) => s.trim());

    const [departureFormatted, returnFormatted] = summaryDivs
      .eq(1)
      .text()
      .split(/[–-]/)
      .map((s) => s.trim());
    const departureDate = this.parseWithFormat(
      departureFormatted,
      `ccc, LLL d`,
    ).toISODate();
    const returnDate = returnFormatted
      ? this.parseWithFormat(returnFormatted, `ccc, LLL d`).toISODate()
      : undefined;

    const passengers = Number(
      /(\d+)\s+adults?/i.exec(summaryDivs.eq(2).text())?.[1] ?? 1,
    );

    const newPrice = parseCurrency(
      this.normalizeSpaces(
        summaryRow.find('span[style*="font-weight:700"]').first().text(),
      ),
    );
    const oldPriceText = this.normalizeSpaces(
      summaryRow.find('[style*="line-through"]').first().text(),
    );
    const oldPrice = oldPriceText ? parseCurrency(oldPriceText) : undefined;

    // First flight row in the table
    const logoEl = $('img[src*="airline_logos"]').first();

    const flightRow = logoEl.closest('tr');
    const details = flightRow.find('td').eq(2);

    const [departureTime, arrivalTime] = details
      .find('div')
      .first()
      .text()
      .split('–')
      .map((text) =>
        this.parseWithFormat(text, `h:mm a`).toISOTime({
          includeOffset: false,
          suppressMilliseconds: true,
        }),
      );
    const [flightOperator, , route] = details
      .find('span')
      .map((_, el) => $(el).text().replace(/·/g, '').trim())
      .get();
    const [originCityIataCode, destinationCityIataCode] = (route ?? '').split(
      /[–-]/,
    );

    return FlightUpdateEmailSchema.parse({
      originCityFullLocalized,
      originCityIataCode,
      destinationCityFullLocalized,
      destinationCityIataCode,
      departureTime,
      arrivalTime,
      departureDate,
      returnDate,
      passengers,
      currencyCode: newPrice.currency,
      newPrice: newPrice.value,
      oldPrice: oldPrice?.value,
      flightOperator,
      flightOperatorLogoImageUrl: logoEl.attr('src'),
      priceLastUpdatedDateTime: priceLastUpdatedDateTime,
    });
  }

  /**
   * Removes invisible unicode spaces from strings
   */
  private normalizeSpaces(text: string) {
    return text.replace(/[\s\u00a0\u202f]+/g, ' ').trim();
  }

  private parseWithFormat(text: string, format: string) {
    const parsed = DateTime.fromFormat(this.normalizeSpaces(text), format, {
      locale: localeConfig.locale,
      zone: 'UTC',
    });

    if (!parsed.isValid) {
      throw new Error(`Could not parse ${text}`);
    }

    return parsed;
  }
}

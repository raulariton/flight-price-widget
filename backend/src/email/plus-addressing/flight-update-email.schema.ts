import { z } from 'zod';

export const FlightUpdateEmail = z.object({
  originCityFullLocalized: z.string().min(1),
  originCityIataCode: z.string().min(2).max(3),
  destinationCityFullLocalized: z.string().min(1),
  destinationCityIataCode: z.string().min(2).max(3),

  departureTime: z.iso.time(),
  arrivalTime: z.iso.time(),

  departureDate: z.iso.date(),
  returnDate: z.iso.date().optional(), // may be one-way trip

  passengers: z.number().min(1),

  currencyCode: z.currencyCode(),
  newPrice: z.number().positive(),
  oldPrice: z.number().positive().optional(), // may be first tracking email

  flightOperator: z.string().min(1),
  flightOperatorLogoImageUrl: z.url(),

  priceLastUpdatedDateTime: z.iso.datetime(),
});

import '../models/flight.dart';

/// Hardcoded sample flights for the prototype.
/// Replace with API calls in production.
final List<Flight> sampleFlights = [
  Flight(
    id: 'flight_001',
    origin: 'SFO',
    destination: 'JFK',
    departureDate: DateTime(2025, 9, 15),
    priceUSD: 289.00,
    airline: 'United Airlines',
  ),
  Flight(
    id: 'flight_002',
    origin: 'LAX',
    destination: 'LHR',
    departureDate: DateTime(2025, 10, 3),
    priceUSD: 621.50,
    airline: 'British Airways',
  ),
  Flight(
    id: 'flight_003',
    origin: 'ORD',
    destination: 'CDG',
    departureDate: DateTime(2025, 11, 20),
    priceUSD: 545.00,
    airline: 'Air France',
  ),
  Flight(
    id: 'flight_004',
    origin: 'MIA',
    destination: 'CUN',
    departureDate: DateTime(2025, 8, 28),
    priceUSD: 174.99,
    airline: 'American Airlines',
  ),
];

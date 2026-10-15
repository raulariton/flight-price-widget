/// Data model representing a single trackable flight.
class Flight {
  final String id;
  final String origin;
  final String destination;
  final DateTime departureDate;
  final double priceUSD;
  final String airline;

  const Flight({
    required this.id,
    required this.origin,
    required this.destination,
    required this.departureDate,
    required this.priceUSD,
    required this.airline,
  });

  /// Human-readable route string, e.g. "SFO → NYC"
  String get route => '$origin → $destination';

  /// Serialise to a plain map for storage in SharedPreferences.
  Map<String, dynamic> toMap() => {
        'id': id,
        'origin': origin,
        'destination': destination,
        'departureDate': departureDate.toIso8601String(),
        'priceUSD': priceUSD,
        'airline': airline,
      };

  factory Flight.fromMap(Map<String, dynamic> map) => Flight(
        id: map['id'] as String,
        origin: map['origin'] as String,
        destination: map['destination'] as String,
        departureDate: DateTime.parse(map['departureDate'] as String),
        priceUSD: (map['priceUSD'] as num).toDouble(),
        airline: map['airline'] as String,
      );
}

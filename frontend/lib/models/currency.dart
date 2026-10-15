/// Supported currencies and their fixed mock conversion rates from USD.
enum Currency {
  usd(code: 'USD', symbol: r'$', rateFromUSD: 1.0),
  eur(code: 'EUR', symbol: '€', rateFromUSD: 0.92),
  gbp(code: 'GBP', symbol: '£', rateFromUSD: 0.79),
  cad(code: 'CAD', symbol: 'C\$', rateFromUSD: 1.37);

  const Currency({
    required this.code,
    required this.symbol,
    required this.rateFromUSD,
  });

  final String code;
  final String symbol;

  /// Fixed conversion rate relative to 1 USD (mock data for prototype).
  final double rateFromUSD;

  /// Convert a USD price to this currency.
  double convert(double usdPrice) => usdPrice * rateFromUSD;

  /// Format a converted price with symbol and two decimal places.
  String format(double usdPrice) =>
      '$symbol${convert(usdPrice).toStringAsFixed(2)}';

  static Currency fromCode(String code) =>
      Currency.values.firstWhere((c) => c.code == code,
          orElse: () => Currency.usd);
}

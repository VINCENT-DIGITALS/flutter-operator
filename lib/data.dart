class Coin {
  final int id;
  final String name;
  final String chainName;
  final double price;
  final double change24h;

  Coin({
    required this.id,
    required this.chainName,
    required this.name,
    required this.price,
    required this.change24h,
  });
}

List<Coin> coins = [
  Coin(
      id: 1,
      name: 'Bitcoin',
      chainName: 'BTC',
      price: 40000.00,
      change24h: 2.5),
  Coin(
      id: 2,
      name: 'Ethereum',
      chainName: 'ETH',
      price: 2500.00,
      change24h: -1.2),
  Coin(
      id: 3,
      name: 'Binance Coin',
      chainName: 'BNB',
      price: 350.00,
      change24h: 0.8),
  Coin(id: 4, name: 'Cardano', chainName: 'ADA', price: 1.20, change24h: 3.1),
  Coin(id: 5, name: 'Ripple', chainName: 'XRP', price: 0.85, change24h: -0.5),
  Coin(id: 6, name: 'Solana', chainName: 'SOL', price: 150.00, change24h: 4.2),
  Coin(id: 7, name: 'Polkadot', chainName: 'DOT', price: 30.00, change24h: 2.0),
  Coin(
      id: 8, name: 'Dogecoin', chainName: 'DOGE', price: 0.25, change24h: -1.0),
  Coin(
      id: 9,
      name: 'Chainlink',
      chainName: 'LINK',
      price: 25.00,
      change24h: 1.5),
  Coin(
      id: 10,
      name: 'Litecoin',
      chainName: 'LTC',
      price: 200.00,
      change24h: 0.3),
  Coin(id: 11, name: 'Uniswap', chainName: 'UNI', price: 20.00, change24h: 2.8),
  Coin(
      id: 12,
      name: 'Avalanche',
      chainName: 'AVAX',
      price: 60.00,
      change24h: 3.5),
  Coin(
      id: 13,
      name: 'Shiba Inu',
      chainName: 'SHIB',
      price: 0.000028,
      change24h: -2.1),
  Coin(id: 14, name: 'Terra', chainName: 'LUNA', price: 45.00, change24h: 4.0),
  Coin(id: 15, name: 'Cosmos', chainName: 'ATOM', price: 15.00, change24h: 1.2),
  Coin(id: 16, name: 'VeChain', chainName: 'VET', price: 0.12, change24h: -0.8),
  Coin(
      id: 17, name: 'Filecoin', chainName: 'FIL', price: 75.00, change24h: 0.7),
  Coin(id: 18, name: 'Tron', chainName: 'TRX', price: 0.08, change24h: 1.9),
  Coin(id: 19, name: 'Theta', chainName: 'THETA', price: 6.00, change24h: -1.5),
  Coin(id: 20, name: 'Tezos', chainName: 'XTZ', price: 5.00, change24h: 2.2),
  Coin(id: 21, name: 'Monero', chainName: 'XMR', price: 240.00, change24h: 0.9),
  Coin(
      id: 22, name: 'Elrond', chainName: 'EGLD', price: 180.00, change24h: 3.0),
  Coin(id: 23, name: 'EOS', chainName: 'EOS', price: 4.00, change24h: -0.2),
  Coin(id: 24, name: 'IOTA', chainName: 'MIOTA', price: 1.50, change24h: 1.4),
  Coin(id: 25, name: 'Aave', chainName: 'AAVE', price: 300.00, change24h: 2.5),
  Coin(id: 26, name: 'NEO', chainName: 'NEO', price: 40.00, change24h: 1.7),
  Coin(
      id: 27, name: 'Algorand', chainName: 'ALGO', price: 1.20, change24h: 0.6),
  Coin(id: 28, name: 'Dash', chainName: 'DASH', price: 150.00, change24h: -0.4),
  Coin(id: 29, name: 'Zcash', chainName: 'ZEC', price: 120.00, change24h: 0.1),
  Coin(id: 30, name: 'Stellar', chainName: 'XLM', price: 0.40, change24h: 1.0),
];

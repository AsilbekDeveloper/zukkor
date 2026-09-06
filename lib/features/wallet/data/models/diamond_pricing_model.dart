import '../../domain/entities/diamond_pricing.dart';

class DiamondPricingModel {
  const DiamondPricingModel({
    required this.inputUsdPer1mTokens,
    required this.outputUsdPer1mTokens,
    required this.diamondMarkupMultiplier,
    required this.usdPerDiamond,
    required this.charsPerTokenEstimate,
  });

  factory DiamondPricingModel.fromJson(Map<String, dynamic> json) => DiamondPricingModel(
        inputUsdPer1mTokens: (json['input_usd_per_1m_tokens'] as num).toDouble(),
        outputUsdPer1mTokens: (json['output_usd_per_1m_tokens'] as num).toDouble(),
        diamondMarkupMultiplier: (json['diamond_markup_multiplier'] as num).toDouble(),
        usdPerDiamond: (json['usd_per_diamond'] as num).toDouble(),
        charsPerTokenEstimate: json['chars_per_token_estimate'] as int,
      );

  final double inputUsdPer1mTokens;
  final double outputUsdPer1mTokens;
  final double diamondMarkupMultiplier;
  final double usdPerDiamond;
  final int charsPerTokenEstimate;

  DiamondPricing toEntity() => DiamondPricing(
        inputUsdPer1mTokens: inputUsdPer1mTokens,
        outputUsdPer1mTokens: outputUsdPer1mTokens,
        diamondMarkupMultiplier: diamondMarkupMultiplier,
        usdPerDiamond: usdPerDiamond,
        charsPerTokenEstimate: charsPerTokenEstimate,
      );
}

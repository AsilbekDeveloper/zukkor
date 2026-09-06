/// Diamond narxlash formulasi - `GET /wallet/pricing`dan bir marta olinib
/// keshlanadi, shu bilan generatsiya ekrani serverga so'rovsiz, JONLI
/// taxminiy narx ko'rsata oladi (foydalanuvchi hujjat/mavzu/savol sonini
/// o'zgartirganda darhol yangilanadi). Haqiqiy (final) narx baribir har
/// doim backend'da, generatsiya tugagach - haqiqiy token sonidan -
/// hisoblanadi; bu yerdagi hisob-kitob FAQAT taxmin uchun.
/// [[ai_cost_architecture]]
class DiamondPricing {
  const DiamondPricing({
    required this.inputUsdPer1mTokens,
    required this.outputUsdPer1mTokens,
    required this.diamondMarkupMultiplier,
    required this.usdPerDiamond,
    required this.charsPerTokenEstimate,
  });

  final double inputUsdPer1mTokens;
  final double outputUsdPer1mTokens;
  final double diamondMarkupMultiplier;
  final double usdPerDiamond;
  final int charsPerTokenEstimate;

  /// Backend'ning `wallet.diamond_cost_from_tokens`si bilan BIR XIL
  /// formula - ikkalasi bir-biridan mustaqil o'zgarsa, taxmin bilan
  /// haqiqiy narx orasida farq paydo bo'ladi, shuning uchun bu ikkalasi
  /// doim qo'lda sinxronlangan holda saqlanishi kerak.
  int diamondCostFromTokens({required int inputTokens, required int outputTokens}) {
    final double inputCostUsd = (inputTokens / 1000000) * inputUsdPer1mTokens;
    final double outputCostUsd = (outputTokens / 1000000) * outputUsdPer1mTokens;
    final double salePriceUsd = (inputCostUsd + outputCostUsd) * diamondMarkupMultiplier;
    final int diamonds = (salePriceUsd / usdPerDiamond).round();
    return diamonds < 1 ? 1 : diamonds;
  }

  /// Generatsiya BOSHLANISHIDAN oldingi taxmin - chiqish (output) tokenlari
  /// hali noma'lum, shuning uchun har bir savol uchun ~120 token deb
  /// taxmin qilinadi (backend'dagi `wallet.estimate_diamond_cost` bilan
  /// bir xil taxmin).
  int estimateDiamondCost({required int estimatedInputTokens, required int questionCount}) {
    final int estimatedOutputTokens = questionCount * 120;
    return diamondCostFromTokens(inputTokens: estimatedInputTokens, outputTokens: estimatedOutputTokens);
  }

  /// Matn/fayl uzunligidan (belgi yoki bayt soni) taxminiy token soni.
  int estimateInputTokens(int lengthInCharsOrBytes) {
    final int tokens = lengthInCharsOrBytes ~/ charsPerTokenEstimate;
    return tokens < 1 ? 1 : tokens;
  }
}

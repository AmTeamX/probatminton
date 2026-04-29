import '../constants/api_config.dart';

class PriceCalculator {
  PriceCalculator._();

  /// Calculate court cost based on membership status
  static double courtCost({
    required double pricePerHour,
    required int durationHours,
    required bool isMember,
  }) {
    if (isMember) {
      return ApiConfig.memberHourlyRate * durationHours;
    }
    return pricePerHour * durationHours;
  }

  /// Calculate equipment rental cost
  static double equipmentCost({
    required int rackets,
    required int shuttlecocks,
    required int shoes,
  }) {
    return (rackets * ApiConfig.racketPrice) +
        (shuttlecocks * ApiConfig.shuttlecockPrice) +
        (shoes * ApiConfig.shoesPrice);
  }

  /// Calculate total booking price
  static double total({
    required double pricePerHour,
    required int durationHours,
    required bool isMember,
    required int rackets,
    required int shuttlecocks,
    required int shoes,
  }) {
    return courtCost(
          pricePerHour: pricePerHour,
          durationHours: durationHours,
          isMember: isMember,
        ) +
        equipmentCost(
          rackets: rackets,
          shuttlecocks: shuttlecocks,
          shoes: shoes,
        );
  }

  /// Calculate monthly savings for a member
  static double monthlySavings({
    required double pricePerHour,
    required int hoursPerWeek,
  }) {
    final standardMonthly = pricePerHour * hoursPerWeek * 4;
    final memberMonthly = ApiConfig.memberHourlyRate * hoursPerWeek * 4;
    return standardMonthly - memberMonthly;
  }
}

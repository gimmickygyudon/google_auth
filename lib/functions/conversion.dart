String setWeight({required double weight, required double count, double conversion = 1000.0}) {
  double conversionWeight = weight * count;

  String conversionString;
  if (conversionWeight > conversion) {
    conversionWeight = conversionWeight / conversion;
    conversionString = '${conversionWeight.toStringAsFixed(2)} Ton';
  } else {
    conversionString = '${conversionWeight.toString()} Kg';
  }

  return conversionString;
}
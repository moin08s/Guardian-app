class Biometrics {
  final double stressLevel;
  final int heartRate;
  final bool isStrapAttached;
  final bool isI2CConnected; // External sensor bus status
  final int spo2;
  final DateTime lastUpdated;

  Biometrics({
    required this.stressLevel,
    required this.heartRate,
    required this.isStrapAttached,
    required this.isI2CConnected,
    required this.spo2,
    required this.lastUpdated,
  });

  factory Biometrics.fromRealtimeDatabase(Map<dynamic, dynamic> data) {
    // Defaults: We assume it's attached and connected unless told otherwise
    bool strapStatus = true;
    if (data.containsKey('strap')) {
      strapStatus = data['strap'].toString() == "1" || data['strap'].toString() == "true";
    }

    bool i2cStatus = true;
    if (data.containsKey('i2c_bus')) {
      i2cStatus = data['i2c_bus'].toString() == "1" || data['i2c_bus'].toString() == "true";
    }

    return Biometrics(
      stressLevel: double.tryParse(data['stress']?.toString() ?? '0.0') ?? 0.0,
      heartRate: int.tryParse(data['hr']?.toString() ?? '75') ?? 75,
      isStrapAttached: strapStatus,
      isI2CConnected: i2cStatus,
      spo2: int.tryParse(data['spo2']?.toString() ?? '98') ?? 98,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(data['timestamp']?.toString() ?? '0') ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  static Biometrics empty() {
    return Biometrics(
      stressLevel: 0.0,
      heartRate: 75,
      isStrapAttached: true,
      isI2CConnected: true,
      spo2: 98,
      lastUpdated: DateTime.now(),
    );
  }
}

import 'dart:math';
/// NMODM Game Configuration
/// 
/// Represents the immutable configuration of an NMODM game instance.
/// 
/// Parameters:
/// - k: Starting number
/// - m: Range limit (players can add 1 to m-1)
/// - t: Target number to reach
class NmodmConfig {
  final int k;
  final int m;
  final int t;

  const NmodmConfig({
    required this.k,
    required this.m,
    required this.t,
  });

  /// Standard mode configuration
  factory NmodmConfig.standard() {
    return const NmodmConfig(k: 0, m: 10, t: 100);
  }

  /// Random mode configuration
  factory NmodmConfig.random() {
    final Random random = Random();

    int start = random.nextInt(102);
    int range = 3 + random.nextInt(27);
    int target = start + 51 + random.nextInt(151);

    return  NmodmConfig(k: start, m: range, t: target);
  }

  /// Create config from JSON
  factory NmodmConfig.fromJson(Map<String, dynamic> json) {
    return NmodmConfig(
      k: json['k'] as int,
      m: json['m'] as int,
      t: json['t'] as int,
    );
  }

  /// Convert config to JSON
  Map<String, dynamic> toJson() {
    return {
      'k': k,
      'm': m,
      't': t,
    };
  }

  /// Validation
  bool isValid() {
    return m > 1 && k >= 0 && t > k;
  }

  String? getValidationError() {
    if (m <= 1) return 'Range (m) must be greater than 1';
    if (k < 0) return 'Starting number (k) must be non-negative';
    if (t <= k) return 'Target (t) must be greater than starting number (k)';
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NmodmConfig && other.k == k && other.m == m && other.t == t;
  }

  @override
  int get hashCode => Object.hash(k, m, t);

  @override
  String toString() => 'NmodmConfig(k: $k, m: $m, t: $t)';
}
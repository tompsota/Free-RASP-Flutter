import '../../freerasp.dart';

enum BiometricsState { notAvailable, noneEnrolled, active }

extension BiometricsStateX on BiometricsState {
  static BiometricsState fromString(String name) {
    switch (name) {
      case 'NOT_AVAILABLE':
        return BiometricsState.notAvailable;
      case 'NONE_ENROLLED':
        return BiometricsState.noneEnrolled;
      case 'ACTIVE':
        return BiometricsState.active;
      default:
        throw TalsecException(
          message: 'Cannot resolve this data as biometrics state: $name',
        );
    }
  }
}

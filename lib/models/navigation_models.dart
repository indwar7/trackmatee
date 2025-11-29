class OtpVerificationArgs {
  final String phoneNumber;
  final String verificationType; // 'login' or 'reset'
  final String? resetToken;

  OtpVerificationArgs({
    required this.phoneNumber,
    required this.verificationType,
    this.resetToken,
  });
}

class CaptureIdArgs {
  final String userId;
  final bool isAadharCapture;
  final Function(String imagePath) onImageCaptured;

  CaptureIdArgs({
    required this.userId,
    required this.isAadharCapture,
    required this.onImageCaptured,
  });
}

class UserVerificationArgs {
  final String userId;
  final String userName;
  final String userEmail;

  UserVerificationArgs({
    required this.userId,
    required this.userName,
    required this.userEmail,
  });
}

class TripMapsArgs {
  final String tripId;
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;

  TripMapsArgs({
    required this.tripId,
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
  });
}


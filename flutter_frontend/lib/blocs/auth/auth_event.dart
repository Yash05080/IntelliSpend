abstract class AuthEvent {}

class SendOtpEvent extends AuthEvent {
  final String email;
  SendOtpEvent(this.email);
}

class VerifyOtpEvent extends AuthEvent {
  final String email;
  final String otp;
  VerifyOtpEvent(this.email, this.otp);
}

class LogoutEvent extends AuthEvent {}

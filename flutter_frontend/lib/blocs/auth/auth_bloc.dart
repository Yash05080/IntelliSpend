import 'package:finance_manager_app/pages/Login%20page/authservice.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(AuthInitial()) {
    on<SendOtpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await authService.sendOtp(event.email);
        emit(OtpSentState(event.email));
      } catch (e) {
        emit(AuthFailure("Failed to send OTP: $e"));
      }
    });

    on<VerifyOtpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await authService.verifyOtp(event.email, event.otp);
        emit(Authenticated());
      } catch (e) {
        emit(AuthFailure("OTP verification failed: $e"));
      }
    });

    on<LogoutEvent>((event, emit) async {
      await authService.logout();
      emit(AuthInitial());
    });
  }
}

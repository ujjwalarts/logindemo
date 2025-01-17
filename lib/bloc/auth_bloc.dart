import 'package:bloc/bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<SendEmailVerification>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.sendSignInLinkToEmail(event.email);
        emit(AuthEmailVerificationSent()); // Emit the email verification sent state
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

on<SignInWithGoogle>((event, emit) async {
  emit(AuthLoading());
  try {
    bool success = await authRepository.signInWithGoogle();
    if (success) {
      emit(AuthSuccess());
    } else {
      emit(AuthFailure("Google sign-in was canceled."));
    }
  } catch (e) {
    emit(AuthFailure(e.toString()));
  }
});



    on<SignInWithFacebook>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signInWithFacebook();
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}

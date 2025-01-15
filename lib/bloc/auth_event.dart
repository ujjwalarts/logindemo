import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SendEmailVerification extends AuthEvent {
    final String email;

  SendEmailVerification(this.email);

  @override
  List<Object> get props => [email];
}
class SignInWithEmailLink extends AuthEvent {
  final String email;
  final String emailLink;

  SignInWithEmailLink(this.email, this.emailLink);

  @override
  List<Object> get props => [email, emailLink];
}
class SignInWithGoogle extends AuthEvent {}

class SignInWithFacebook extends AuthEvent {}

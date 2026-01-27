/// Auth request/response models
library;

import 'package:equatable/equatable.dart';
import 'user_model.dart';

/// Login Request
class LoginRequest extends Equatable {
  final String emailOrPhone;
  final String password;

  const LoginRequest({required this.emailOrPhone, required this.password});

  Map<String, dynamic> toJson() {
    return {'email_or_phone': emailOrPhone, 'password': password};
  }

  @override
  List<Object?> get props => [emailOrPhone, password];
}

/// Register Request
class RegisterRequest extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;
  final String? referralCode;

  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    this.referralCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'f_name': firstName,
      'l_name': lastName,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      if (referralCode != null) 'referral_code': referralCode,
    };
  }

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phone,
    password,
    passwordConfirmation,
    referralCode,
  ];
}

/// OTP Verification Request
class OtpVerificationRequest extends Equatable {
  final String phone;
  final String otp;

  const OtpVerificationRequest({required this.phone, required this.otp});

  Map<String, dynamic> toJson() {
    return {'phone': phone, 'token': otp};
  }

  @override
  List<Object?> get props => [phone, otp];
}

/// Forgot Password Request
class ForgotPasswordRequest extends Equatable {
  final String emailOrPhone;

  const ForgotPasswordRequest({required this.emailOrPhone});

  Map<String, dynamic> toJson() {
    return {'email_or_phone': emailOrPhone};
  }

  @override
  List<Object?> get props => [emailOrPhone];
}

/// Reset Password Request
class ResetPasswordRequest extends Equatable {
  final String resetToken;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordRequest({
    required this.resetToken,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'reset_token': resetToken,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }

  @override
  List<Object?> get props => [resetToken, password, passwordConfirmation];
}

/// Social Login Request
class SocialLoginRequest extends Equatable {
  final String token;
  final String uniqueId;
  final String email;
  final String medium; // 'google', 'facebook', 'apple'

  const SocialLoginRequest({
    required this.token,
    required this.uniqueId,
    required this.email,
    required this.medium,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'unique_id': uniqueId,
      'email': email,
      'medium': medium,
    };
  }

  @override
  List<Object?> get props => [token, uniqueId, email, medium];
}

/// Auth Response (Login/Register)
class AuthResponse extends Equatable {
  final String token;
  final User user;

  const AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  List<Object?> get props => [token, user];
}

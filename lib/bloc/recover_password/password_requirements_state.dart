import 'package:equatable/equatable.dart';

class PasswordRequirementsState extends Equatable {
  final bool length;
  final bool number;
  final bool lowercase;
  final bool uppercase;
  final bool specialChar;

  const PasswordRequirementsState({
    required this.length,
    required this.number,
    required this.lowercase,
    required this.uppercase,
    required this.specialChar,
  });

  const PasswordRequirementsState.initial()
    : length = false,
      number = false,
      lowercase = false,
      uppercase = false,
      specialChar = false;

  bool allSatisfied() =>
      length && number && lowercase && uppercase && specialChar;

  PasswordRequirementsState copyWith({
    bool? length,
    bool? number,
    bool? lowercase,
    bool? uppercase,
    bool? specialChar,
  }) {
    return PasswordRequirementsState(
      length: length ?? this.length,
      number: number ?? this.number,
      lowercase: lowercase ?? this.lowercase,
      uppercase: uppercase ?? this.uppercase,
      specialChar: specialChar ?? this.specialChar,
    );
  }

  @override
  List<Object> get props => [length, number, lowercase, uppercase, specialChar];
}

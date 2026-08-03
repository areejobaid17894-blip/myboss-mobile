import 'package:equatable/equatable.dart';

class Building extends Equatable {
  const Building({
    required this.id,
    required this.name,
    required this.governorate,
    required this.address,
  });

  final String id;
  final String name;
  final String governorate;
  final String address;

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] as String,
      name: json['name'] as String,
      governorate: json['governorate'] as String,
      address: json['address'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, governorate, address];
}

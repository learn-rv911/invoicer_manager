import '../../utils/json_helpers.dart';

class Company {
  final int id;
  final String name;
  final String? address;
  final int? gstPercent;
  final int? createdBy;
  final DateTime? createdAt;

  Company({
    required this.id,
    required this.name,
    this.address,
    this.gstPercent,
    this.createdBy,
    this.createdAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    id: json['id'] as int,
    name: json['name'] as String,
    address: json['address'] as String?,
    gstPercent: json['gst_percent'] as int?,
    createdBy: json['created_by'] as int?,
    createdAt: parseDateTime(json['created_at']),
  );
}

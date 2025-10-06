import '../../utils/json_helpers.dart';

class Client {
  final int id;
  final String name;
  final String? address;
  final int? gstPercent;
  final int? createdBy;
  final int? companyId;
  final DateTime? createdAt;

  Client({
    required this.id,
    required this.name,
    this.address,
    this.gstPercent,
    this.createdBy,
    this.companyId,
    this.createdAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) => Client(
    id: json['id'] as int,
    name: json['name'] as String,
    address: json['address'] as String?,
    gstPercent: json['gst_percent'] as int?,
    createdBy: json['created_by'] as int?,
    companyId: json['company_id'] as int,
    createdAt: parseDateTime(json['created_at']),
  );
}

import '../../utils/json_helpers.dart';

class Project {
  final int id;
  final String name;
  final String? address;
  final String? status;
  final String? notes;
  final int? createdBy;
  final int companyId;
  final int clientId;
  final DateTime? createdAt;

  Project({
    required this.id,
    required this.name,
    this.address,
    this.status,
    this.notes,
    this.createdBy,
    required this.companyId,
    required this.clientId,
    this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] as int,
    name: json['name'] as String,
    address: json['address'] as String?,
    status: json['status'] as String?,
    notes: json['notes'] as String?,
    createdBy: json['created_by'] as int?,
    companyId: json['company_id'] as int,
    clientId: json['client_id'] as int,
    createdAt: parseDateTime(json['created_at']),
  );
}

class ProjectCreate {
  final String name;
  final String? address;
  final String? status;
  final String? notes;
  final int companyId;
  final int clientId;

  ProjectCreate({
    required this.name,
    this.address,
    this.status,
    this.notes,
    required this.companyId,
    required this.clientId,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    if (address != null) 'address': address,
    if (status != null) 'status': status,
    if (notes != null) 'notes': notes,
    'company_id': companyId,
    'client_id': clientId,
  };
}

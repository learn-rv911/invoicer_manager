class ProjectUpdate {
  final String? name;
  final String? address;
  final String? status;
  final String? notes;

  ProjectUpdate({
    this.name,
    this.address,
    this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (name != null) json['name'] = name;
    if (address != null) json['address'] = address;
    if (status != null) json['status'] = status;
    if (notes != null) json['notes'] = notes;
    return json;
  }
}

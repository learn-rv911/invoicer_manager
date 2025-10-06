class ClientCreate {
  final String name;
  final String? address;
  final int? gstPercent;
  final int companyId;

  ClientCreate({
    required this.name,
    this.address,
    this.gstPercent,
    required this.companyId,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    if (address != null) 'address': address,
    if (gstPercent != null) 'gst_percent': gstPercent,
    'company_id': companyId,
  };
}

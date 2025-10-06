class CompanyCreate {
  final String name;
  final String? address;
  final int? gstPercent;

  CompanyCreate({
    required this.name,
    this.address,
    this.gstPercent,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    if (address != null) 'address': address,
    if (gstPercent != null) 'gst_percent': gstPercent,
  };
}


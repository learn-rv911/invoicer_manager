class ClientUpdate {
  final String? name;
  final String? address;
  final int? gstPercent;

  ClientUpdate({this.name, this.address, this.gstPercent});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (name != null) json['name'] = name;
    if (address != null) json['address'] = address;
    if (gstPercent != null) json['gst_percent'] = gstPercent;
    return json;
  }
}

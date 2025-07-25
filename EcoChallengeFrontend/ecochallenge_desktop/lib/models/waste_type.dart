// WasteType Response model
class WasteTypeResponse {
  final int id;
  final String name;

  WasteTypeResponse({
    required this.id,
    required this.name,
  });

  factory WasteTypeResponse.fromJson(Map<String, dynamic> json) {
    return WasteTypeResponse(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// WasteType Insert Request model
class WasteTypeInsertRequest {
  final String name;

  WasteTypeInsertRequest({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

// WasteType Update Request model
class WasteTypeUpdateRequest {
  final String? name;

  WasteTypeUpdateRequest({
    this.name,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (name != null) data['name'] = name;
    
    return data;
  }
}

// WasteType Request model (for backward compatibility)
class WasteTypeRequest {
  final String name;

  WasteTypeRequest({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

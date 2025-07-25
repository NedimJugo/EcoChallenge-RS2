class SearchResult<T> {
  int? totalCount;
  List<T>? items;

  SearchResult({
    this.totalCount,
    this.items,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return SearchResult<T>(
      totalCount: json['totalCount'],
      items: json['items'] != null 
          ? List<T>.from(json['items'].map((item) => fromJsonT(item)))
          : null,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'totalCount': totalCount,
      'items': items?.map((item) => toJsonT(item)).toList(),
    };
  }
}

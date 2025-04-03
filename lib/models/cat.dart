class cat {
  final int id;
  final String name;

  const cat({required this.id, required this.name});

  factory cat.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'id': int id, 'name': String name} => cat(
        id: id,
        name: name,
      ),
      _ => throw const FormatException('Failed to load cat.'),
    };
  }
}

// models/pest.dart

class Infos {
  final String name;
  final String description;
  final String fulldescription;
  final String imageUrl; // You can use asset path or network URL

  Infos({
    required this.name,
    required this.description,
    required this.imageUrl,
    this.fulldescription = '',
  });
}

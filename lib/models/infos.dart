// models/infos.dart

class Infos {
  final String name;
  final String description;
  final String fulldescription;
  final String imageUrl;

  // optional: "pest" or "disease"
  final String type;

  Infos({
    required this.name,
    required this.description,
    required this.imageUrl,
    this.fulldescription = '',
    this.type = '',
  });
}

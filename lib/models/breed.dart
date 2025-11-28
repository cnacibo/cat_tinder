class Breed {
  final Map<String, String> weight;
  final String id;
  final String name;
  final String? temperament;
  final String? origin;
  final String? countryCodes;
  final String? countryCode;
  final String? lifeSpan;
  final String? wikipediaUrl;
  final String? description;
  final int? adaptability;
  final int? affectionLevel;
  final int? childFriendly;
  final int? dogFriendly;
  final int? energyLevel;
  final int? grooming;
  final int? healthIssues;
  final int? intelligence;
  final int? sheddingLevel;
  final int? socialNeeds;
  final int? strangerFriendly;
  final int? vocalisation;

  Breed({
    required this.weight,
    required this.id,
    required this.name,
    this.temperament,
    this.origin,
    this.countryCodes,
    this.countryCode,
    this.lifeSpan,
    this.wikipediaUrl,
    this.description,
    this.adaptability,
    this.affectionLevel,
    this.childFriendly,
    this.dogFriendly,
    this.energyLevel,
    this.grooming,
    this.healthIssues,
    this.intelligence,
    this.sheddingLevel,
    this.socialNeeds,
    this.strangerFriendly,
    this.vocalisation,
  });

  factory Breed.fromJson(Map<String, dynamic> json) {
    return Breed(
      weight: Map<String, String>.from(json['weight'] ?? {}),
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Breed',
      temperament: json['temperament'],
      origin: json['origin'],
      countryCodes: json['country_codes'],
      countryCode: json['country_code'],
      lifeSpan: json['life_span'],
      wikipediaUrl: json['wikipedia_url'],
      description: json['description'],
      adaptability: json['adaptability'],
      affectionLevel: json['affection_level'],
      childFriendly: json['child_friendly'],
      dogFriendly: json['dog_friendly'],
      energyLevel: json['energy_level'],
      grooming: json['grooming'],
      healthIssues: json['health_issues'],
      intelligence: json['intelligence'],
      sheddingLevel: json['shedding_level'],
      socialNeeds: json['social_needs'],
      strangerFriendly: json['stranger_friendly'],
      vocalisation: json['vocalisation'],
    );
  }
}
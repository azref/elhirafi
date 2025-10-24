class Profession {
  final String id;
  final String conceptKey;
  final Map<String, String> dialectNames;
  final String category;
  final String description;
  final bool isActive;

  Profession({
    required this.id,
    required this.conceptKey,
    required this.dialectNames,
    required this.category,
    required this.description,
    this.isActive = true,
  });

  factory Profession.fromMap(Map<String, dynamic> map) {
    return Profession(
      id: map['id'] ?? '',
      conceptKey: map['conceptKey'] ?? '',
      dialectNames: Map<String, String>.from(map['dialectNames'] ?? {}),
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conceptKey': conceptKey,
      'dialectNames': dialectNames,
      'category': category,
      'description': description,
      'isActive': isActive,
    };
  }

  String getNameByDialect(String dialect) {
    return dialectNames[dialect] ?? dialectNames['AR'] ?? conceptKey;
  }
}

class ProfessionsData {
  final List<Profession> professions = [
    Profession(
      id: 'building',
      conceptKey: 'building',
      dialectNames: {
        'MA': 'بناي',
        'DZ': 'ماصو',
        'TN': 'بنّاي',
        'AR': 'بناء',
      },
      category: 'construction',
      description: 'أعمال البناء والخرسانة',
    ),
    Profession(
      id: 'tiling',
      conceptKey: 'tiling',
      dialectNames: {
        'MA': 'زلايجي',
        'DZ': 'كارلور',
        'TN': 'بلانجي',
        'AR': 'بلاط',
      },
      category: 'construction',
      description: 'أعمال البلاط والزليج',
    ),
    // ... (أضف باقي المهن هنا كما كانت في ملفك الأصلي)
  ];

  List<Profession> getAllProfessions() {
    return professions;
  }

  Profession? getProfessionByConceptKey(String conceptKey) {
    try {
      return professions.firstWhere(
        (profession) => profession.conceptKey == conceptKey,
      );
    } catch (e) {
      return null;
    }
  }

  String getLocalizedProfessionName(String conceptKey, String dialect) {
    final profession = getProfessionByConceptKey(conceptKey);
    return profession?.getNameByDialect(dialect) ?? conceptKey;
  }
}

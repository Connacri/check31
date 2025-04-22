class Signalement {
  final String user;
  final String numero;
  final String? description;
  final String signalePar;
  final String motif;
  final int gravite;
  final DateTime date;

  Signalement({
    required this.user,
    required this.numero,
    this.description,
    required this.signalePar,
    required this.motif,
    required this.gravite,
    required this.date,
  });

  /// Convertir en JSON pour Firestore
  Map<String, dynamic> toJson() => {
        'user': user,
        'numero': numero,
        'description': description,
        'signalePar': signalePar,
        'motif': motif,
        'gravite': gravite,
        'date': date.toIso8601String(),
      };

  static Signalement fromJson(Map<dynamic, dynamic> json) {
    return Signalement(
      user: json['user'] ?? '0',
      numero: json['numero'],
      description: json['description'] ?? '',
      signalePar: json['signalePar'],
      motif: json['motif'],
      gravite: json['gravite'],
      date: DateTime.parse(json['date']),
    );
  }
}

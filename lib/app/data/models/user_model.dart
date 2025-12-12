class UserModel {
  final String name;
  final DateTime birthday;
  final bool isMale;
  final double weight;
  final double height;
  final String? job;
  final int dailyTargetStep;

  UserModel({
    required this.name,
    required this.birthday,
    required this.isMale,
    required this.weight,
    required this.height,
    this.job,
    this.dailyTargetStep = 8000,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      birthday: DateTime.parse(json['birthday']),
      isMale: json['isMale'],
      weight: json['weight'],
      height: json['height'],
      job: json['job'],
      dailyTargetStep: json['dailyTargetStep'] ?? 8000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birthday': birthday.toString(),
      'isMale': isMale,
      'weight': weight,
      'height': height,
      'job': job,
      'dailyTargetStep': dailyTargetStep,
    };
  }
}

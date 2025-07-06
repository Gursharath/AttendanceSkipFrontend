class Course {
  String name;
  int totalClasses;
  int attendedClasses;

  Course({
    required this.name,
    required this.totalClasses,
    required this.attendedClasses,
  });

  double get attendancePercentage {
    if (totalClasses == 0) return 0;
    return (attendedClasses / totalClasses) * 100;
  }

  void skipClass() {
    totalClasses += 1;
  }

  void resetSkip() {
    totalClasses -= 1;
  }

  // Convert Course to Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalClasses': totalClasses,
      'attendedClasses': attendedClasses,
    };
  }

  // Create Course from Map for JSON deserialization
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      name: json['name'],
      totalClasses: json['totalClasses'],
      attendedClasses: json['attendedClasses'],
    );
  }
}

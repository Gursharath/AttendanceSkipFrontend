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
}

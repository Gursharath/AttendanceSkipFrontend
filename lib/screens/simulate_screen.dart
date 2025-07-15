import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course_model.dart';

class SimulateScreen extends StatefulWidget {
  final List<Course> courses;

  const SimulateScreen({super.key, required this.courses});

  @override
  State<SimulateScreen> createState() => _SimulateScreenState();
}

class _SimulateScreenState extends State<SimulateScreen> {
  final Set<int> skippedIndices = {};
  late List<Course> simulatedCourses;
  double minimumAttendanceRequired = 75.0; // Default value
  final TextEditingController _attendanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    simulatedCourses =
        widget.courses
            .map(
              (course) => Course(
                name: course.name,
                totalClasses: course.totalClasses,
                attendedClasses: course.attendedClasses,
              ),
            )
            .toList();
    _attendanceController.text = minimumAttendanceRequired.toString();
  }

  @override
  void dispose() {
    _attendanceController.dispose();
    super.dispose();
  }

  void _simulate() {
    setState(() {
      for (var index in skippedIndices) {
        simulatedCourses[index].skipClass();
      }
    });
  }

  void _resetSimulation() {
    setState(() {
      simulatedCourses =
          widget.courses
              .map(
                (course) => Course(
                  name: course.name,
                  totalClasses: course.totalClasses,
                  attendedClasses: course.attendedClasses,
                ),
              )
              .toList();
      skippedIndices.clear();
    });
  }

  void _updateMinimumAttendance() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Set Minimum Attendance',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: TextField(
              controller: _attendanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Minimum Attendance %',
                hintText: 'Enter value (0-100)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.percent),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final value = double.tryParse(_attendanceController.text);
                  if (value != null && value >= 0 && value <= 100) {
                    setState(() {
                      minimumAttendanceRequired = value;
                    });
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter a valid percentage (0-100)',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Set'),
              ),
            ],
          ),
    );
  }

  double get simulatedOverallAttendance {
    int totalAttended = 0;
    int totalClasses = 0;
    for (var course in simulatedCourses) {
      totalAttended += course.attendedClasses;
      totalClasses += course.totalClasses;
    }
    if (totalClasses == 0) return 0;
    return (totalAttended / totalClasses) * 100;
  }

  bool get isOverallAttendanceLow {
    return simulatedOverallAttendance < minimumAttendanceRequired;
  }

  bool isCourseAttendanceLow(Course course) {
    return course.attendancePercentage < minimumAttendanceRequired;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Simulate Skipped Classes',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: _updateMinimumAttendance,
            icon: const Icon(Icons.settings),
            tooltip: 'Set Minimum Attendance',
          ),
          TextButton(
            onPressed: _resetSimulation,
            child: const Text("Reset", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Minimum Attendance Display
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.track_changes, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Minimum Required: ${minimumAttendanceRequired.toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _updateMinimumAttendance,
                    child: Icon(Icons.edit, size: 16, color: Colors.blue[600]),
                  ),
                ],
              ),
            ),
          ),
          // Overall Attendance Display
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color:
                    isOverallAttendanceLow ? Colors.red[100] : Colors.teal[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isOverallAttendanceLow
                            ? Icons.warning
                            : Icons.bar_chart,
                        color:
                            isOverallAttendanceLow ? Colors.red : Colors.teal,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Simulated Overall: ${simulatedOverallAttendance.toStringAsFixed(1)}%',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              isOverallAttendanceLow
                                  ? Colors.red[900]
                                  : Colors.teal[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: simulatedOverallAttendance / 100,
                    color: isOverallAttendanceLow ? Colors.red : Colors.teal,
                    backgroundColor: Colors.grey[300],
                    minHeight: 8,
                  ),
                  if (isOverallAttendanceLow)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Below minimum requirement!',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.red[800],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Courses List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: simulatedCourses.length,
              itemBuilder: (context, index) {
                final course = simulatedCourses[index];
                final isSkipped = skippedIndices.contains(index);
                final isCourseLow = isCourseAttendanceLow(course);

                return Card(
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side:
                        isCourseLow
                            ? BorderSide(color: Colors.red[300]!, width: 2)
                            : const BorderSide(
                              color: Colors.transparent,
                              width: 0,
                            ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isCourseLow ? Colors.red[50] : null,
                    ),
                    child: CheckboxListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      activeColor: Colors.teal,
                      checkboxShape: const CircleBorder(),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              course.name,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isCourseLow ? Colors.red[800] : null,
                              ),
                            ),
                          ),
                          if (isCourseLow)
                            Icon(
                              Icons.warning,
                              color: Colors.red[600],
                              size: 20,
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New: ${course.attendedClasses}/${course.totalClasses} → '
                            '${course.attendancePercentage.toStringAsFixed(1)}%',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: isCourseLow ? Colors.red[700] : null,
                            ),
                          ),
                          if (isCourseLow)
                            Text(
                              'Below minimum requirement!',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.red[600],
                              ),
                            ),
                        ],
                      ),
                      value: isSkipped,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            skippedIndices.add(index);
                          } else {
                            skippedIndices.remove(index);
                            course.totalClasses =
                                widget.courses[index].totalClasses;
                            course.attendedClasses =
                                widget.courses[index].attendedClasses;
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          // Simulate Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                elevation: 6,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _simulate,
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                'Simulate Skip',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

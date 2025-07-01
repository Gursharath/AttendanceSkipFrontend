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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Simulate Skipped Classes',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _resetSimulation,
            child: const Text("Reset", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color:
                    simulatedOverallAttendance >= 75
                        ? Colors.teal[100]
                        : Colors.red[100],
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
                      const Icon(Icons.bar_chart, color: Colors.teal, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Simulated Overall: ${simulatedOverallAttendance.toStringAsFixed(1)}%',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              simulatedOverallAttendance >= 75
                                  ? Colors.teal[900]
                                  : Colors.red[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: simulatedOverallAttendance / 100,
                    color:
                        simulatedOverallAttendance >= 75
                            ? Colors.teal
                            : Colors.red,
                    backgroundColor: Colors.grey[300],
                    minHeight: 8,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: simulatedCourses.length,
              itemBuilder: (context, index) {
                final course = simulatedCourses[index];
                final isSkipped = skippedIndices.contains(index);
                return Card(
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CheckboxListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    activeColor: Colors.teal,
                    checkboxShape: const CircleBorder(),
                    title: Text(
                      course.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'New: ${course.attendedClasses}/${course.totalClasses} → '
                      '${course.attendancePercentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(fontSize: 14),
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
                );
              },
            ),
          ),
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

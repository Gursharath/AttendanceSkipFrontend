import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/course_model.dart';
import '../providers/theme_provider.dart';
import 'add_course_screen.dart';
import 'simulate_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Course> courses = [];

  void _addCourse(Course course) {
    setState(() {
      courses.add(course);
    });
  }

  void _navigateToAddCourse() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddCourseScreen(onAdd: _addCourse)),
    );
  }

  void _navigateToSimulate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SimulateScreen(courses: courses)),
    );
  }

  double get overallAttendance {
    int totalAttended = courses.fold(0, (sum, c) => sum + c.attendedClasses);
    int totalClasses = courses.fold(0, (sum, c) => sum + c.totalClasses);
    if (totalClasses == 0) return 0;
    return (totalAttended / totalClasses) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance Simulator',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: _navigateToSimulate,
          ),
        ],
      ),
      body: Column(
        children: [
          if (courses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: overallAttendance >= 75
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
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.assessment, color: Colors.teal, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'Overall Attendance: ${overallAttendance.toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: overallAttendance >= 75
                            ? Colors.teal[900]
                            : Colors.red[900],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: courses.isEmpty
                ? const Center(
                    child: Text(
                      'No courses added yet.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return Card(
                        elevation: 6,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          title: Text(
                            course.name,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Attended: ${course.attendedClasses}/${course.totalClasses}',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                          trailing: Text(
                            '${course.attendancePercentage.toStringAsFixed(1)}%',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: course.attendancePercentage >= 75
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddCourse,
        label: const Text('Add Course'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

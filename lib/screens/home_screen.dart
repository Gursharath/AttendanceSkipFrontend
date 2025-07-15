import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import '../providers/theme_provider.dart';
import '../utils/course_storage.dart';
import 'add_course_screen.dart';
import 'simulate_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Course> courses = [];
  bool isLoading = true;
  double minimumAttendanceRequired = 75.0; // Default value
  final TextEditingController _attendanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _loadMinimumAttendance();
    _attendanceController.text = minimumAttendanceRequired.toString();
  }

  @override
  void dispose() {
    _attendanceController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    try {
      final loadedCourses = await CourseStorage.loadCourses();
      setState(() {
        courses = loadedCourses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading courses: $e')));
    }
  }

  Future<void> _loadMinimumAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMinimum = prefs.getDouble('minimum_attendance') ?? 75.0;
      setState(() {
        minimumAttendanceRequired = savedMinimum;
        _attendanceController.text = savedMinimum.toString();
      });
    } catch (e) {
      // If SharedPreferences fails, use default value
      setState(() {
        minimumAttendanceRequired = 75.0;
        _attendanceController.text = '75.0';
      });
    }
  }

  Future<void> _saveMinimumAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('minimum_attendance', minimumAttendanceRequired);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving minimum attendance: $e')),
      );
    }
  }

  Future<void> _saveCourses() async {
    try {
      await CourseStorage.saveCourses(courses);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving courses: $e')));
    }
  }

  void _addCourse(Course course) {
    setState(() {
      courses.add(course);
    });
    _saveCourses();
  }

  void _editCourse(Course course, int index) {
    setState(() {
      courses[index] = course;
    });
    _saveCourses();
  }

  void _deleteCourse(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Course', style: GoogleFonts.poppins()),
            content: Text('Are you sure you want to delete this course?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    courses.removeAt(index);
                  });
                  _saveCourses();
                  Navigator.pop(context);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
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
                    _saveMinimumAttendance();
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

  void _navigateToAddCourse() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddCourseScreen(onAdd: _addCourse)),
    );
  }

  void _navigateToEditCourse(Course course, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddCourseScreen(
              onAdd: (editedCourse) => _editCourse(editedCourse, index),
              course: course,
            ),
      ),
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

  bool get isOverallAttendanceLow {
    return overallAttendance < minimumAttendanceRequired;
  }

  bool isCourseAttendanceLow(Course course) {
    return course.attendancePercentage < minimumAttendanceRequired;
  }

  int getClassesNeededToMeetMinimum(Course course) {
    if (course.attendancePercentage >= minimumAttendanceRequired) return 0;

    // Formula: (minimumRequired/100) * (totalClasses + x) = attendedClasses + x
    // Where x is the number of classes needed to attend
    // Solving for x: x = (minimumRequired * totalClasses - 100 * attendedClasses) / (100 - minimumRequired)

    double minRequired = minimumAttendanceRequired;
    int totalClasses = course.totalClasses;
    int attendedClasses = course.attendedClasses;

    if (minRequired >= 100)
      return -1; // Impossible to achieve 100% if already missed classes

    double classesNeeded =
        (minRequired * totalClasses - 100 * attendedClasses) /
        (100 - minRequired);

    return classesNeeded > 0 ? classesNeeded.ceil() : 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

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
            icon: const Icon(Icons.settings),
            onPressed: _updateMinimumAttendance,
            tooltip: 'Set Minimum Attendance',
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: _navigateToSimulate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Minimum Attendance Display
          if (courses.isNotEmpty)
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
                    const Icon(
                      Icons.track_changes,
                      color: Colors.blue,
                      size: 20,
                    ),
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
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Overall Attendance Display
          if (courses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color:
                      isOverallAttendanceLow
                          ? Colors.red[100]
                          : Colors.teal[100],
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isOverallAttendanceLow
                              ? Icons.warning
                              : Icons.assessment,
                          color:
                              isOverallAttendanceLow ? Colors.red : Colors.teal,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Overall Attendance: ${overallAttendance.toStringAsFixed(1)}%',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
                      value: overallAttendance / 100,
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
          Expanded(
            child:
                courses.isEmpty
                    ? const Center(
                      child: Text(
                        'No courses added yet.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        final isCourseLow = isCourseAttendanceLow(course);

                        return Card(
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side:
                                isCourseLow
                                    ? BorderSide(
                                      color: Colors.red[300]!,
                                      width: 2,
                                    )
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
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      course.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isCourseLow
                                                ? Colors.red[800]
                                                : null,
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
                                    'Attended: ${course.attendedClasses}/${course.totalClasses}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color:
                                          isCourseLow ? Colors.red[700] : null,
                                    ),
                                  ),
                                  if (isCourseLow) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Below minimum requirement!',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.blue[300]!,
                                        ),
                                      ),
                                      child: Text(
                                        'Need ${getClassesNeededToMeetMinimum(course)} more classes to reach ${minimumAttendanceRequired.toStringAsFixed(1)}%',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${course.attendancePercentage.toStringAsFixed(1)}%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isCourseLow
                                              ? Colors.red
                                              : Colors.green,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteCourse(index),
                                  ),
                                ],
                              ),
                              onTap: () => _navigateToEditCourse(course, index),
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

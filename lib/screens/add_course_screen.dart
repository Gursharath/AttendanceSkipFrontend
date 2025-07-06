import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course_model.dart';

class AddCourseScreen extends StatefulWidget {
  final void Function(Course) onAdd;
  final Course? course; // For editing existing course

  const AddCourseScreen({super.key, required this.onAdd, this.course});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalController = TextEditingController();
  final _attendedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If editing, populate fields with existing course data
    if (widget.course != null) {
      _nameController.text = widget.course!.name;
      _totalController.text = widget.course!.totalClasses.toString();
      _attendedController.text = widget.course!.attendedClasses.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalController.dispose();
    _attendedController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final course = Course(
        name: _nameController.text.trim(),
        totalClasses: int.parse(_totalController.text.trim()),
        attendedClasses: int.parse(_attendedController.text.trim()),
      );
      widget.onAdd(course);
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.course == null
                ? 'Course added successfully!'
                : 'Course updated successfully!',
          ),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.teal),
      labelStyle: GoogleFonts.poppins(fontSize: 14),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.teal, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.course != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Course' : 'Add Course',
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add_box,
                    size: 48,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isEditing ? 'Edit Course Details' : 'Enter Course Details',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Course Name', Icons.book),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter course name'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _totalController,
                    decoration: _inputDecoration('Total Classes', Icons.class_),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final val = int.tryParse(value ?? '');
                      if (val == null || val < 0) return 'Enter valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _attendedController,
                    decoration: _inputDecoration(
                      'Classes Attended',
                      Icons.check_circle,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final val = int.tryParse(value ?? '');
                      final total = int.tryParse(_totalController.text) ?? 0;
                      if (val == null || val < 0 || val > total) {
                        return 'Invalid attended count';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: Icon(isEditing ? Icons.save : Icons.check),
                      label: Text(isEditing ? 'Update Course' : 'Add Course'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

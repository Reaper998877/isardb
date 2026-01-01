import 'package:flutter/material.dart';
import 'package:isar_db/controller/c_student.dart';
import 'package:isar_db/model/m_student.dart';

final StudentController studentController = StudentController();
// Provides database CRUD functions.

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _mathMarksController = TextEditingController();

  Student? _editingStudent;

  void _saveOrUpdateStudent() async {
    if (_formKey.currentState!.validate()) {
      // Validates input.
      // Stores input from input fields.
      final name = _nameController.text.trim();
      final age = double.tryParse(_ageController.text) ?? 0.0;
      final mathMarks = double.tryParse(_mathMarksController.text) ?? 0.0;

      // Creates a Subject list, which consists of single subject named Math.
      final subjects = <Subject>[
        // This creates a single Subject with:
        // subject name → "Math"
        // marks → the number user typed in UI
        // The cascade operator .. lets you set multiple properties on the same object. Cascade makes the code shorter and cleaner.
        Subject()
          ..name = "Math"
          ..mark = mathMarks,
      ];

      final student = _editingStudent ?? Student();
      // If _editingStudent is null, then final student = Student();
      // If _editingStudent is not null, then final student = _editingStudent;
      // ?? — Null-Coalescing Operator
      // Returns the left value if not null, otherwise the right value.
      student.name = name;
      student.age = age;
      student.marks = subjects;

      await studentController.saveStudent(student); // Adds student data in db.

      _resetForm();
    }
  }

  // Displays current data of student, the user wants to update.
  void _startEditing(Student student) {
    setState(() {
      _editingStudent =
          student; // Stores the student data, the user wants to edit.

      _nameController.text = student.name; // Displays existing name.
      _ageController.text = student.age.toString(); // Displays existing age.

      // Extract Math marks (if available)
      // Fetches the existing marks of student.
      final mathSubject = student.marks.firstWhere(
        // Iterates on every subject in the list.
        (s) => s.name == "Math",
        orElse: () => Subject()
          ..name = "Math"
          ..mark = 0.0,
      );
      // If not found, new object is created.

      _mathMarksController.text = mathSubject.mark
          .toString(); // Displays existing marks.
    });
  }

  // Clears input from input field. // Makes _editingStudent null.
  void _resetForm() {
    setState(() {
      _editingStudent = null;
      _nameController.clear();
      _ageController.clear();
      _mathMarksController.clear();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _mathMarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        title: Text(
          _editingStudent == null
              ? 'Isar Student CRUD (Create)'
              : 'Isar Student CRUD (Update)',
          style: TextStyle(fontFamily: 'poppins'),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildInputForm(),
              const Divider(height: 32, thickness: 1),
              const Text(
                'All Students',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildStudentList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 18.0,
              color: Colors.black,
            ),
            controller: _nameController,
            decoration: const InputDecoration(
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 8.0,
              ),
              labelText: 'Student Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a name' : null,
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 18.0,
              color: Colors.black,
            ),
            controller: _ageController,
            decoration: const InputDecoration(
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 8.0,
              ),
              labelText: 'Age (Double)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Enter age';
              if (double.tryParse(value) == null) return 'Invalid number';
              return null;
            },
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 18.0,
              color: Colors.black,
            ),
            controller: _mathMarksController,
            decoration: const InputDecoration(
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 8.0,
              ),
              labelText: 'Math Marks (Map Value)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Enter marks';
              if (double.tryParse(value) == null) return 'Invalid number';
              return null;
            },
          ),
          const SizedBox(height: 40.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_editingStudent != null)
                // When adding new student this button is hidden.
                // When editing existing student this button is shown.
                TextButton(
                  onPressed: _resetForm,
                  child: const Text(
                    'Cancel Edit',
                    style: TextStyle(fontFamily: 'amaranth'),
                  ),
                ),
              ElevatedButton.icon(
                // Add or Update button
                onPressed: _saveOrUpdateStudent,
                icon: Icon(_editingStudent == null ? Icons.add : Icons.save),
                label: Text(
                  _editingStudent == null ? 'Add Student' : 'Update Student',
                  style: TextStyle(fontFamily: 'amaranth'),
                ),
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 20.0),
                  backgroundColor: Colors.blue.shade800,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    // StreamBuilder automatically rebuilds the UI when data changes via CRUD operations.
    return StreamBuilder<List<Student>>(
      stream: studentController.listenToStudents(), // Provides data stream.
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No students found. Add one above!',
              style: TextStyle(fontFamily: 'poppins'),
            ),
          );
        }

        final students = snapshot.data!; // Stores list of students data.

        return ListView.builder(
          // Displays each student data.
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(child: Text(student.id.toString())),
                title: Text(
                  student.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'poppins',
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Age: ${student.age.toStringAsFixed(1)}',
                      style: TextStyle(fontFamily: 'poppins'),
                    ),
                    Text(
                      'Marks: ${student.marksSummary}',
                      style: TextStyle(fontFamily: 'poppins'),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      // Edit button // Update operation
                      icon: const Icon(Icons.edit, color: Colors.indigo),
                      onPressed: () => _startEditing(student),
                    ),
                    IconButton(
                      // Delete button // Delete operation
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          studentController.deleteStudent(student.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

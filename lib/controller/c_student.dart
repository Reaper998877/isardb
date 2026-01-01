import 'package:isar_community/isar.dart';
import 'package:isar_db/model/m_student.dart';
import 'package:path_provider/path_provider.dart';

// ----------------------------
// ISAR DATABASE SERVICE
// ----------------------------

class StudentController {
  // Holds a future instance of the Isar database
  late Future<Isar> isarDB;

  // Constructor automatically calls openDB() to initialize the database
  StudentController() {
    isarDB = openDB();
  }

  // ----------------------------
  // Opens the Isar database
  // ----------------------------
  // - Ensures only one instance exists (singleton)
  // - Registers the Student schema
  // - Stores DB files in the device's application directory
  // - Enables Isar Inspector during development
  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return Isar.open(
        [StudentSchema], // Register schemas here
        directory: dir.path, // Where database files are stored
        inspector: true, // Enable Isar inspector
      );
    }
    // If already opened, simply return existing instance
    return Future.value(Isar.getInstance());
  }

  // ----------------------------
  // CREATE / UPDATE Student
  // ----------------------------
  // Saves student to database.
  // If student.id exists → record is updated.
  // If student.id does NOT exist → new record is created.
  // All write operations MUST be wrapped inside a writeTxn transaction.
  Future<void> saveStudent(Student student) async {
    final isar = await isarDB;

    // isar.writeTxn() means:
    // “Run the following code as a write transaction inside the database.”
    // ✔ Used for:
    // Inserting, Updating and Deleting data

    await isar.writeTxn(() async {
      await isar.students.put(student); // Insert or update student
    });
  }

  // ----------------------------
  // LISTEN TO ALL STUDENTS (Reactive)
  // ----------------------------
  // Returns a Stream that emits updates whenever:
  // - A student is added
  // - A student is updated
  // - A student is deleted
  //
  // fireImmediately: true → first event emitted instantly
  // watch() gives a stream of database change events
  // then we map it to actual list of students
  Stream<List<Student>> listenToStudents() async* {
    final isar = await isarDB;

    // yield → give one value
    // yield* → give every value from another stream

    yield* isar.students.where().watch(fireImmediately: true).map((_) {
      // Return the updated list of students
      return isar.students.where().findAllSync();
    });

    // the above line is the key to making your UI reactive.
    // ✔ yield* means:
    // “Take another stream and pass (forward) all of its events into my stream.”
    // It does not produce one value
    // It forwards an entire stream from Isar to your UI.
  }

  // ----------------------------
  // DELETE Student by ID
  // ----------------------------
  // Removes a student from the database using their id.
  Future<void> deleteStudent(int id) async {
    final isar = await isarDB;

    await isar.writeTxn(() async {
      await isar.students.delete(id);
    });
  }

  // ----------------------------
  // CUSTOM QUERY: Search Students by Name
  // ----------------------------
  // This performs a case-insensitive search.
  // Example: searching "jo" matches: John, Joana, JOE, etc.
  Future<List<Student>> findStudentsByName(String name) async {
    final isar = await isarDB;

    return isar.students
        .filter()
        .nameContains(name, caseSensitive: false)
        .findAll();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Kullanıcı giriş yapmamış.');
    }

    return user.uid;
  }

  static CollectionReference<Map<String, dynamic>> get _tasksCollection {
    return _firestore.collection('users').doc(_userId).collection('tasks');
  }

  static Stream<List<Map<String, dynamic>>> getTasksStream() {
    return _tasksCollection.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((document) {
        return {'id': document.id, ...document.data()};
      }).toList();
    });
  }

  static Future<void> addTask(Map<String, dynamic> task) async {
    final taskData = Map<String, dynamic>.from(task);

    taskData.remove('id');

    taskData['createdAt'] = FieldValue.serverTimestamp();

    await _tasksCollection.add(taskData);
  }

  static Future<void> updateTask(String taskId, Map<String, dynamic> task) async {
    final taskData = Map<String, dynamic>.from(task);

    taskData.remove('id');

    await _tasksCollection.doc(taskId).update(taskData);
  }

  static Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  static Future<void> deleteCompletedTasks() async {
    final snapshot = await _tasksCollection.where('isDone', isEqualTo: true).get();

    final batch = _firestore.batch();

    for (final document in snapshot.docs) {
      batch.delete(document.reference);
    }

    await batch.commit();
  }
}

import 'package:dio/dio.dart';
import '../models/task_model.dart';

class ApiService {
  static const String BASE_URL =
      'https://smart-task-manager-my9r.onrender.com/api';

  final Dio _dio = Dio();

  Future<List<Task>> fetchTasks({int offset = 0, int limit = 100}) async {
    final response = await _dio.get(
      '$BASE_URL/tasks',
      queryParameters: {'offset': offset, 'limit': limit},
    );

    final List tasksJson = response.data['data'];

    return tasksJson.map((task) => Task.fromJson(task)).toList();
  }

  Future<void> createTask({
    required String title,
    required String description,
    required String category,
    required String priority,
    String? assignedTo,
    DateTime? dueDate,
  }) async {
    final response = await _dio.post(
      '$BASE_URL/tasks',
      data: {
        "title": title,
        "description": description,
        "category": category,
        "priority": priority,
        "assigned_to": assignedTo,
        "due_date": dueDate?.toIso8601String(),
      },
    );
    // Response is now wrapped: { data: {...} }
    // The backend will handle the response
  }

  Future<Map<String, dynamic>?> previewTaskClassification(
    String title,
    String description,
  ) async {
    try {
      final response = await _dio.post(
        '$BASE_URL/tasks/classify',
        data: {"title": title, "description": description},
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }
}

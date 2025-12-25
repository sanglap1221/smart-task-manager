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

  Future<Task> updateTask({
    required String id,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? assignedTo,
    DateTime? dueDate,
    String? status,
  }) async {
    final payload = <String, dynamic>{};
    if (title != null) payload['title'] = title;
    if (description != null) payload['description'] = description;
    if (category != null) payload['category'] = category;
    if (priority != null) payload['priority'] = priority;
    if (assignedTo != null) payload['assigned_to'] = assignedTo;
    if (dueDate != null) payload['due_date'] = dueDate.toIso8601String();
    if (status != null) payload['status'] = status;

    final response = await _dio.patch('$BASE_URL/tasks/$id', data: payload);
    final Map<String, dynamic> json = response.data['data'];
    return Task.fromJson(json);
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

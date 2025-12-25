import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/api_services.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedStatus;
  String? _selectedPriority;
  int _currentPage = 0;
  static const int _pageSize = 10;
  bool _hasMoreTasks = true;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedStatus => _selectedStatus;
  String? get selectedPriority => _selectedPriority;
  bool get hasMoreTasks => _hasMoreTasks;

  // Task count getters
  int get pendingTasksCount =>
      tasks.where((task) => task.status == 'pending').length;
  int get inProgressTasksCount =>
      tasks.where((task) => task.status == 'in_progress').length;
  int get completedTasksCount =>
      tasks.where((task) => task.status == 'completed').length;

  // Filtered tasks getter with search, category, priority, and status filters
  List<Task> get filteredTasks {
    List<Task> filtered = List.from(tasks);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (task) =>
                task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                task.category.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered
          .where((task) => task.category == _selectedCategory)
          .toList();
    }

    // Apply priority filter
    if (_selectedPriority != null) {
      filtered = filtered
          .where((task) => task.priority == _selectedPriority)
          .toList();
    }

    // Apply status filter
    if (_selectedStatus != null) {
      filtered = filtered
          .where((task) => task.status == _selectedStatus)
          .toList();
    }

    return filtered;
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _currentPage = 0;
    notifyListeners();

    _tasks = await _apiService.fetchTasks();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreTasks() async {
    if (_isLoading || !_hasMoreTasks) return;

    _isLoading = true;
    notifyListeners();

    _currentPage++;
    try {
      final moreTasks = await _apiService.fetchTasks(
        offset: _currentPage * _pageSize,
        limit: _pageSize,
      );

      if (moreTasks.isEmpty) {
        _hasMoreTasks = false;
      } else {
        _tasks.addAll(moreTasks);
      }
    } catch (e) {
      _currentPage--;
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setPriorityFilter(String? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedPriority = null;
    _selectedStatus = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> previewClassification(
    String title,
    String description,
  ) async {
    try {
      return await _apiService.previewTaskClassification(title, description);
    } catch (e) {
      return null;
    }
  }

  Future<void> addTask({
    required String title,
    required String description,
    required String category,
    required String priority,
    String? assignedTo,
    DateTime? dueDate,
  }) async {
    await _apiService.createTask(
      title: title,
      description: description,
      category: category,
      priority: priority,
      assignedTo: assignedTo,
      dueDate: dueDate,
    );

    await loadTasks();
  }

  Future<void> updateTask({
    required Task task,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? assignedTo,
    DateTime? dueDate,
    String? status,
  }) async {
    await _apiService.updateTask(
      id: task.id,
      title: title,
      description: description,
      category: category,
      priority: priority,
      assignedTo: assignedTo,
      dueDate: dueDate,
      status: status,
    );

    await loadTasks();
  }

  Future<void> updateTaskStatus({
    required Task task,
    required String status,
  }) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task.copyWith(status: status);
      notifyListeners();
    }

    try {
      await _apiService.updateTask(id: task.id, status: status);
    } catch (e) {
      await loadTasks();
      rethrow;
    }
  }

  Future<void> deleteTask(Task task) async {
    _tasks.removeWhere((t) => t.id == task.id);
    notifyListeners();

    try {
      await _apiService.deleteTask(task.id);
    } catch (e) {
      await loadTasks();
      rethrow;
    }
  }
}

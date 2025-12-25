import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'providers/task_provider.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider()..loadTasks(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: const AppWithOfflineIndicator(),
      ),
    );
  }
}

class AppWithOfflineIndicator extends StatelessWidget {
  const AppWithOfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final isOffline =
            snapshot.hasData &&
            (snapshot.data?.contains(ConnectivityResult.none) ?? false);

        return Column(
          children: [
            if (isOffline)
              Container(
                width: double.infinity,
                color: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.cloud_off, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'You are offline',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const Expanded(child: DashboardScreen()),
          ],
        );
      },
    );
  }
}

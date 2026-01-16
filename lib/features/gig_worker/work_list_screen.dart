import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme.dart';
import '../../models/task_model.dart';
import '../shared/job_card.dart';
import '../../data/repositories/task_repository.dart';

class WorkListScreen extends StatefulWidget {
  const WorkListScreen({super.key});

  @override
  State<WorkListScreen> createState() => _WorkListScreenState();
}

class _WorkListScreenState extends State<WorkListScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await Provider.of<TaskRepository>(context, listen: false).fetchTasks();
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Find Work'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: const Icon(Icons.filter_list, color: AppColors.textMain),
          ),
           Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                context.go('/login');
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSub),
                  hintText: 'Search for gigs...',
                  hintStyle: TextStyle(color: AppColors.textSub.withValues(alpha: 0.5)),
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              
              // Categories
              const Text('Job Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryCard('Retail', Icons.store, AppColors.pastelOrange, AppColors.secondary),
                    const SizedBox(width: 16),
                    _buildCategoryCard('Delivery', Icons.local_shipping, AppColors.pastelGreen, AppColors.success),
                    const SizedBox(width: 16),
                    _buildCategoryCard('Event', Icons.event, AppColors.pastelPurple, AppColors.primary),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Job Matched / Nearby
              const Text('Job Matched', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              
              _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : _tasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 48),
                              Icon(Icons.search_off, size: 64, color: AppColors.textSub.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text('No gigs found nearby.', style: TextStyle(color: AppColors.textSub.withOpacity(0.5), fontSize: 16)),
                              const SizedBox(height: 8),
                              TextButton(onPressed: _loadTasks, child: const Text('Refresh'))
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            return JobCard(
                              task: _tasks[index],
                              onTap: () => context.push('/worker/task-details', extra: _tasks[index]),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color bg, Color iconColor) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text('120 Jobs', style: TextStyle(color: AppColors.textSub.withValues(alpha: 0.8), fontSize: 12)),
        ],
      ),
    );
  }
}

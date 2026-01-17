
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/task_model.dart';

class JobCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const JobCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface, // Use pastel background if preferred, or white surface
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    task.categoryImageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                     errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.pastelOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.business, color: AppColors.secondary),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.companyName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSub,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.bookmark_border, color: AppColors.textSub),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                     _buildTag(context, 'Instant Pay', AppColors.pastelGreen, AppColors.success),
                     const SizedBox(width: 8),
                     _buildTag(context, task.time, AppColors.pastelBlue, AppColors.primary),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.groups_outlined, size: 20, color: AppColors.textSub),
                        const SizedBox(width: 8),
                         Text(
                          '3 Applicants', // Dynamic in real app
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSub,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${task.payout}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textCol,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

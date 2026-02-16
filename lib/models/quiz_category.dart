import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum QuizCategory {
  processingSpeed(
    label: 'Processing Speed',
    description: 'How fast you respond correctly to simple tasks',
    icon: Icons.speed_rounded,
    color: AppColors.processingSpeed,
    metricLabel: 'Avg Response Time',
    metricUnit: 'ms',
  ),
  workingMemory(
    label: 'Working Memory',
    description: 'How much information you can hold short-term',
    icon: Icons.memory_rounded,
    color: AppColors.workingMemory,
    metricLabel: 'Max Sequence',
    metricUnit: 'digits',
  ),
  logicalReasoning(
    label: 'Logical Reasoning',
    description: 'Pattern detection and rule inference',
    icon: Icons.psychology_rounded,
    color: AppColors.logicalReasoning,
    metricLabel: 'Accuracy',
    metricUnit: '%',
  ),
  mathReasoning(
    label: 'Math Reasoning',
    description: 'Multi-step arithmetic and word problems',
    icon: Icons.calculate_rounded,
    color: AppColors.mathReasoning,
    metricLabel: 'Score',
    metricUnit: '/100',
  ),
  reactionTime(
    label: 'Reaction Time',
    description: 'How quickly you react to visual stimuli',
    icon: Icons.bolt_rounded,
    color: AppColors.reactionTime,
    metricLabel: 'Avg Reaction',
    metricUnit: 'ms',
  ),
  attentionControl(
    label: 'Attention Control',
    description: 'Focus under distraction and interference',
    icon: Icons.center_focus_strong_rounded,
    color: AppColors.attentionControl,
    metricLabel: 'Error Rate',
    metricUnit: '%',
  ),
  consistencyScore(
    label: 'Consistency Score',
    description: 'Stability of performance across all tasks',
    icon: Icons.auto_graph_rounded,
    color: AppColors.consistencyScore,
    metricLabel: 'Consistency',
    metricUnit: '/100',
  );

  const QuizCategory({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.metricLabel,
    required this.metricUnit,
  });

  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final String metricLabel;
  final String metricUnit;

  /// Playable categories (excludes consistency which is derived).
  static List<QuizCategory> get playable =>
      values.where((c) => c != consistencyScore).toList();

  /// URL-safe slug for routing.
  String get slug => name
      .replaceAllMapped(RegExp(r'[A-Z]'), (m) => '-${m[0]!.toLowerCase()}')
      .replaceFirst('-', '');

  /// Parse category from route parameter.
  static QuizCategory fromSlug(String slug) {
    return values.firstWhere(
      (c) => c.slug == slug,
      orElse: () => processingSpeed,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_theme.dart';
import '../../providers/review_provider.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final String courtId;
  const ReviewScreen({super.key, required this.courtId});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();

  final _labels = ['', 'Terrible', 'Poor', 'Average', 'Good', 'Excellent'];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(reviewCreationProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                  ),
                  const Text(
                    'Write a Review',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Court info
              Row(
                children: [
                  const Icon(Icons.sports_tennis, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Rate your experience',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Rating question
              const Text(
                'How was your experience?',
                style: TextStyle(fontSize: 16, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              // Stars
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (i) => GestureDetector(
                      onTap: () => setState(() => _rating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedScale(
                          scale: _rating == i + 1 ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            i < _rating ? Icons.star : Icons.star_border,
                            size: 40,
                            color: i < _rating
                                ? Colors.amber
                                : const Color(0xFFE0E0E0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_rating > 0)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _labels[_rating],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              // Comment
              TextFormField(
                controller: _commentController,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Share your thoughts...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              // Error message
              if (creationState is ReviewCreationError)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 20,
                        color: AppTheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          creationState.message,
                          style: const TextStyle(
                            color: AppTheme.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              // Submit
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      _rating == 0 || creationState is ReviewCreationSubmitting
                      ? null
                      : _submitReview,
                  child: creationState is ReviewCreationSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Submit Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    await ref
        .read(reviewCreationProvider.notifier)
        .submitReview(
          courtId: widget.courtId,
          rating: _rating,
          comment: _commentController.text.trim(),
        );

    final state = ref.read(reviewCreationProvider);
    if (state is ReviewCreationSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted! Thank you for your feedback.'),
            backgroundColor: AppTheme.success,
          ),
        );
        context.pop();
      }
    }
    // Error is shown via the state in build()
  }
}

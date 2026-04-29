import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/court.dart';

class CourtCard extends StatelessWidget {
  final Court court;
  const CourtCard({super.key, required this.court});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/court/${court.id}'),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Court Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: court.imageUrl != null
                    ? Image.network(
                        court.imageUrl!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
              const SizedBox(width: AppTheme.md),
              // Court Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            court.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          court.avgRating?.toStringAsFixed(1) ?? "N/A",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${court.reviewCount ?? 0})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      court.location,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          Formatters.currency(court.pricePerHour),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
                          ),
                        ),
                        Text(
                          '/hr',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Text(
                          '  •  ',
                          style: TextStyle(color: AppTheme.textDisabled),
                        ),
                        if (court.distanceKm != null)
                          Text(
                            Formatters.distance(court.distanceKm!),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.sports_tennis, size: 40, color: AppTheme.primary),
    );
  }
}

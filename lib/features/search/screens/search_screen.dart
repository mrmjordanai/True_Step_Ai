import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../shared/widgets/glass_card.dart';

/// Search/Browse screen for finding guides
///
/// Features:
/// - Search bar with voice input
/// - Category filters (All, Cooking, DIY)
/// - Results list with guide cards
/// - Popular guides section
class SearchScreen extends ConsumerStatefulWidget {
  /// Callback when voice input button is tapped
  final VoidCallback? onVoiceTap;

  /// Callback when search query changes
  final void Function(String)? onSearch;

  /// Callback when category filter is selected
  final void Function(String)? onCategorySelected;

  /// Callback when a guide is tapped
  final void Function(String guideId)? onGuideTap;

  const SearchScreen({
    super.key,
    this.onVoiceTap,
    this.onSearch,
    this.onCategorySelected,
    this.onGuideTap,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    widget.onSearch?.call(query);
  }

  void _onCategoryTap(String category) {
    setState(() {
      _selectedCategory = category;
    });
    widget.onCategorySelected?.call(category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrueStepColors.bgPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: TrueStepColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(TrueStepSpacing.lg),
                child: _buildSearchBar(),
              ),

              // Category filters
              _buildCategoryFilters(),
              const SizedBox(height: TrueStepSpacing.md),

              // Results/Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TrueStepSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Browse message
                      _buildBrowseMessage(),
                      const SizedBox(height: TrueStepSpacing.xl),

                      // Popular guides
                      _buildPopularGuides(),
                      const SizedBox(height: TrueStepSpacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: TrueStepColors.glassSurface,
        borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
        border: Border.all(
          color: TrueStepColors.glassBorder,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: TrueStepTypography.body,
        decoration: InputDecoration(
          hintText: 'Search guides...',
          hintStyle: TrueStepTypography.body.copyWith(
            color: TrueStepColors.textTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: TrueStepColors.textTertiary,
          ),
          suffixIcon: GestureDetector(
            onTap: widget.onVoiceTap,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TrueStepColors.accentBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.mic,
                color: TrueStepColors.accentBlue,
                size: 20,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: TrueStepSpacing.md,
            vertical: TrueStepSpacing.md,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: TrueStepSpacing.lg),
      child: Row(
        children: [
          _CategoryChip(
            label: 'All',
            isSelected: _selectedCategory == 'all',
            onTap: () => _onCategoryTap('all'),
          ),
          const SizedBox(width: TrueStepSpacing.sm),
          _CategoryChip(
            label: 'Cooking',
            isSelected: _selectedCategory == 'cooking',
            onTap: () => _onCategoryTap('cooking'),
          ),
          const SizedBox(width: TrueStepSpacing.sm),
          _CategoryChip(
            label: 'DIY',
            isSelected: _selectedCategory == 'diy',
            onTap: () => _onCategoryTap('diy'),
          ),
          const SizedBox(width: TrueStepSpacing.sm),
          _CategoryChip(
            label: 'Electronics',
            isSelected: _selectedCategory == 'electronics',
            onTap: () => _onCategoryTap('electronics'),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseMessage() {
    return GlassCard(
      padding: const EdgeInsets.all(TrueStepSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TrueStepColors.accentBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.explore,
              color: TrueStepColors.accentBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: TrueStepSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse Guides',
                  style: TrueStepTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Search or explore our guide library',
                  style: TrueStepTypography.caption.copyWith(
                    color: TrueStepColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularGuides() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Guides',
          style: TrueStepTypography.title,
        ),
        const SizedBox(height: TrueStepSpacing.md),

        // Popular guide items
        _buildGuideItem(
          title: 'Perfect Scrambled Eggs',
          category: 'Cooking',
          duration: '10 min',
          difficulty: 'Easy',
          icon: Icons.egg,
          color: TrueStepColors.analysisYellow,
        ),
        const SizedBox(height: TrueStepSpacing.md),
        _buildGuideItem(
          title: 'iPhone Screen Replacement',
          category: 'DIY',
          duration: '45 min',
          difficulty: 'Medium',
          icon: Icons.phone_iphone,
          color: TrueStepColors.accentBlue,
        ),
        const SizedBox(height: TrueStepSpacing.md),
        _buildGuideItem(
          title: 'Fix a Running Toilet',
          category: 'DIY',
          duration: '20 min',
          difficulty: 'Easy',
          icon: Icons.plumbing,
          color: TrueStepColors.sentinelGreen,
        ),
      ],
    );
  }

  Widget _buildGuideItem({
    required String title,
    required String category,
    required String duration,
    required String difficulty,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => widget.onGuideTap?.call(title.toLowerCase().replaceAll(' ', '-')),
      child: GlassCard(
        padding: const EdgeInsets.all(TrueStepSpacing.md),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: TrueStepSpacing.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TrueStepTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        category,
                        style: TrueStepTypography.caption.copyWith(
                          color: color,
                        ),
                      ),
                      const SizedBox(width: TrueStepSpacing.sm),
                      Text(
                        '•',
                        style: TrueStepTypography.caption.copyWith(
                          color: TrueStepColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: TrueStepSpacing.sm),
                      Text(
                        duration,
                        style: TrueStepTypography.caption.copyWith(
                          color: TrueStepColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: TrueStepSpacing.sm),
                      Text(
                        '•',
                        style: TrueStepTypography.caption.copyWith(
                          color: TrueStepColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: TrueStepSpacing.sm),
                      Text(
                        difficulty,
                        style: TrueStepTypography.caption.copyWith(
                          color: TrueStepColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.chevron_right,
              color: TrueStepColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Category filter chip
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TrueStepSpacing.md,
          vertical: TrueStepSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? TrueStepColors.accentBlue
              : TrueStepColors.glassSurface,
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
          border: Border.all(
            color: isSelected
                ? TrueStepColors.accentBlue
                : TrueStepColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TrueStepTypography.body.copyWith(
            color: isSelected
                ? TrueStepColors.textPrimary
                : TrueStepColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

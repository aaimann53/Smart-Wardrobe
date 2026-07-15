import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_state.dart';
import '../widgets/category_carousel.dart';
import '../widgets/section_header.dart';

class HomeDashboardBody extends StatefulWidget {
  final void Function(String? category, String? season)? onNavigateToWardrobe;
  final void Function(int page)? onNavigateToPage;

  const HomeDashboardBody({
    super.key,
    this.onNavigateToWardrobe,
    this.onNavigateToPage,
  });

  @override
  State<HomeDashboardBody> createState() => _HomeDashboardBodyState();
}

class _HomeDashboardBodyState extends State<HomeDashboardBody> {
  // Islamabad, Pakistan coordinates
  static const double _latitude = 33.6844;
  static const double _longitude = 73.0479;
  static const String _locationName = 'Islamabad, Pakistan';

  bool _isLoadingWeather = true;
  bool _weatherError = false;
  double? _temperatureC;
  int? _weatherCode;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoadingWeather = true;
      _weatherError = false;
    });

    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$_latitude&longitude=$_longitude'
      '&current=temperature_2m,wind_speed_10m,weather_code',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final current = data['current'] as Map<String, dynamic>;
        setState(() {
          _temperatureC = (current['temperature_2m'] as num).toDouble();
          _weatherCode = (current['weather_code'] as num).toInt();
          _isLoadingWeather = false;
        });
      } else {
        setState(() {
          _weatherError = true;
          _isLoadingWeather = false;
        });
      }
    } catch (_) {
      setState(() {
        _weatherError = true;
        _isLoadingWeather = false;
      });
    }
  }

  /// Maps Open-Meteo WMO weather codes to a short label + icon.
  /// https://open-meteo.com/en/docs (see "WMO Weather interpretation codes")
  ({String label, IconData icon}) _describeWeatherCode(int code) {
    if (code == 0) return (label: 'Clear Sky', icon: Icons.wb_sunny);
    if (code <= 2) return (label: 'Partly Cloudy', icon: Icons.wb_cloudy);
    if (code == 3) return (label: 'Overcast', icon: Icons.cloud);
    if (code == 45 || code == 48) {
      return (label: 'Foggy', icon: Icons.foggy);
    }
    if (code >= 51 && code <= 57) {
      return (label: 'Drizzle', icon: Icons.grain);
    }
    if (code >= 61 && code <= 67) {
      return (label: 'Rainy', icon: Icons.water_drop);
    }
    if (code >= 71 && code <= 77) {
      return (label: 'Snowy', icon: Icons.ac_unit);
    }
    if (code >= 80 && code <= 82) {
      return (label: 'Rain Showers', icon: Icons.water_drop);
    }
    if (code >= 95) {
      return (label: 'Thunderstorm', icon: Icons.thunderstorm);
    }
    return (label: 'Clear', icon: Icons.wb_sunny);
  }

  String _outfitSuggestionFor(int code, double tempC) {
    if (code >= 61 && code <= 82) {
      return 'Grab an umbrella and waterproof shoes today.';
    }
    if (code >= 71 && code <= 77) {
      return 'Bundle up — a warm coat and boots are a must.';
    }
    if (code >= 95) {
      return 'Stay in if you can, or bring a heavy rain jacket.';
    }
    if (tempC <= 10) {
      return 'Perfect day for a warm coat and layers.';
    }
    if (tempC <= 18) {
      return 'Perfect day for a light jacket and jeans.';
    }
    if (tempC <= 26) {
      return 'Light layers should do — comfortable and breezy.';
    }
    return 'Keep it light and breathable today.';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Make the hero carousel feel more like a full-screen banner while
    // still allowing the content below to shift naturally downward.
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = (screenHeight * 0.72).clamp(320.0, 620.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeatherCard(),
          const SizedBox(height: 20),
          CategoryCarousel(
            categories: state.isMaleWardrobe
                ? maleHomeCarouselCategories
                : homeCarouselCategories,
            height: carouselHeight,
            onCategoryTap: (category) {
              String? filterCategory;
              String? filterSeason;
              if (category.filterType == CarouselFilterType.category) {
                filterCategory = category.filterValue;
              } else {
                filterSeason = category.filterValue;
              }
              widget.onNavigateToWardrobe?.call(filterCategory, filterSeason);
            },
          ),
          const SizedBox(height: 20),
          SectionHeader(
            title: 'Recently Added',
            actionLabel: state.clothingItems.isNotEmpty ? 'See All' : null,
            onAction: () => widget.onNavigateToWardrobe?.call(null, null),
          ),
          const SizedBox(height: 12),
          _buildRecentlyAdded(state),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Upcoming Planned Outfits',
            actionLabel: state.plannedOutfits.isNotEmpty ? 'View All' : null,
            onAction: () => widget.onNavigateToPage?.call(2),
          ),
          const SizedBox(height: 12),
          _buildUpcomingOutfits(state),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    Widget content;

    if (_isLoadingWeather) {
      content = const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      );
    } else if (_weatherError || _temperatureC == null || _weatherCode == null) {
      content = Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.white70, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Couldn't load weather",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _fetchWeather,
                    child: const Text(
                      'Tap to retry',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      final weather = _describeWeatherCode(_weatherCode!);
      final tempLabel = '${_temperatureC!.round()}°C';
      final suggestion = _outfitSuggestionFor(_weatherCode!, _temperatureC!);

      content = Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              weather.icon,
              size: 100,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(weather.icon, color: Colors.white, size: 34),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            tempLabel,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            weather.label,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        suggestion,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _locationName,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF3A3A3A), Color(0xFF2A2A2A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: content,
      ),
    );
  }

  Widget _buildRecentlyAdded(AppState state) {
    if (state.clothingItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.softShadow,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.checkroom_outlined,
                  size: 36,
                  color: AppTheme.textSecondary.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 8),
                const Text(
                  'No items yet — tap + to add your first item!',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final ScrollController scrollController = ScrollController();

    return Column(
      children: [
        SizedBox(
          height: 190,
          child: Stack(
            children: [
              ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: state.clothingItems.length,
                itemBuilder: (_, index) {
                  final item = state.clothingItems[index];
                  return SizedBox(
                    width: 140,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                child: kIsWeb
                                    ? Image.network(
                                        item.imageUrl,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Container(
                                          color: AppTheme.surfaceVariant,
                                          child: const Icon(
                                            Icons.broken_image,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      )
                                    : Image.file(
                                        File(item.imageUrl),
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Container(
                                          color: AppTheme.surfaceVariant,
                                          child: const Icon(
                                            Icons.broken_image,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.category,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Left arrow
              Positioned(
                left: 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      scrollController.animateTo(
                        scrollController.offset - 160,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppTheme.textPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),

              // Right arrow
              Positioned(
                right: 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      scrollController.animateTo(
                        scrollController.offset + 160,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.textPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingOutfits(AppState state) {
    final now = DateTime.now();
    final upcoming =
        state.plannedOutfits.entries
            .where((e) => e.key.isAfter(now.subtract(const Duration(days: 1))))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    if (upcoming.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.softShadow,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 32,
                  color: AppTheme.textSecondary.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 8),
                const Text(
                  'No planned outfits — go to Planner to add!',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: upcoming.take(3).expand((entry) {
          return entry.value.map((outfit) {
            final date = entry.key;
            final isToday = isSameDay(date, now);
            final isTomorrow = isSameDay(
              date,
              now.add(const Duration(days: 1)),
            );
            final dateLabel = isToday
                ? 'Today'
                : isTomorrow
                ? 'Tomorrow'
                : '${_monthName(date.month)} ${date.day}';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.checkroom_rounded,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                dateLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              outfit['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              outfit['time'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList();
        }).toList(),
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }
}

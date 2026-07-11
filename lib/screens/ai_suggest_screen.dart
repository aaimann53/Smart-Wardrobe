import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_state.dart';

class AiSuggestScreen extends StatefulWidget {
  const AiSuggestScreen({super.key});

  @override
  State<AiSuggestScreen> createState() => _AiSuggestScreenState();
}

class _AiSuggestScreenState extends State<AiSuggestScreen> {
  String _selectedOccasion = 'Casual';
  String _selectedWeather = 'Sunny';
  bool _isLoading = false;
  String? _suggestion;

  final List<String> _occasions = [
    'Casual',
    'Office',
    'Party',
    'Wedding',
    'Date Night',
    'Gym',
  ];

  final List<String> _weathers = ['Sunny', 'Cloudy', 'Rainy', 'Cold', 'Hot'];

  // Groq API key — passed in at build/run time, never hardcoded.
  // Run with: flutter run --dart-define=GROQ_API_KEY=your_key_here
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');

  Future<void> _getSuggestion() async {
    final state = context.read<AppState>();

    if (state.clothingItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add clothing items to your wardrobe first!'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Missing GROQ_API_KEY. Run with --dart-define=GROQ_API_KEY=your_key',
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      setState(() {
        _suggestion = _buildLocalFallbackSuggestion();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _suggestion = null;
    });

    final wardrobeList = state.clothingItems
        .map((item) => '${item.name} (${item.category}, ${item.color})')
        .join(', ');

    final prompt =
        'I have these clothing items in my wardrobe: $wardrobeList. '
        'Suggest a complete outfit for a $_selectedOccasion occasion '
        'in $_selectedWeather weather. '
        'Be specific about which items to wear and why. '
        'Keep it concise and stylish. '
        'Format: start with the outfit name, then list the items, '
        'then a short style tip.';

    try {
      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': 'llama-3.3-70b-versatile',
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are a helpful fashion stylist. Return a concise outfit suggestion with an outfit name, specific items, and a short style tip.',
                },
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.8,
              'max_tokens': 500,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        final text = content is String
            ? content
            : content is List
            ? content.map((entry) => entry.toString()).join('\n')
            : null;

        if (mounted) {
          setState(() {
            _suggestion =
                text ??
                'Could not generate a suggestion right now. Please try again.';
            _isLoading = false;
          });
        }
      } else {
        final fallback = _buildLocalFallbackSuggestion();
        if (mounted) {
          setState(() {
            _suggestion = fallback;
            _isLoading = false;
          });
        }
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        setState(() {
          _suggestion = _buildLocalFallbackSuggestion();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestion = _buildLocalFallbackSuggestion();
          _isLoading = false;
        });
      }
    }
  }

  String _buildLocalFallbackSuggestion() {
    final state = context.read<AppState>();
    final items = state.clothingItems;

    String pickByCategory(String category) {
      final match = items
          .where((item) => item.category == category)
          .firstOrNull;
      return match?.name ?? '';
    }

    final top = pickByCategory('Tops');
    final bottom = pickByCategory('Bottoms');
    final outerwear = pickByCategory('Outerwear');
    final shoes = pickByCategory('Footwear');
    final fallbackItems = <String>[
      top,
      bottom,
      outerwear,
      shoes,
    ].where((item) => item.isNotEmpty).toList();

    if (fallbackItems.isEmpty) {
      return 'Fallback Outfit: Start by adding a few wardrobe items to unlock personalized AI suggestions.';
    }

    return 'Fallback Outfit: $_selectedOccasion Look\n'
        'Items: ${fallbackItems.join(', ')}\n'
        'Style tip: Keep the tone balanced and add a light layer for ${_selectedWeather.toLowerCase()} weather.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text('AI Style Suggest'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppTheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Outfit Suggester',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Get personalized outfit ideas from your wardrobe',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Occasion selector
            const Text(
              'Occasion',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _occasions.map((occ) {
                final isSelected = _selectedOccasion == occ;
                return GestureDetector(
                  onTap: () => setState(() => _selectedOccasion = occ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textSecondary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      occ,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.background
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Weather selector
            const Text(
              'Weather',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _weathers.map((w) {
                final isSelected = _selectedWeather == w;
                return GestureDetector(
                  onTap: () => setState(() => _selectedWeather = w),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textSecondary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      w,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.background
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Generate button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _getSuggestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.background,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.background,
                        ),
                      )
                    : const Icon(Icons.auto_awesome, size: 22),
                label: Text(
                  _isLoading ? 'Thinking...' : 'Suggest My Outfit',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Suggestion result
            if (_suggestion != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'AI Suggestion',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _suggestion!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _getSuggestion,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Try Again'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: BorderSide(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

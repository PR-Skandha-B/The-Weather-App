import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeatherByCurrentLocation();
    });
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      FocusScope.of(context).unfocus(); // dismiss keyboard
      context.read<WeatherProvider>().fetchWeather(query);
    }
  }

  BoxDecoration _buildBackground(WeatherState state, String? condition) {
    List<Color> colors = [Colors.blue.shade800, Colors.blue.shade400]; // Default

    if (state == WeatherState.success && condition != null) {
      final lowerCondition = condition.toLowerCase();
      if (lowerCondition.contains('clear')) {
        colors = [Colors.orange.shade800, Colors.yellow.shade600];
      } else if (lowerCondition.contains('cloud')) {
        colors = [Colors.grey.shade800, Colors.blueGrey.shade400];
      } else if (lowerCondition.contains('rain') || lowerCondition.contains('drizzle')) {
        colors = [Colors.teal.shade900, Colors.blueGrey.shade700];
      }
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Weather', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          final weatherCondition = provider.weather?.condition;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: _buildBackground(provider.state, weatherCondition),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  await provider.refreshWeather();
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            // Search Bar
                            TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Search for a city...',
                                hintStyle: const TextStyle(color: Colors.white70),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                                  onPressed: provider.isLoading ? null : _submitSearch,
                                ),
                              ),
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) {
                                if (!provider.isLoading) _submitSearch();
                              },
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: _buildContent(provider),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(WeatherProvider provider) {
    switch (provider.state) {
      case WeatherState.initial:
        return Center(
          child: Text(
            'Search for a city to see the weather',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        );
      case WeatherState.loading:
        return const LoadingWidget();
      case WeatherState.success:
        if (provider.weather != null) {
          return WeatherCard(weather: provider.weather!);
        }
        return const SizedBox.shrink();
      case WeatherState.error:
        return CustomErrorWidget(
          errorMessage: provider.errorMessage ?? 'An error occurred',
          onRetry: () => provider.refreshWeather(),
        );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

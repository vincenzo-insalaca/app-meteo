import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../blocs/favorites/favorites_cubit.dart';
import '../../blocs/weather/weather_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C3A6E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          context.l10n.favoritesTitle,
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.cities.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_border,
                    color: Colors.white38,
                    size: 72,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.noFavorites,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.noFavoritesHint,
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: state.cities.length,
            itemBuilder: (context, index) {
              final city = state.cities[index];
              return Dismissible(
                key: ValueKey(city),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red.withValues(alpha: 0.8),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) =>
                    context.read<FavoritesCubit>().toggleFavorite(city),
                child: ListTile(
                  leading: const Icon(Icons.location_city, color: Colors.white70),
                  title: Text(
                    city,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white38,
                  ),
                  onTap: () {
                    context
                        .read<WeatherBloc>()
                        .add(WeatherFetchByCityRequested(city));
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

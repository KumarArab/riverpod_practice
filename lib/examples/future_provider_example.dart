import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum City { Mysore, Banglore, Bokaro, Kashmir }

final currentCityProvider = StateProvider<City?>((ref) => null);

typedef WeatherEmoji = String;

Future<WeatherEmoji> getWeather(City city) async {
  return Future.delayed(const Duration(seconds: 1), () {
    return {
      City.Mysore: '🍃',
      City.Banglore: '🌦️',
      City.Bokaro: '🌞',
      City.Kashmir: '❄️'
    }[city]!;
  });
}

final FutureProvider<WeatherEmoji> weatherProvider = FutureProvider((ref) {
  final city = ref.watch(currentCityProvider);
  if (city != null) {
    return getWeather(city);
  } else {
    return '𖡄';
  }
});

class FutureProviderExample extends ConsumerWidget {
  const FutureProviderExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCityWeather = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("Futurepovider"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            alignment: Alignment.center,
            height: 100,
            child: currentCityWeather.when(
                data: (data) => Text(
                      data,
                      style: const TextStyle(fontSize: 80),
                    ),
                error: (error, stackTrace) => Text(stackTrace.toString()),
                loading: () => const CircularProgressIndicator(strokeWidth: 1)),
          ),
          ListView.builder(
            padding: const EdgeInsets.all(4),
            itemBuilder: (context, index) {
              final currentCity = ref.watch(currentCityProvider);
              bool isSelected = currentCity == City.values[index];
              return ListTile(
                title: Text(City.values[index].name),
                trailing: isSelected ? Icon(Icons.check) : null,
                onTap: () {
                  ref.read(currentCityProvider.notifier).state =
                      City.values[index];
                },
              );
            },
            itemCount: City.values.length,
            shrinkWrap: true,
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(),
    );
  }
}

enum City { Mysore, Banglore, Bokaro, Kashmir }

typedef WeatherEmoji = String;

Future<WeatherEmoji> getWeather(City? city) async {
  return {
        'Mysore': '🍃',
        'Banglore': '🌦️',
        'Bokaro': '☀️',
        'Kashmir': '❄️'
      }[city] ??
      '🤷🏼‍♂️';
}

final StateProvider<City?> currentCityProvider =
    StateProvider<City?>((ref) => null);

final weatherProvider = FutureProvider<WeatherEmoji>((ref) {
  final city = ref.watch(currentCityProvider);
  return getWeather(city);
});

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riverpod Practice"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Consumer(
            builder: (context, ref, child) {
              final currentWeather = ref.watch(weatherProvider);
              return currentWeather.when(
                data: (data) {
                  return Text(data);
                },
                error: (error, stackTrace) => Text("Something went wrong"),
                loading: () => CircularProgressIndicator(),
              );
            },
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: City.values.length,
            itemBuilder: (context, index) {
              final City? city = ref.watch(currentCityProvider);
              bool isSelected = City.values[index] == currentCityProvider;
              return ListTile(
                title: Text(city.toString()),
                leading: isSelected ? Icon(Icons.check) : null,
              );
            },
          )
        ],
      ),
    );
  }
}

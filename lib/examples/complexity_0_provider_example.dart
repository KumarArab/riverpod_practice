// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

@immutable
class Person {
  final String name;
  final int age;
  final String? uid;
  Person({
    required this.name,
    required this.age,
    String? uid,
  }) : uid = uid ?? const Uuid().v4();

  Person updated([String? name, int? age]) =>
      Person(name: name ?? this.name, age: age ?? this.age, uid: uid);

  get displayName => "$name ($age year old)";

  @override
  bool operator ==(covariant Person other) => uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() => "Person with \nname: $name \nage: $age \nuid: $uid";
}

class DataModel extends ChangeNotifier {
  final List<Person> _people = [];

  int get length => _people.length;

  UnmodifiableListView<Person> get people => UnmodifiableListView(_people);

  void add(Person person) {
    _people.add(person);
    notifyListeners();
  }

  void remove(Person person) {
    _people.remove(person);
    notifyListeners();
  }

  void update(Person person) {
    int i = _people.indexWhere((p) => p.uid == person.uid);
    if (i != -1) {
      _people[i] = _people[i].updated(person.name, person.age);
      notifyListeners();
    }
  }
}

final peopleProvider = ChangeNotifierProvider((_) => DataModel());

class Complexity0ProviderExample extends ConsumerWidget {
  const Complexity0ProviderExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complexity0Provider"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openEntryDialog(context: context).then((person) {
            if (person != null) {
              ref.read(peopleProvider).add(person);
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final DataModel dataModel = ref.watch(peopleProvider);
          return ListView.builder(
            shrinkWrap: true,
            itemCount: dataModel.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(dataModel.people[index].displayName),
                onTap: () {
                  openEntryDialog(
                          context: context,
                          existingPerson: dataModel.people[index])
                      .then((person) {
                    if (person != null) {
                      ref.read(peopleProvider).update(person);
                    }
                  });
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Person?> openEntryDialog(
      {required context, Person? existingPerson}) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ageController = TextEditingController();

    String name = existingPerson?.name ?? '';
    int age = existingPerson?.age ?? 0;
    if (existingPerson != null) {
      nameController.text = name;
      ageController.text = age.toString();
    }

    return await showDialog<Person?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingPerson == null ? 'Create User' : 'Update User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                onChanged: (value) => name = value,
                decoration:
                    const InputDecoration(hintText: "Enter name here.."),
              ),
              TextField(
                controller: ageController,
                onChanged: (value) => age = int.tryParse(value) ?? 0,
                decoration: const InputDecoration(hintText: "Enter age here.."),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (existingPerson != null) {
                  //User already exists, updating it
                  final updatedPerson = existingPerson.updated(name, age);
                  Navigator.pop(context, updatedPerson);
                } else {
                  //No existing user, creating new one
                  final person = Person(name: name, age: age);
                  Navigator.pop(context, person);
                }
              },
              child: Text(existingPerson == null ? "Create" : "Update"),
            ),
          ],
        );
      },
    );
  }
}

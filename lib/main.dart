import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() => runApp(MyApp());

class Pokemon {
  final String name;
  final String imageUrl;
  final String url; // Add the URL field to store the Pokemon's API URL

  Pokemon(this.name, this.imageUrl, this.url);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Pokemon>> pokemonData;

  Future<List<Pokemon>> fetchPokemonData() async {
    var url = Uri.https('pokeapi.co', '/api/v2/pokemon');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];

      List<Pokemon> pokemonList = results.map((result) {
        String name = result['name'];
        String imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/animated/back/132.gif';
        String pokemonUrl = result['url']; // Get the Pokemon's API URL
        return Pokemon(name, imageUrl, pokemonUrl);
      }).toList();

      return pokemonList;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    pokemonData = fetchPokemonData();
  }

  Future<void> showPokemonDetails(String url) async {
    var response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final String pokemonName = data['name'];
    final int pokemonHeight = data['height'];
    final int pokemonWeight = data['weight'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de $pokemonName'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Nombre: $pokemonName'),
              Text('Altura: $pokemonHeight'),
              Text('Peso: $pokemonWeight'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  } else {
    // Handle error
    print('Failed to fetch Pokemon details');
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista en Flutter'),
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: pokemonData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].name),
                  leading: GestureDetector(
                    onTap: () {
                      showPokemonDetails(snapshot.data![index].url);
                    },
                    child: Image.network(snapshot.data![index].imageUrl),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          return Container(); // Return an empty container by default
        },
      ),
    );
  }
}


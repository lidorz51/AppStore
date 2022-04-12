import 'dart:convert';

import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:matrix_mobile/data.dart';
import 'package:matrix_mobile/favorite.dart';
import 'package:shared_preferences/shared_preferences.dart';

// get data from api
Future<Data> fetchApps(String api) async {
  final response = await http.get(Uri.parse(
      api));

  if (response.statusCode == 200) {
    return Data.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}

// Home Page
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<String> app = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      SharedPreferences? prefs = await SharedPreferences.getInstance();
      app = (prefs.getStringList("appList") ?? [].cast<String>()) ;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        _selectedIndex = index;
        if (_selectedIndex == 1) {
          SharedPreferences? prefs = await SharedPreferences.getInstance();
          app = (prefs.getStringList("appList") ?? [].cast<String>()) ;

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Favorite(app: app)),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Used for removing back buttoon.
        title: const Text("AppStore Assignment"),
      ),
      body: FutureBuilder<Data>(
        future: fetchApps('https://rss.applemarketingtools.com/api/v2/us/apps/top-free/10/apps.json'),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: <Widget>[
                Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(top: 30.0, bottom: 30.0),
                      child: Text(
                        snapshot.data!.title,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    )),
                SizedBox(
                  height: 150, // Constrain height.
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.res.length,
                    separatorBuilder: (context, _) => const SizedBox(
                      width: 12,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        height: 200,
                        width: 250,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FavoriteButton(
                                iconSize: 30,
                                isFavorite: app.contains(
                                    snapshot.data!.res[index]['artworkUrl100'] +
                                        "#" +
                                        snapshot.data!.res[index]['name']),
                                iconColor: Colors.pink[500],
                                valueChanged: (_isFavorite) async {
                                  if (_isFavorite == true) {
                                    app.add(snapshot.data!.res[index]
                                            ['artworkUrl100'] +
                                        "#" +
                                        snapshot.data!.res[index]['name']);
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setStringList('appList', app);
                                  } else {
                                    app.remove(snapshot.data!.res[index]
                                            ['artworkUrl100'] +
                                        "#" +
                                        snapshot.data!.res[index]['name']);
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setStringList('appList', app);
                                  }
                                },
                              ),
                            ),
                            Image.network(
                                snapshot.data!.res[index]['artworkUrl100']),
                            Text(
                              snapshot.data!.res[index]['name'],
                              style: const TextStyle(fontSize: 13),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ConstrainedBox(
                  constraints:
                      const BoxConstraints(minHeight: 100, maxHeight: 314),
                  child: FutureBuilder<Data>(
                    future: fetchApps('https://rss.applemarketingtools.com/api/v2/us/apps/top-paid/25/apps.json'),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: <Widget>[
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      top: 30.0, bottom: 30.0),
                                  child: Text(
                                    snapshot.data!.title,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                )),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                padding: const EdgeInsets.all(8),
                                itemCount: snapshot.data!.res.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      height: 70,
                                      width: 100,
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                Image.network(
                                                  snapshot.data!.res[index]
                                                      ['artworkUrl100'],
                                                  height: 50,
                                                  width: 50,
                                                ),
                                                const Spacer(),
                                                Text(
                                                  snapshot.data!.res[index]
                                                      ['name'],
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                const Spacer(flex: 10),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: FavoriteButton(
                                                    iconSize: 30,
                                                    isFavorite: app.contains(
                                                        snapshot.data!
                                                                    .res[index]
                                                                [
                                                                'artworkUrl100'] +
                                                            "#" +
                                                            snapshot.data!
                                                                    .res[index]
                                                                ['name']),
                                                    iconColor: Colors.pink[500],
                                                    valueChanged:
                                                        (_isFavorite) async {
                                                      if (_isFavorite == true) {
                                                        app.add(snapshot
                                                                    .data!
                                                                    .res[index][
                                                                'artworkUrl100'] +
                                                            "#" +
                                                            snapshot.data!
                                                                    .res[index]
                                                                ['name']);
                                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                                        prefs.setStringList('appList', app);
                                                      } else {
                                                        app.remove(snapshot
                                                                    .data!
                                                                    .res[index][
                                                                'artworkUrl100'] +
                                                            "#" +
                                                            snapshot.data!
                                                                    .res[index]
                                                                ['name']);
                                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                                          prefs.setStringList('appList', app);
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }
                      return Text('${snapshot.error}');
                    },
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

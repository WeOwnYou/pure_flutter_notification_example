import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:list_view_divider/artists_data.dart';
import 'package:list_view_divider/fetch_file.dart';

const channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  importance: Importance.max,
);
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  print(message.data);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print(await FirebaseMessaging.instance.getToken());
  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterDemo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: const Navigation(),
      // const Navigation('Navigation'),
    );
  }
}

class Navigation extends StatelessWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: SizedBox(
          width: MediaQuery.of(context).size.width * 0.45,
          child: const _CustomDrawer(title: 'Home')),
    );
  }
}

class _CustomDrawer extends StatelessWidget {
  final String title;
  const _CustomDrawer({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          //Header
          Container(
            width: double.infinity,
            color: Colors.blue,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            child: Column(
              children: const [
                FlutterLogo(
                  size: 52,
                ),
                Text(
                  'Header',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10)
              ],
            ),
          ),
          // Body
          ListTile(
            selected: title == 'Home',
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const Navigation(),
                ),
              );
            },
          ),
          ListTile(
            selected: title == 'Artists',
            leading: const Icon(Icons.people),
            title: const Text('Artists'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const ArtistsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
    );
  }
}

class ArtistsPage extends StatefulWidget {
  const ArtistsPage({Key? key}) : super(key: key);

  @override
  State<ArtistsPage> createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage> {
  List<ArtistsData> artists = [];
  String title = 'Artists';

  Future<List<ArtistsData>> loadArtistsData() async {
    // final String jsonData = await fetchFileFromAssets('assets/artists.json');
    // final list = json.decode(jsonData) as List<dynamic>;
    final String list = await fetchFileFromAssets('assets/artists.json');
    final artistsList = artistsDataFromJson(list);
    return artistsList;
  }

  void loadData() async {
    await loadArtistsData();
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
              onPressed: () {
                title = 'Refreshed Artists';
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      drawer: const _CustomDrawer(
        title: 'Artists',
      ),
      body: FutureBuilder<List<ArtistsData>>(
        future: loadArtistsData(),
        builder:
            (BuildContext context, AsyncSnapshot<List<ArtistsData>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const Center(
                child: Text('Connection Error'),
              );
            case ConnectionState.active:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasData) {
                artists = snapshot.data!;
                return ListView.builder(
                  itemCount: artists.length,
                  itemBuilder: (context, index) {
                    final artist = artists[index];
                    return ListTile(
                      title: Text(artist.name ?? ''),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ArtistDetails(artist: artist),
                          ),
                        );
                      },
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('Artists List is empty'),
                );
              }
          }
        },
      ),
    );
  }
}

class ArtistDetails extends StatelessWidget {
  final ArtistsData artist;
  const ArtistDetails({required this.artist, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(artist.name ?? 'No name artist'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(artist.about ?? 'No About Data'),
        ),
      ),
    );
  }
}

// Drawer drawerForPage(String pageName, BuildContext context) => Drawer(
//     child: SafeArea(
//         child: Column(
//           children: [
//             TextButton(
//                 onPressed: () {
//                   Navigator.of(context)
//                       .push(MaterialPageRoute(builder: (BuildContext context) {
//                     return const Navigation('Navigation');
//                   }));
//                 },
//                 style: ButtonStyle(
//                     foregroundColor: MaterialStateProperty.all(
//                         pageName == 'Home' ? Colors.black : Colors.blue)),
//                 child: const Text('Home')),
//             TextButton(
//                 onPressed: () {
//                   Navigator.of(context)
//                       .push(MaterialPageRoute(builder: (BuildContext context) {
//                     return const ArtistsPage();
//                   }));
//                 },
//                 style: ButtonStyle(
//                     foregroundColor: MaterialStateProperty.all(
//                         pageName == 'Artists' ? Colors.black : Colors.blue)),
//                 child: const Text('Artists')),
//           ],
//         )));
//
// class Navigation extends StatefulWidget {
//   final String title;
//   const Navigation(this.title, {Key? key}) : super(key: key);
//
//   @override
//   State<Navigation> createState() => _NavigationState();
// }
//
// class _NavigationState extends State<Navigation> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       drawer: drawerForPage('Home', context),
//     );
//   }
// }
//
// class ArtistsPage extends StatefulWidget {
//   const ArtistsPage({Key? key}) : super(key: key);
//
//   @override
//   State<ArtistsPage> createState() => _ArtistsPageState();
// }
//
// class _ArtistsPageState extends State<ArtistsPage> {
//   // late List<ArtistsData> artists;
//   Future<List<ArtistsData>> getDataFromJson() async {
//     // print('dsffsd');
//     final jsonData = await fetchFileFromAssets('assets/artists.json');
//     final list = json.decode(jsonData) as List<dynamic>;
//     // throw Exception();
//     /*artists*/ return list.map((e) => ArtistsData.fromJson(e)).toList();
//     // print('end');
//   }
//
//   List<Widget> artistsNames(artistsData) {
//     List<Widget> names = [];
//     for (ArtistsData data in artistsData) {
//       names.add(GestureDetector(
//         onTap: () {
//           Navigator.of(context)
//               .push(MaterialPageRoute(builder: (BuildContext context) {
//             return AboutArtists(null, data.name ?? '', data.about ?? '');
//           }));
//         },
//         child: Padding(
//           padding: const EdgeInsets.only(top: 20, bottom: 20),
//           child: Text(
//             data.name ?? '',
//             style: const TextStyle(fontSize: 20),
//           ),
//         ),
//       ));
//     }
//     return names;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     getDataFromJson();
//     return Scaffold(
//         appBar: AppBar(),
//         drawer: drawerForPage('Artists', context),
//         body: FutureBuilder(
//           future: getDataFromJson(),
//           builder: (context, data) {
//             if (data.hasError) {
//               return Text('${data.error}');
//             } else if (data.hasData) {
//               return Column(children: [...artistsNames(data.data)]);
//             } else {
//               return const Center(child: CircularProgressIndicator());
//             }
//           },
//         ));
//   }
// }
//
// class AboutArtists extends StatefulWidget {
//   final String artistName, artistAbout;
//   const AboutArtists(Key? key, this.artistName, this.artistAbout)
//       : super(key: key);
//
//   @override
//   State<AboutArtists> createState() => _AboutArtistsState();
// }
//
// class _AboutArtistsState extends State<AboutArtists> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.artistName),
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Text(widget.artistAbout),
//         ),
//       ),
//     );
//   }
// }

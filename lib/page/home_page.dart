import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pinger/assets.dart';
import 'package:pinger/di/injector.dart';
import 'package:pinger/extensions.dart';
import 'package:pinger/model/ping_session.dart';
import 'package:pinger/page/archive_page.dart';
import 'package:pinger/page/intro_page.dart';
import 'package:pinger/page/ping_page.dart';
import 'package:pinger/page/search_page.dart';
import 'package:pinger/page/settings_page.dart';
import 'package:pinger/resources.dart';
import 'package:pinger/store/favorites_store.dart';
import 'package:pinger/store/hosts_store.dart';
import 'package:pinger/store/ping_store.dart';
import 'package:pinger/widgets/home_host_suggestions.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HostsStore _hostsStore = Injector.resolve();
  final FavoritesStore _favoritesStore = Injector.resolve();
  final PingStore _pingStore = Injector.resolve();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => push(SettingsPage()),
        ),
        title: Text("Pinger"),
        centerTitle: true,
        actions: <Widget>[
          SizedBox.fromSize(
            size: Size.square(56.0),
            child: IconButton(
              icon: Icon(Icons.unarchive),
              onPressed: () => push(ArchivePage()),
            ),
          ),
        ],
      ),
      body: Observer(builder: (_) {
        final stats = _hostsStore.stats;
        final favorites = _favoritesStore.items;
        final session = _pingStore.currentSession;
        final hasNoSuggestions =
            stats.isEmpty && favorites.isEmpty && session == null;
        return hasNoSuggestions
            ? _buildNoSuggestions()
            : Builder(
                builder: (context) => HomeHostSuggestions(
                  session: session,
                  favorites: favorites,
                  stats: stats,
                  searchBar: _buildSearchBar(),
                  onItemPressed: (it) => _onHostItemPressed(context, it),
                ),
              );
      }),
    );
  }

  Widget _buildNoSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(children: <Widget>[
        _buildSearchBar(),
        Spacer(),
        Image(image: Images.undrawRoadSign, height: 144.0),
        Container(height: 24.0),
        Text(
          "Looks like there's nothing here yet",
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Container(height: 24.0),
        Text(
          "Use search field above to choose host to ping or see intro explaining app concept",
          style: TextStyle(fontSize: 18.0),
          textAlign: TextAlign.center,
        ),
        Spacer(),
        ButtonTheme.fromButtonThemeData(
          data: R.themes.raisedButton,
          child: RaisedButton(
            child: Text("Show intro"),
            onPressed: () => push(IntroPage()),
          ),
        ),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      style: TextStyle(fontSize: 18.0),
      readOnly: true,
      onTap: () => pushReplacement(SearchPage()),
      decoration: InputDecoration(
        hintText: "Search host to ping",
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        fillColor: R.colors.grayLight,
        filled: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(Icons.search, color: R.colors.gray),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _onHostItemPressed(BuildContext context, String host) {
    final status = _pingStore.currentSession?.status;
    if (status.isNull || status.isInitial || status.isDone) {
      _pingStore.initSession(host);
      push(PingPage());
    } else if (_pingStore.currentSession.host.name == host) {
      push(PingPage());
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Another session in progress"),
        duration: Duration(seconds: 1),
      ));
    }
  }
}

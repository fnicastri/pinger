import 'package:flutter/material.dart';
import 'package:pinger/extensions.dart';
import 'package:pinger/resources.dart';
import 'package:pinger/widgets/tiles/host_tile.dart';

class HostsPage extends StatefulWidget {
  const HostsPage({
    Key key,
    @required this.title,
    @required this.hosts,
    @required this.getTrailingLabel,
    @required this.removeHosts,
    @required this.onHostSelected,
  }) : super(key: key);

  final String title;
  final List<String> hosts;
  final String Function(String) getTrailingLabel;
  final ValueChanged<List<String>> removeHosts;
  final ValueChanged<String> onHostSelected;

  @override
  _HostsPageState createState() => _HostsPageState();
}

class _HostsPageState extends State<HostsPage> {
  List<String> _selection = [];
  bool _isEditing = false;

  void _onEditPressed() {
    if (_isEditing && _selection.isNotEmpty) {
      widget.removeHosts(_selection);
      _selection = [];
    }
    _isEditing = !_isEditing;
    rebuild();
  }

  void _onItemPressed(String host) {
    if (!_isEditing) {
      widget.onHostSelected(host);
    } else {
      _toggleSelection(host);
      rebuild();
    }
  }

  void _onItemLongPress(String host) {
    if (!_isEditing) {
      _isEditing = true;
      _selection.add(host);
    } else {
      _toggleSelection(host);
    }
    rebuild();
  }

  void _toggleSelection(String host) {
    if (!_selection.remove(host)) _selection.add(host);
  }

  void _onBackPressed() {
    if (_isEditing) {
      _selection = [];
      _isEditing = false;
      rebuild();
    } else {
      pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onBackPressed();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: CloseButton(onPressed: _onBackPressed),
          title: Text(!_isEditing ? widget.title : "Remove"),
          centerTitle: true,
          actions: <Widget>[
            SizedBox.fromSize(
              size: Size.square(56.0),
              child: IconButton(
                icon: Icon(_isEditing ? Icons.lock_open : Icons.lock),
                onPressed: _onEditPressed,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: ListView.builder(
            itemCount: widget.hosts.length,
            itemBuilder: (_, index) {
              final item = widget.hosts[index];
              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0.0 : 16.0),
                child: HostTile(
                  host: item,
                  type: !_isEditing
                      ? HostTileType.regular
                      : _selection.contains(item)
                          ? HostTileType.removableSelected
                          : HostTileType.removable,
                  trailing: !_isEditing
                      ? Container(
                          width: 40.0,
                          child: Text(
                            widget.getTrailingLabel(item),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: R.colors.gray,
                              fontSize: 14.0,
                            ),
                          ),
                        )
                      : null,
                  onPressed: () => _onItemPressed(item),
                  onLongPress: () => _onItemLongPress(item),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

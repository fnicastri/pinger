import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pinger/resources.dart';

class PingerBottomSheet extends StatelessWidget {
  static Future<T> show<T>(
    BuildContext context, {
    String title,
    String subtitle,
    String rejectLabel,
    VoidCallback onRejectPressed,
    VoidCallback onAcceptPressed,
    ValueGetter<bool> canAccept,
    Duration duration = const Duration(milliseconds: 300),
    @required Widget builder(VoidCallback rebuild),
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "PingerBottomSheet",
      pageBuilder: (_, __, ___) => null,
      transitionDuration: duration,
      transitionBuilder: (_, transition, __, child) => PingerBottomSheet._(
        title: title,
        subtitle: subtitle,
        rejectLabel: rejectLabel,
        onRejectPressed: onRejectPressed,
        onAcceptPressed: onAcceptPressed,
        canAccept: canAccept,
        transition: transition,
        builder: builder,
      ),
    );
  }

  const PingerBottomSheet._({
    Key key,
    @required this.title,
    @required this.subtitle,
    @required this.rejectLabel,
    @required this.onRejectPressed,
    @required this.onAcceptPressed,
    @required this.canAccept,
    @required this.transition,
    @required this.builder,
  }) : super(key: key);

  static final _blurSigma = 3.0;

  final Animation<double> transition;
  final String title;
  final String subtitle;
  final String rejectLabel;
  final VoidCallback onRejectPressed;
  final VoidCallback onAcceptPressed;
  final ValueGetter<bool> canAccept;
  final Widget Function(VoidCallback) builder;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Positioned.fill(child: _buildBlurLayer(context)),
        // Wrap content in additional builder so that only
        // this widget rebuilds when keyboard is popping up.
        Builder(builder: (context) => _buildSheetLayer(context)),
      ],
    );
  }

  Widget _buildBlurLayer(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: transition.value * _blurSigma,
          sigmaY: transition.value * _blurSigma,
        ),
        child: Container(color: R.colors.none),
      ),
    );
  }

  Widget _buildSheetLayer(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: FractionalTranslation(
        translation: Offset(0.0, 1.0 - transition.value),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 32.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(12.0),
            ),
            color: R.colors.canvas,
            boxShadow: [
              BoxShadow(
                color: R.colors.shadow,
                spreadRadius: 1.0,
                blurRadius: 8.0,
              ),
            ],
          ),
          child: Material(
            child: _buildSheetContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetContent() {
    return StatefulBuilder(
      builder: (_, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null)
            Text(
              title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                subtitle,
                style: TextStyle(color: R.colors.gray),
              ),
            ),
          builder(() => setState(() {})),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (rejectLabel != null)
                ButtonTheme.fromButtonThemeData(
                  data: R.themes.flatButton,
                  child: FlatButton(
                    padding: EdgeInsets.zero,
                    onPressed: onRejectPressed,
                    child: Text(rejectLabel),
                  ),
                ),
              if (rejectLabel != null) Spacer(),
              SizedBox.fromSize(
                size: Size.square(48.0),
                child: RaisedButton(
                  padding: EdgeInsets.zero,
                  onPressed:
                      canAccept == null || canAccept() ? onAcceptPressed : null,
                  child: Icon(Icons.check),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

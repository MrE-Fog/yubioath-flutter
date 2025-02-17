/*
 * Copyright (C) 2022 Yubico.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:async';

import 'package:flutter/material.dart';

import '../message.dart';

abstract class UserInteractionController {
  void updateContent({String? title, String? description, Widget? icon});
  void close();
}

class _UserInteractionController extends UserInteractionController
    with ChangeNotifier {
  final void Function() onClosed;
  String title;
  String description;
  Widget? icon;
  _UserInteractionController({
    required this.onClosed,
    required this.title,
    required this.description,
    this.icon,
  });

  @override
  void close() {
    onClosed();
  }

  @override
  void updateContent({String? title, String? description, Widget? icon}) {
    if (title != null) {
      this.title = title;
    }
    if (description != null) {
      this.description = description;
    }
    if (icon != null) {
      this.icon = icon;
    }
    notifyListeners();
  }
}

class _UserInteractionDialog extends StatefulWidget {
  final _UserInteractionController controller;
  const _UserInteractionDialog({required this.controller});

  @override
  State<_UserInteractionDialog> createState() => _UserInteractionDialogState();
}

class _UserInteractionDialogState extends State<_UserInteractionDialog> {
  void _rebuild() {
    Timer.run(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    Widget? icon = widget.controller.icon;
    return AlertDialog(
      scrollable: true,
      content: SizedBox(
        width: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: IconTheme(
                  data: IconTheme.of(context).copyWith(size: 36),
                  child: icon,
                ),
              ),
            Text(
              widget.controller.title,
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
              widget.controller.description,
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }
}

/// Opens a modal dialog informing the user to take some action.
/// The dialog content can be updated programatically via the returned
/// [UserInteractionController].
///
/// An optional [onCancel] function can be provided to allow the user to cancel
/// the action by tapping outside of the dialog (or pressing Back, etc.).
UserInteractionController promptUserInteraction(
  BuildContext context, {
  required String title,
  required String description,
  Widget? icon,
  void Function()? onCancel,
}) {
  var wasPopped = false;
  final controller = _UserInteractionController(
    title: title,
    description: description,
    icon: icon,
    onClosed: () {
      if (!wasPopped) {
        Navigator.of(context).pop();
      }
    },
  );
  showBlurDialog(
      context: context,
      routeSettings: const RouteSettings(name: 'user_interaction_prompt'),
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            if (onCancel != null) {
              onCancel();
              wasPopped = true;
              return true;
            } else {
              return false;
            }
          },
          child: _UserInteractionDialog(
            controller: controller,
          ),
        );
      });

  return controller;
}

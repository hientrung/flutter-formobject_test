import 'package:flutter/material.dart';
import 'package:formobject/formobject.dart';

abstract class FOEditorBase extends StatelessWidget {
  final FOField field;
  late final String caption;
  late final bool required;
  late final String? hint;

  FOEditorBase({
    super.key,
    required this.field,
  }) {
    caption = field.meta['caption'] ?? field.name;
    required = (field.meta['rules'] as List<dynamic>?)
            ?.any((it) => it['type'] == 'required') ??
        false;
    hint = field.meta['hint'];
  }
}

class FOEditorString extends FOEditorBase {
  FOEditorString({
    super.key,
    required super.field,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        labelText: caption,
      ),
      onChanged: (value) => field.value = value,
    );
  }
}

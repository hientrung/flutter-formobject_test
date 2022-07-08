import 'package:flutter/material.dart';
import 'package:formobject/formobject.dart';

typedef FOEditorCreator = FOEditorBase Function(FOField field);

const registerEditor = FOEditorBase.register;

const editorFor = FOEditorBase.editor;

abstract class FOEditorBase extends StatelessWidget {
  final FOField field;
  late final String caption;
  late final String? help;

  FOEditorBase({
    super.key,
    required this.field,
  }) {
    caption = field.meta['caption'] ?? field.name;
    help = field.meta['help'];
  }

  static final Map<String, FOEditorCreator> templates = {};

  static void register(Map<String, FOEditorCreator> sources) =>
      templates.addAll(sources);

  static Widget editor(FOField field, [String? template]) {
    if (templates.isEmpty) _defaultRegister();
    final arr = <String>{
      if (template != null) template,
      field.fullName,
      field.name,
      field.type.name
    };
    FOEditorCreator? tmpl;
    for (var n in arr) {
      tmpl = templates[n];
      if (tmpl != null) break;
    }
    if (tmpl == null) {
      throw 'Not found editor template: ${arr.join(', ')}';
    }
    return tmpl(field);
  }

  static void _defaultRegister() {
    register({
      'string': (field) => FOEditorProperty.string(field),
      'int': ((field) => FOEditorProperty.int(field)),
      'password': (field) => FOEditorProperty.string(field),
      'expression': (field) => FOEditorProperty.expression(field),
    });
  }
}

class FOEditorForm extends StatelessWidget {
  final FOForm form;

  const FOEditorForm({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    final lst = form.childs.toList();
    return ListView.builder(
      itemCount: lst.length,
      itemBuilder: (ctx, ind) => editorFor(lst[ind]),
    );
  }
}

class FOEditorObject extends FOEditorBase {
  FOEditorObject({super.key, required super.field});

  @override
  Widget build(Object context) {
    final lst = field.childs.toList();
    return Column(
      children: [
        Text(
          caption,
          style: const TextStyle(inherit: true, fontWeight: FontWeight.bold),
          textScaleFactor: 1.2,
        ),
        const SizedBox(
          height: 10,
        ),
        ListView.builder(
          itemCount: lst.length,
          itemBuilder: (ctx, ind) => editorFor(lst[ind]),
        ),
      ],
    );
  }
}

class FOEditorProperty extends FOEditorBase {
  final Widget Function(BuildContext context, FOEditorProperty editor) builder;
  final VoidCallback? onDispose;

  FOEditorProperty({
    required super.field,
    required this.builder,
    super.key,
    this.onDispose,
  });

  bool get isRequired =>
      (field.meta['rules'] as List<dynamic>?)
          ?.any((it) => it['type'] == 'required') ??
      false;

  String? get holder => field.meta['holder'];

  String? get hint => field.meta['hint'];

  @override
  Widget build(BuildContext context) => builder(context, this);

  factory FOEditorProperty.string(FOField field) {
    final ctrl = TextEditingController(text: field.value);
    final sub = field.onChanged((value) {
      if (ctrl.text != value) ctrl.text = value;
    });
    return FOEditorProperty(
      field: field,
      onDispose: () => sub.dispose(),
      builder: (ctx, ed) => TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: ed.hint,
          helperText: ed.help,
          labelText: ed.caption,
        ),
        onChanged: (v) => ed.field.value = v,
      ),
    );
  }

  factory FOEditorProperty.int(FOField field) {
    final ctrl = TextEditingController(
        text: field.value == null ? '' : field.value.toString());
    final sub = field.onChanged((value) {
      final s = value == null ? '' : value.toString();
      if (ctrl.text != s) ctrl.text = s;
    });
    return FOEditorProperty(
      field: field,
      onDispose: () => sub.dispose(),
      builder: (ctx, ed) => TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: ed.hint,
          helperText: ed.help,
          labelText: ed.caption,
        ),
        onChanged: (v) => ed.field.value = int.tryParse(v),
      ),
    );
  }

  factory FOEditorProperty.expression(FOField field) {
    return FOEditorProperty(
      field: field,
      builder: (ctx, ed) => _ExpressionValue(ed),
    );
  }
}

class _ExpressionValue extends StatefulWidget {
  final FOEditorProperty editor;
  const _ExpressionValue(this.editor);

  @override
  State<StatefulWidget> createState() => _ExpressionValueState();
}

class _ExpressionValueState extends State<_ExpressionValue> {
  FOSubscription? sub;
  String value = '';

  @override
  void initState() {
    super.initState();
    subscribe();
  }

  @override
  void didUpdateWidget(covariant _ExpressionValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editor.field != oldWidget.editor.field) subscribe();
  }

  @override
  Widget build(BuildContext context) => Text(value);

  void subscribe() {
    unsubscribe();
    value = widget.editor.field.value;
    sub = widget.editor.field.onChanged((val) {
      setState(() {
        value = val == null ? '' : val.toString();
      });
    });
  }

  void unsubscribe() {
    sub?.dispose();
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }
}

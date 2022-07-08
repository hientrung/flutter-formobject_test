import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:formobject/formobject.dart';
import 'package:formobject_test/foeditor.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(primarySwatch: Colors.blue),
    home: HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  final form = FOForm({
    'data': {
      'firstName': 'Test',
      'lastName': '',
      'password': '',
      'confirm': '',
      'age': 18,
    },
    'meta': {
      ':root': {
        'type': 'object',
        'objectType': 'Root',
      },
      'Root': {
        'firstName': {
          'type': 'string',
          'rules': [
            {'type': 'required', 'message': 'Required'}
          ]
        },
        'lastName': {'type': 'string'},
        'name': {
          'type': 'expression',
          'expression': 'firstName + " " + lastName'
        },
        'password': {
          'type': 'string',
          'rules': [
            {'type': 'required', 'message': 'Required'}
          ]
        },
        'confirm': {
          'type': 'string',
          'rules': [
            {'type': 'required', 'message': 'Required'},
            {
              'type': 'equal',
              'message': 'Not matched',
              'expression': 'password'
            },
          ]
        },
        'age': {
          'type': 'int',
          'rules': [
            {'type': 'range', 'message': 'Must great than 18', 'min': 18}
          ]
        },
      }
    }
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: FOEditorForm(form: form)),
          ),
        ),
      ),
    );
  }

  void onPressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Form data'),
        content: Text(
            true || form.isValid ? json.encode(form.value) : "Invalid data"),
      ),
    );
  }
}

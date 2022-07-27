import 'package:flutter/material.dart';
import 'package:formobject/formobject.dart';

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
      'firstName': 'Testing',
      'lastName': '',
      'password': '',
      'confirm': '',
      'age': null,
      'salary': 1.23,
      'birthday': null,
      'argee': null,
      'accounts': [
        {'name': 'Facebook', 'value': false},
        {'name': 'Google', 'value': false},
      ]
    },
    'meta': {
      ':root': {
        'type': 'object',
        'objectType': 'Root',
      },
      'Root': {
        'firstName': {
          'type': 'string',
          'help': 'Help string',
          'hint': 'Hint text',
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
          'template': 'password',
          'rules': [
            {'type': 'required', 'message': 'Required'},
            {
              'type': 'equal',
              'message': 'Not matched',
              'expression': '^.password'
            },
          ]
        },
        'age': {
          'type': 'int',
          'rules': [
            {'type': 'range', 'message': 'Must great than 18', 'min': 18}
          ]
        },
        'salary': {
          'type': 'double',
        },
        'birthday': {
          'type': 'datetime',
        },
        'agree': {
          'type': 'bool',
          'caption': 'I agree to the terms of use',
          'rules': [
            {'type': 'requiredTrue', 'message': 'Should agree'}
          ],
        },
        'accounts': {
          'type': 'list',
          'itemType': {'type': 'object', 'objectType': 'AccountType'}
        },
      },
      'AccountType': {
        'name': {
          'type': 'string',
          'rules': [
            {'type': 'required', 'message': 'Required'}
          ]
        },
        'value': {'type': 'bool'}
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      FOEditorForm(form: form),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                              onPressed: () => onAdd(),
                              child: const Text('Add')),
                          const SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                              onPressed: () => onSubmit(context),
                              child: const Text('Submit')),
                          const SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                              onPressed: () => onReset(),
                              child: const Text('Reset')),
                        ],
                      )
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

  void onAdd() {
    (form['accounts'] as FOList).add({'name': '', 'value': true});
  }

  void onSubmit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Form data'),
        content: Text(form.isValid ? form.value.toString() : "Invalid data"),
      ),
    );
  }

  void onReset() {
    form.reset();
  }
}

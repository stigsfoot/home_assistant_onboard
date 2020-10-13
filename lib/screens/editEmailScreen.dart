import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/mainProvider.dart';

class EmailEditScreen extends StatefulWidget {
  @override
  _EmailEditScreenState createState() => _EmailEditScreenState();
}

class _EmailEditScreenState extends State<EmailEditScreen> {
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final providerData = Provider.of<MainProvider>(context, listen: true);

    void submitAddress() {
      print('Submitting Address...');
      final address = textController.value.text.trim();
      if (address != '' ) {
        providerData.address = address;
        providerData.setAddress();
        Navigator.of(context).pop();
      } else {
        print('Address is Empty...');
        Navigator.of(context).pop();
      }

    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text('Update Address'),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: textController,
                  onEditingComplete: submitAddress,
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home),
                    labelText: 'Update Address',
                  ),
                ),
              ),
              SizedBox(height: 100),
              FlatButton(
                child: Text('Done'),
                onPressed: submitAddress,
              )
            ],
          ),
        ),
      ),
    );
  }
}

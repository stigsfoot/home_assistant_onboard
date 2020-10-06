import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mainProvider.dart';
import '../services/services.dart';
import './screens.dart';

class AddAsset extends StatefulWidget {
  AddAsset({Key key}) : super(key: key);

  @override
  _AddAssetState createState() => _AddAssetState();
}

class _AddAssetState extends State<AddAsset> {
  void selectAsset(asset) {
    String selectedAssetText;
    switch (asset) {
      case Assets.Add:
        selectedAssetText = 'Custom';
        break;
      case Assets.Appliance:
        selectedAssetText = 'Appliance';
        break;
      case Assets.HVAC:
        selectedAssetText = 'HVAC';
        break;
      case Assets.Plumbing:
        selectedAssetText = 'Plumbing';
        break;
      case Assets.Roof:
        selectedAssetText = 'Roof';
        break;
    }
    // Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          return AddAssetDateScreen(
            selectedAsset: asset,
            selectedAssetText: selectedAssetText,
          );
        },
      ),
    );
    print(asset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Add Home Asset'),
      ),
      body: Container(
        child: GridView.count(
          crossAxisCount: 2,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                selectAsset(Assets.Roof);
              },
              child: Card(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.roofing,
                        size: 40,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Roof'),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                selectAsset(Assets.HVAC);
              },
              child: Card(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.hvac,
                        size: 40,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('HVAC'),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                selectAsset(Assets.Plumbing);
              },
              child: Card(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.plumbing,
                        size: 40,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Plumbing'),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                selectAsset(Assets.Appliance);
              },
              child: Card(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.kitchen,
                        size: 40,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Appliances'),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                selectAsset(Assets.Add);
              },
              child: Card(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.power,
                        size: 40,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Custom'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mainProvider.dart';
import '../services/services.dart';
import './screens.dart';

class EditScreen extends StatefulWidget {
  EditScreen({Key key}) : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  void gotoEditScreen(String asset, int index, String realName) {
    String selectedAssetText;
    if (asset == 'Add') {
      selectedAssetText = 'Custom';
    } else {
      selectedAssetText = asset;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          return EditDateScreen(
            selectedAsset: asset,
            index: index,
            selectedAssetText: selectedAssetText,
            realName: realName,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerData = Provider.of<MainProvider>(context);
    final assetsList = providerData.selectedAssets;
    final assetTypes = providerData.selectedAssetType;
    List<Widget> gridRenderList = [];

    print('ALL ASSETS:');
    print(assetsList);
    Widget returnSelectedAssetIcon(selectedAsset) {
      if (selectedAsset == 'HVAC') {
        return Icon(
          Icons.hvac,
          size: 40,
        );
      } else if (selectedAsset == 'Add' || selectedAsset == 'Custom') {
        return Icon(
          Icons.power,
          size: 40,
        );
      } else if (selectedAsset == 'Appliance') {
        return Icon(
          Icons.kitchen,
          size: 40,
        );
      } else if (selectedAsset == 'Plumbing') {
        return Icon(
          Icons.plumbing,
          size: 40,
        );
      } else {
        return Icon(
          Icons.roofing,
          size: 40,
        );
      }
    }

    assetsList.asMap().forEach(
      (index, asset) {
        gridRenderList.add(
          GestureDetector(
            onTap: () {
              print(assetTypes[index]);
              print(index);
              gotoEditScreen(assetTypes[index], index, asset);
            },
            child: Card(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    returnSelectedAssetIcon(assetTypes[index]),
                    SizedBox(
                      height: 10,
                    ),
                    Text(asset),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Edit Home Asset'),
      ),
      body: Container(
        child: GridView.count(
          crossAxisCount: 2,
          children: gridRenderList,
        ),
      ),
    );
  }
}

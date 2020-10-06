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
  void gotoEditScreen(String asset, int index) {
    String selectedAssetText;
    if (asset == 'Add') {
      selectedAssetText = 'Custom';
    } else {
      selectedAssetText = asset;
    }
    // switch (asset) {
    //   case Assets.Add:
    //     selectedAssetText = 'Custom';
    //     break;
    //   case Assets.Appliance:
    //     selectedAssetText = 'Appliance';
    //     break;
    //   case Assets.HVAC:
    //     selectedAssetText = 'HVAC';
    //     break;
    //   case Assets.Plumbing:
    //     selectedAssetText = 'Plumbing';
    //     break;
    //   case Assets.Roof:
    //     selectedAssetText = 'Roof';
    //     break;
    // }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          return EditDateScreen(
            selectedAsset: asset,
            index: index,
            selectedAssetText: selectedAssetText,
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
      } else if (selectedAsset == 'Appliances') {
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
              gotoEditScreen(assetTypes[index], index);
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
    // assetsList.asMap().forEach(
    //   (index, asset) {
    //     if (asset == 'Roof') {
    //       gridRenderList.add(
    //         GestureDetector(
    //           onTap: () {
    //             print(Assets.Roof);
    //             print(index);
    //             gotoEditScreen(Assets.Roof, index);
    //           },
    //           child: Card(
    //             child: Container(
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   Icon(
    //                     Icons.roofing,
    //                     size: 40,
    //                   ),
    //                   SizedBox(
    //                     height: 10,
    //                   ),
    //                   Text('Roof'),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //       );
    //     } else if (asset == 'HVAC') {
    //       gridRenderList.add(
    //         GestureDetector(
    //           onTap: () {
    //             print(Assets.HVAC);
    //             print(index);
    //             gotoEditScreen(Assets.HVAC, index);
    //           },
    //           child: Card(
    //             child: Container(
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   Icon(
    //                     Icons.hvac,
    //                     size: 40,
    //                   ),
    //                   SizedBox(
    //                     height: 10,
    //                   ),
    //                   Text('HVAC'),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //       );
    //     } else if (asset == 'Plumbing') {
    //       gridRenderList.add(
    //         GestureDetector(
    //           onTap: () {
    //             print(Assets.Plumbing);
    //             print(index);
    //             gotoEditScreen(Assets.Plumbing, index);
    //           },
    //           child: Card(
    //             child: Container(
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   Icon(
    //                     Icons.plumbing,
    //                     size: 40,
    //                   ),
    //                   SizedBox(
    //                     height: 10,
    //                   ),
    //                   Text('Plumbing'),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //       );
    //     } else if (asset == 'Appliance') {
    //       gridRenderList.add(
    //         GestureDetector(
    //           onTap: () {
    //             print(Assets.Appliance);
    //             print(index);
    //             gotoEditScreen(Assets.Appliance, index);
    //           },
    //           child: Card(
    //             child: Container(
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   Icon(
    //                     Icons.kitchen,
    //                     size: 40,
    //                   ),
    //                   SizedBox(
    //                     height: 10,
    //                   ),
    //                   Text('Appliances'),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //       );
    //     } else {
    //       print(asset);
    //       print('IT IS NOT IN GROUP !');
    //     }
    //   },
    // );
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

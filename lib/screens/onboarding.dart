import 'package:flutter/material.dart';
import '../services/services.dart';
import '../shared/shared.dart';
import '../screens/screens.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import '../providers/mainProvider.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
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
          return OnboardingDateScreen(
              selectedAsset: asset, selectedAssetText: selectedAssetText);
        },
      ),
    );
    print(asset);
  }

  @override
  Widget build(BuildContext context) {
    final providerData = Provider.of<MainProvider>(context, listen: false);
    final AuthService auth = providerData.auth;
    // return FutureBuilder(
    //   // future: Global.assetsRef.getData(),
    //   builder: (BuildContext context, AsyncSnapshot snap) {
    //     if (snap.hasData) {
    //       List<Asset> assets = snap.data;
    //       return Scaffold(
    //         appBar: AppBar(
    //           backgroundColor: Colors.deepPurple,
    //           title: Text('Assets'),
    //           actions: [
    //             IconButton(
    //               icon: Icon(FontAwesomeIcons.userCircle,
    //                   color: Colors.pink[200]),
    //               onPressed: () => Navigator.pushNamed(context, '/profile'),
    //             )
    //           ],
    //         ),
    //         drawer: AssetDrawer(assets: snap.data),
    //         body: GridView.count(
    //           primary: false,
    //           padding: const EdgeInsets.all(20.0),
    //           crossAxisSpacing: 10.0,
    //           crossAxisCount: 2,
    //           children: assets.map((asset) => AssetItem(asset: asset)).toList(),
    //         ),
    //         bottomNavigationBar: AppBottomNav(),
    //       );

    // Check if Null, Initialise it by checking from Firebase
    if (auth.isCompetedOnboarding == null) {
      // It will set the isCompletedOnboarding value to true or false
      auth.getUser.then((value) {
        auth.createUser(value).then((val) {
          setState(() {});
        });
      });
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.blue[200],
          ),
        ),
      );
    }
    if (!auth.isCompetedOnboarding) {
      print(auth.isCompetedOnboarding);
      // Onboarding Not Complete, display Onboarding screen here
      providerData.isOnboardingComplete = false;
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
    } else {
      // Onboarding is already Complete
      // return ProfileScreen();
      // Set all data in the provider
      providerData.isOnboardingComplete = true;
      if (!providerData.dataConfigured) {
        providerData.selectedAssets = providerData.auth.selectedAssets;
        providerData.selectedInstalledDate =
            providerData.auth.selectedInstalledDate;
        providerData.selectedRemindingDate =
            providerData.auth.selectedRemindingDate;
        providerData.selectedAssetType = providerData.auth.selectedAssetsType;
        providerData.recieveNotifications =
            providerData.auth.recieveNotifications;
        providerData.address = providerData.auth.address;
        providerData.hasRemovedNotif = providerData.auth.hasRemovedNotif;
        providerData.downloadURLs = providerData.auth.downloadURLs;
        providerData.uploadedFileNames = providerData.auth.uploadedFileNames;
        providerData.scheduleNotifications();
        print('Successfully configured all data in the Provider...');
        providerData.dataConfigured = true;
      } else {
        print('Retaining previous Data...');
      }
      providerData.initFirebaseStorage();
      return BottomNavBar();
      // Reminder: MockScreen() goes here if all else fails :D
    }
    // },
    // );
  }
}

class AssetItem extends StatelessWidget {
  final Asset asset;
  const AssetItem({Key key, this.asset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Hero(
        tag: asset.img,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => AssetScreen(asset: asset),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/covers/${asset.img}',
                  fit: BoxFit.contain,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(
                          asset.title,
                          style: TextStyle(
                              height: 1.5, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ),
                    // Text(asset.description)
                  ],
                ),
                // )
                //AssetProgress(asset: asset),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AssetScreen extends StatelessWidget {
  final Asset asset;

  AssetScreen({this.asset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: ListView(children: [
        Hero(
          tag: asset.img,
          child: Image.asset('assets/covers/${asset.img}',
              width: MediaQuery.of(context).size.width),
        ),
        Text(
          asset.title,
          style:
              TextStyle(height: 2, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        QuestionList(asset: asset)
      ]),
    );
  }
}

class QuestionList extends StatelessWidget {
  final Asset asset;
  QuestionList({Key key, this.asset});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: asset.questions.map((question) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 4,
        margin: EdgeInsets.all(4),
        child: InkWell(
          onTap: () {
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (BuildContext context) =>
            //         QuestionScreen(questionId: question.id),
            //   ),
            // );
          },
          child: Container(
            padding: EdgeInsets.all(8),
            child: ListTile(
              title: Text(
                question.title,
                style: Theme.of(context).textTheme.headline6,
              ),
              subtitle: Text(
                question.description,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              // leading: QuestionBadge(asset: asset, questionId: question.id),
            ),
          ),
        ),
      );
    }).toList());
  }
}

class AssetDrawer extends StatelessWidget {
  final List<Asset> assets;
  AssetDrawer({Key key, this.assets});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView.separated(
          shrinkWrap: true,
          itemCount: assets.length,
          itemBuilder: (BuildContext context, int idx) {
            Asset asset = assets[idx];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10, left: 10),
                  child: Text(
                    asset.title,
                    // textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ),
                QuestionList(asset: asset)
              ],
            );
          },
          separatorBuilder: (BuildContext context, int idx) => Divider()),
    );
  }
}

import 'package:flutter/material.dart';
import '../shared/shared.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/mainProvider.dart';
import './screens.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final providerData = Provider.of<MainProvider>(context, listen: true);
    // Cloning the original List, so that calling sort on this list
    // Does not change the original one
    List upcomingRemindersList = List.from(providerData.selectedRemindingDate);
    List indexSortedList = [];

    int getDatePosition(List dateList, DateTime date) {
      int index;
      for (var i = 0; i < dateList.length; i++) {
        if (dateList[i] == date && !indexSortedList.contains(i)) {
          index = i;
          break;
        }
      }
      return index;
    }

    // print(upcomingRemindersList);
    upcomingRemindersList.sort();
    List prevOrigList = providerData.selectedRemindingDate;
    print('AFTER:');
    print(upcomingRemindersList);
    print('BEFORE SORT:');
    print(prevOrigList);
    upcomingRemindersList.forEach(
      (date) {
        indexSortedList.add(
          getDatePosition(prevOrigList, date),
        );
      },
    );
    print(indexSortedList);
    Widget returnSelectedAssetIcon(selectedAsset) {
      if (selectedAsset == 'HVAC') {
        return Icon(
          Icons.hvac,
          size: 0.12 * width,
        );
      } else if (selectedAsset == 'Add' || selectedAsset == 'Custom') {
        return Icon(
          Icons.power,
          size: 0.12 * width,
        );
      } else if (selectedAsset == 'Appliance') {
        return Icon(
          Icons.kitchen,
          size: 0.12 * width,
        );
      } else if (selectedAsset == 'Plumbing') {
        return Icon(
          Icons.plumbing,
          size: 0.12 * width,
        );
      } else {
        return Icon(
          Icons.roofing,
          size: 0.12 * width,
        );
      }
    }

    return Scaffold(
      floatingActionButton: indexSortedList.length <= 6
          ? FloatingActionButton(
              onPressed: () {
                // To get a test notification, uncomment this code below,
                // You will get a notification 5 Seconds after you pressed this FAB:

                 providerData.scheduleNotificationTest();
                 print('Scheduled Notification Test!');

                print('Adding a new Asset !');
                Navigator.of(context).pushNamed('/addAsset');
              },
              child: Icon(
                Icons.add,
                size: 30,
                color: Colors.white,
              ),
              backgroundColor: Colors.deepPurple,
            )
          : Container(),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (indexSortedList.length > 0) {
                  String selectedAssetText;
                  if (providerData.selectedAssetType[indexSortedList[0]] ==
                      'Add') {
                    selectedAssetText = 'Custom';
                  } else {
                    selectedAssetText =
                        providerData.selectedAssetType[indexSortedList[0]];
                  }
                  // Handle onTap:
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) {
                        return EditDateScreen(
                          selectedAsset: providerData
                              .selectedAssetType[indexSortedList[0]],
                          index: indexSortedList[0],
                          // This is the Type
                          selectedAssetText: selectedAssetText,
                          realName:
                              providerData.selectedAssets[indexSortedList[0]],
                          canBeDeleted: false,
                        );
                      },
                    ),
                  );
                }
              },
              child: Container(
                width: 0.7 * width,
                height: 0.7 * width,
                margin: EdgeInsets.only(top: 80),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: indexSortedList.length > 0
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              providerData.selectedAssets[indexSortedList[0]],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Text(
                              'Service Due',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              // 'Thursday 10/15',
                              DateFormat('EEEE M/yy')
                                  .format(providerData.selectedRemindingDate[
                                      indexSortedList[0]])
                                  .toString(),
                              style: TextStyle(fontSize: 18),
                            )
                          ],
                        )
                      : Container(),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    if (indexSortedList.length > 1) {
                      String selectedAssetText;
                      if (providerData.selectedAssetType[indexSortedList[1]] ==
                          'Add') {
                        selectedAssetText = 'Custom';
                      } else {
                        selectedAssetText =
                            providerData.selectedAssetType[indexSortedList[1]];
                      }
                      // Handle onTap:
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) {
                            return EditDateScreen(
                              selectedAsset: providerData
                                  .selectedAssetType[indexSortedList[1]],
                              index: indexSortedList[1],
                              // This is the Type
                              selectedAssetText: selectedAssetText,
                              realName: providerData
                                  .selectedAssets[indexSortedList[1]],
                            );
                          },
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 0.2 * width,
                    height: 0.2 * width,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: prevOrigList.length > 1
                          ? Center(
                              child: returnSelectedAssetIcon(providerData
                                  .selectedAssetType[indexSortedList[1]]),
                            )
                          : Container(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () {
                    if (indexSortedList.length > 2) {
                      String selectedAssetText;
                      if (providerData.selectedAssetType[indexSortedList[2]] ==
                          'Add') {
                        selectedAssetText = 'Custom';
                      } else {
                        selectedAssetText =
                            providerData.selectedAssetType[indexSortedList[2]];
                      }
                      // Handle onTap:
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) {
                            return EditDateScreen(
                              selectedAsset: providerData
                                  .selectedAssetType[indexSortedList[2]],
                              index: indexSortedList[2],
                              // This is the Type
                              selectedAssetText: selectedAssetText,
                              realName: providerData
                                  .selectedAssets[indexSortedList[2]],
                            );
                          },
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 0.2 * width,
                    height: 0.2 * width,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: prevOrigList.length > 2
                          ? Center(
                              child: returnSelectedAssetIcon(providerData
                                  .selectedAssetType[indexSortedList[2]]),
                            )
                          : Container(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () {
                    if (indexSortedList.length > 3) {
                      String selectedAssetText;
                      if (providerData.selectedAssetType[indexSortedList[3]] ==
                          'Add') {
                        selectedAssetText = 'Custom';
                      } else {
                        selectedAssetText =
                            providerData.selectedAssetType[indexSortedList[3]];
                      }
                      // Handle onTap:
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) {
                            return EditDateScreen(
                              selectedAsset: providerData
                                  .selectedAssetType[indexSortedList[3]],
                              index: indexSortedList[3],
                              // This is the Type
                              selectedAssetText: selectedAssetText,
                              realName: providerData
                                  .selectedAssets[indexSortedList[3]],
                            );
                          },
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 0.2 * width,
                    height: 0.2 * width,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: prevOrigList.length > 3
                          ? Center(
                              child: returnSelectedAssetIcon(providerData
                                  .selectedAssetType[indexSortedList[3]]),
                            )
                          : Container(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    if (indexSortedList.length > 4) {
                      String selectedAssetText;
                      if (providerData.selectedAssetType[indexSortedList[4]] ==
                          'Add') {
                        selectedAssetText = 'Custom';
                      } else {
                        selectedAssetText =
                            providerData.selectedAssetType[indexSortedList[4]];
                      }
                      // Handle onTap:
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) {
                            return EditDateScreen(
                              selectedAsset: providerData
                                  .selectedAssetType[indexSortedList[4]],
                              index: indexSortedList[4],
                              // This is the Type
                              selectedAssetText: selectedAssetText,
                              realName: providerData
                                  .selectedAssets[indexSortedList[4]],
                            );
                          },
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 0.2 * width,
                    height: 0.2 * width,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: prevOrigList.length > 4
                          ? Center(
                              child: returnSelectedAssetIcon(providerData
                                  .selectedAssetType[indexSortedList[4]]),
                            )
                          : Container(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).pushNamed('/editAsset');
                    if (indexSortedList.length > 5) {
                      String selectedAssetText;
                      if (providerData.selectedAssetType[indexSortedList[5]] ==
                          'Add') {
                        selectedAssetText = 'Custom';
                      } else {
                        selectedAssetText =
                            providerData.selectedAssetType[indexSortedList[5]];
                      }
                      // Handle onTap:
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) {
                            return EditDateScreen(
                              selectedAsset: providerData
                                  .selectedAssetType[indexSortedList[5]],
                              index: indexSortedList[5],
                              // This is the Type
                              selectedAssetText: selectedAssetText,
                              realName: providerData
                                  .selectedAssets[indexSortedList[5]],
                            );
                          },
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 0.2 * width,
                    height: 0.2 * width,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: prevOrigList.length > 5
                          ? Center(
                              child: returnSelectedAssetIcon(providerData
                                  .selectedAssetType[indexSortedList[5]]),
                            )
                          : Container(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () {
                    if (indexSortedList.length > 6) {
                      String selectedAssetText;
                      if (providerData.selectedAssetType[indexSortedList[6]] ==
                          'Add') {
                        selectedAssetText = 'Custom';
                      } else {
                        selectedAssetText =
                            providerData.selectedAssetType[indexSortedList[6]];
                      }
                      // Handle onTap:
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) {
                            return EditDateScreen(
                              selectedAsset: providerData
                                  .selectedAssetType[indexSortedList[6]],
                              index: indexSortedList[6],
                              // This is the Type
                              selectedAssetText: selectedAssetText,
                              realName: providerData
                                  .selectedAssets[indexSortedList[6]],
                            );
                          },
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 0.2 * width,
                    height: 0.2 * width,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: indexSortedList.length > 6
                            ? returnSelectedAssetIcon(providerData
                                .selectedAssetType[indexSortedList[6]])
                            : Container(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/mainProvider.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final providerData = Provider.of<MainProvider>(context);
    // Cloning the original List, so that calling sort on this list
    // Does not change the original one
    List upcomingRemindersList = List.from(providerData.selectedRemindingDate);
    List indexSortedList = [];

    // Sorting the list by date
    upcomingRemindersList.sort();

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
    List prevOrigList = providerData.selectedRemindingDate;
    print('AFTER:');
    print(upcomingRemindersList);
    print('BEFORE SORT:');
    print(prevOrigList);

    // Romoving the dates in the future from this list...
    final dateNow = DateTime.now();
    List tempReminderList = [];
    upcomingRemindersList.forEach(
      (date) {
        if (!date.isBefore(dateNow)) {
          print('Date is in Future...');
          print('Not Adding it in List...');
        } else {
          tempReminderList.add(date);
        }
      },
    );
    // Set it equal to the original list which removes all dates in future
    upcomingRemindersList = tempReminderList;
    upcomingRemindersList.forEach(
      (date) {
        indexSortedList.add(
          getDatePosition(prevOrigList, date),
        );
      },
    );
    print(indexSortedList);

    Widget returnSelectedAssetIcon(String selectedAsset) {
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

    void deleteNotif(int index) {
      setState(
        () {
          providerData.hasRemovedNotif[index] = true;
          providerData.updateFirebase();
        },
      );
    }

    // List to pass to the Column Widget to render
    List renderList = <Widget>[];
    indexSortedList.forEach(
      (index) {
        if (!providerData.hasRemovedNotif[index]) {
          renderList.add(
            Container(
              width: double.infinity,
              height: 0.1 * height,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    returnSelectedAssetIcon(
                      providerData.selectedAssetType[index],
                    ),
                    Container(
                      width: 0.6 * width,
                      child: Text(providerData.selectedAssets[index]),
                    ),
                    IconButton(
                      onPressed: () {
                        deleteNotif(index);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          print('Has removed Notification at index: $index');
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text('All Notifications'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 70),
        child: Column(
          children: renderList,
        ),
      ),
    );
  }
}

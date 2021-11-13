import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:search_delegate_flutter/searchDelegate.dart';

class TestData {
  final String name;
  final int id;
  final bool isOpen;
  final int price;
  final int duration;
  TestData(this.name, this.id, this.isOpen, this.price, this.duration);
  @override
  String toString() {
    return 'name:$name, id:$id, isOpen:$isOpen,price:$price,duration:$duration';
  }
}

const testNames = [
  "mahmut",
  "ayşe",
  "ali",
  "jack",
  "jonny",
  "alex",
  "alexa",
  "liz",
  "siri",
  "maria",
  "marz",
  "mia"
];

TestData generateRandomTestData() {
  var name = testNames[Random().nextInt(testNames.length)];
  var id = Random().nextInt(1000);
  var price = Random().nextInt(5000);
  var duration = 1 + Random().nextInt(3);
  var isOpen = Random().nextBool();
  return TestData(name, id, isOpen, price, duration);
}

void main() {
  group('A group of tests', () {
    var items = List<int>.generate(50, (index) => index);
    var delegate = ChainedSearchDelegate<int>(items, List.from(items),
        search: (int value, dynamic integer) {
      var val = integer as int;
      return value > val;
    }, initialValue: 5);
    final testData = List.generate(100000, (index) => generateRandomTestData());
    var chainedTestDelegate = ChainedSearchDelegate<TestData>(
        testData, List.from(testData), search: (TestData data, dynamic value) {
      var val = value as int;
      return data.id > val;
    }, initialValue: 100);

    final treeSearchDelegate = TreeSearchDelegate<TestData>(
      testData,
      List.from(testData),
      search: (item, param) => item.id > param,
      initialValue: 150,
    );
    final node = treeSearchDelegate.createNodeTrees(
      [
        Truple((item, param) => item.id < param, 450, null),
        Truple((item, param) => item.price > param, 2500, null),
        Truple((item, param) => item.duration < param, 2, null),
        Truple((item, param) => item.id > param, 850, null),
        Truple((item, param) => item.price < param, 250, null),
      ],
      (item, param) => item.isOpen == param,
      true,
      insertIntoTree: true,
      filterType: TREE_FILTER_TYPE.ONLY,
    );

    setUp(() {
      var regex = RegExp(".*a.*");
      chainedTestDelegate.chain<RegExp>(
          (item, param) => param.hasMatch(item.name), regex);
      chainedTestDelegate.chain<int>((item, param) => item.id > param, 250);
      chainedTestDelegate.chain<bool>(
          (item, param) => item.isOpen == param, true);
      chainedTestDelegate.chain<int>((item, param) => item.duration > param, 1);
      chainedTestDelegate.chain<int>((item, param) => item.price < param, 2000);

      var s = DateTime.now().millisecondsSinceEpoch;
      chainedTestDelegate.searchItems();
      var f = DateTime.now().millisecondsSinceEpoch;

      var ts = DateTime.now().millisecondsSinceEpoch;
      treeSearchDelegate.searchItems();
      var tf = DateTime.now().millisecondsSinceEpoch;
      print("filtering with Tree delegate took ${tf - ts} milliseconds for" +
          " ${testData.length} items, qualfying ${treeSearchDelegate.shown.length} items to show.");
      print(
          "filtering with Chained delegate took ${f - s} milliseconds for ${testData.length} items, qualfying ${chainedTestDelegate.shown.length} items to show.");
      for (var i in chainedTestDelegate.shown) {
        if (i.id <= 250 ||
            !i.isOpen ||
            !i.name.contains('a') ||
            i.price >= 2000 ||
            i.duration <= 1) {
          print(i);
        }
      }
      for (var i in treeSearchDelegate.shown) {
        if ((!i.isOpen &&
            i.id >= 150 &&
            (i.id <= 450 &&
                (i.price <= 2500 && i.price >= 250) &&
                i.duration >= 2))) {
          print('error filtering $i');
        }
      }
    });

    test('First Test', () {
      //expect(delegate.shown, List.generate(length, (index) => null));
      //expect(delegateLower.shown, [1, 2, 3, 4, 5]);
    });
  });
}

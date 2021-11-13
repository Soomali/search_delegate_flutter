import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:search_delegate_flutter/searchDelegate.dart';
import 'package:search_delegate_flutter/src/treeNodeData.dart';

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
    var delegate = ChainedSearchDelegate<int>(items);
    final testData = List.generate(100000, (index) => generateRandomTestData());
    var chainedTestDelegate = ChainedSearchDelegate<TestData>(testData);

    final treeSearchDelegate = TreeSearchDelegate<TestData>(
      testData,
    );
    final node = treeSearchDelegate.createNodeTrees(
      [
        TreeNodeData(
            initialValue: 450, search: (item, param) => item.id < param),
        TreeNodeData(
            initialValue: 2500, search: (item, param) => item.price > param),
        TreeNodeData(
          search: (item, param) => item.duration < param,
          initialValue: 2,
        ),
        TreeNodeData(
          search: (item, param) => item.id > param,
          initialValue: 850,
        ),
        TreeNodeData(
            search: (item, param) => item.price < param, initialValue: 250),
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
      final items = List.generate(25000, (index) => generateRandomTestData());
      TreeSearchDelegate<TestData> delegate = TreeSearchDelegate(items);
      delegate.add<bool>((item, param) => item.isOpen, true, nodeLabel: 'root');
      delegate.add<int>((item, param) => item.price < param, 1500,
          nodeLabel: 'lesserThan1500', filterType: TREE_FILTER_TYPE.ONLY);
      delegate.add<int>((item, param) => item.price > param, 150,
          nodeLabel: 'PriceBigger150');
      delegate.add<int>((item, param) => item.duration < param, 2,
          parentNodeLabel: 'lesserThan1500', nodeLabel: 'durationLesserThan2');
      var dbt = delegate.add<int>((item, param) => item.price % 10 == 0, 1500,
          nodeLabel: 'dividableByTen', parentNodeLabel: 'lesserThan1500');
      delegate.searchItems();
      expect(delegate.shown.where((element) => element.price > 1500).length, 0);
      expect(delegate.shown.where((element) => element.price < 150).length, 0);
      expect(
          delegate.shown
              .where((element) =>
                  element.price > 1500 &&
                  element.price < 150 &&
                  (element.duration > 2 && element.price % 10 != 0))
              .length,
          0);
      expect(delegate.findNodeByLabel('dividableByTen'), dbt);
      print(delegate.findNodeByLabel('lesserThan1500'));
    });
  });
}

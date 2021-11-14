import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:search_delegate_flutter/search_delegate_flutter.dart';
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
  group('', () {
    final testData = List.generate(100000, (index) => generateRandomTestData());
    var chainedTestDelegate = ChainedSearchDelegate<TestData>(testData);
    TreeSearchDelegate<TestData> delegateWithLabeled =
        TreeSearchDelegate(testData);

    void addLabels() {
      delegateWithLabeled.add<bool>((item, param) => item.isOpen, true,
          nodeLabel: 'root');
      delegateWithLabeled.add<int>((item, param) => item.price < param, 1500,
          nodeLabel: 'lesserThan1500', filterType: TREE_FILTER_TYPE.ONLY);
      delegateWithLabeled.add<int>((item, param) => item.price > param, 150,
          nodeLabel: 'PriceBigger150');
      delegateWithLabeled.add<int>((item, param) => item.duration < param, 2,
          parentNodeLabel: 'lesserThan1500', nodeLabel: 'durationLesserThan2');
    }

    void clearRoot() {
      delegateWithLabeled.clear();
    }

    clearRoot();
    test("Time test", () {
      final treeSearchDelegate = TreeSearchDelegate<TestData>(
        testData,
      );
      final node = treeSearchDelegate.createNodeTree(
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
      final treeTime = tf - ts;
      final chainedTime = f - s;
      print("filtering with Tree delegate took $treeTime milliseconds for" +
          " ${testData.length} items, qualfying ${treeSearchDelegate.shown.length} items to show.");
      print(
          "filtering with Chained delegate took $chainedTime milliseconds for ${testData.length} items, qualfying ${chainedTestDelegate.shown.length} items to show.");
      expect(true, treeTime < 100);
      expect(true, chainedTime < 100);
      for (var i in chainedTestDelegate.shown) {
        if (i.id <= 250 ||
            !i.isOpen ||
            !i.name.contains('a') ||
            i.price >= 2000 ||
            i.duration <= 1) {
          throw 'error filtering $i fot chainedTestDelegate';
        }
      }
      for (var i in treeSearchDelegate.shown) {
        if ((!i.isOpen &&
            i.id >= 150 &&
            (i.id <= 450 &&
                (i.price <= 2500 && i.price >= 250) &&
                i.duration >= 2))) {
          throw 'error filtering $i for treeSerachDelegate';
        }
      }
    });

    test('Label addditionTest,', () {
      addLabels();
      var dbt = delegateWithLabeled.add<int>(
          (item, param) => item.price % 10 == 0, 1500,
          nodeLabel: 'dividableByTen', parentNodeLabel: 'lesserThan1500');
      delegateWithLabeled.searchItems();
      expect(delegateWithLabeled.findNodeByLabel('dividableByTen'), dbt);

      expect(
          delegateWithLabeled.shown
              .where((element) => element.price > 1500)
              .length,
          0);
      expect(
          delegateWithLabeled.shown
              .where((element) => element.price < 150)
              .length,
          0);
      expect(
          delegateWithLabeled.shown
              .where((element) =>
                  element.price > 1500 &&
                  element.price < 150 &&
                  (element.duration > 2 && element.price % 10 != 0))
              .length,
          0);

      print(delegateWithLabeled.findNodeByLabel('lesserThan1500'));
      clearRoot();
    });
    test('Label removing test', () {
      addLabels();
      delegateWithLabeled.add<int>((item, param) => item.price % 10 == 0, 1500,
          nodeLabel: 'dividableByTen', parentNodeLabel: 'lesserThan1500');
      delegateWithLabeled.clearNodeByLabel('dividableByTen');
      delegateWithLabeled.clearNodeByLabel('lesserThan1500');

      var res = delegateWithLabeled.findNodeByLabel('dividableByTen');
      var lesserRes = delegateWithLabeled.findNodeByLabel('lesserThan1500');
      expect(null, res);
      expect(null, lesserRes);
      clearRoot();
    });
  });
}

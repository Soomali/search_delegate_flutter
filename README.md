# search_delegate_flutter

Search delegate lets you handle your list of items in a way that you can search through them efficiently and get the
items that meets your conditions.

## Getting Started

Note that all delegates extends ChangeNotifier.
Simple usage example:


import the package
```dart
import 'package:search_delegate_flutter/search_delegate_flutter.dart';
```

create the items like so. delegates at the start does not have root nodes, so the first addition to them will be their root node.
```dart
List<int> items = List.generate(1000,(index) => index);
TreeSearchDelegate<int> treeDelegate = TreeSearchDelegate(items);
ChainedSearchDelegate<int> chainedDelegate = ChainedSearchDelegate(items)
```


## Simple Usage

for TreeSearchDelegate, add method adds a node under the root if parentNodeLabel is not specified.
notice that add method has a generic type, which is used to determine params type. initialValue means the starting value of the node and when searching through it will be used.You can also change it later,mind that doing so will effect future searches. 
You can add nodes to above examples like so:
```dart

treeDelegate.add<int>((item, param) => item > param, 150,
          nodeLabel: 'root');

treeDelegate.add<int>((item, param) => item < param, 1500,
          nodeLabel: 'lesserThan1500', filterType: TREE_FILTER_TYPE.ONLY);
treeDelegate.add<int>((item,param) => item % param == 0,3,nodeLabel:'dividableBy3',parentNodeLabel:'lesserThan1500')

```
for ChainedSearchDelegate it is simpler

```dart
    chainedDelegate.chain<int>((item,param) => item < param,140);
```

You can do all type of searches.This libraries main goal is to help manage and maintain searching practices.
For example a Regular expression search would something like this:
```dart
//for chained delegate
var regex = RegExp(".*a.*");
chainedDelegate.chain<RegExp>(
          (item, param) => param.hasMatch(item.name), regex);
treeDelegate.add<RegExp>((item,param) => param.hasMatch(item.name),regex,nodeLabel:'matchNameRegexp')
```

While using treeSearchDelegate, you can create the root and the first subNodes by calling treeDelegate.createNodeTree.
If insertIntoTree is false and the root is not null then the created root node will be returned with the subNodes.
An example:
```dart
treeSearchDelegate.createNodeTree(
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

```

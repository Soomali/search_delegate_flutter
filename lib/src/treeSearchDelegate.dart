import 'package:search_delegate_flutter/src/treeNodeData.dart';

import '../search_delegate_flutter.dart';
import 'delegate.dart';
import 'node.dart';

class _TreeSearchNode<T, V> extends Node<T, V> {
  final List<_TreeSearchNode<T, dynamic>> _nodes = [];
  TREE_FILTER_TYPE filterType;
  _TreeSearchNode(Search<T, V> search, V initialSearchValue, this.filterType,
      {String? label})
      : super(search, initialSearchValue, label: label);
  @override
  void add<P>(Node<T, P> added) {
    if (!(added is _TreeSearchNode)) return;
    _nodes.add(added as _TreeSearchNode<T, P>);
  }

  void clear() => _nodes.clear();

  ///recursively checks all the subnodes of the class until the specific condition met.
  bool _inShown(T value,
      {TREE_FILTER_TYPE parentFilterType = TREE_FILTER_TYPE.ALL}) {
    //checks its status regarding the filter type of the parent.
    switch (parentFilterType) {
      case TREE_FILTER_TYPE.NONE:
        return !search(value, initialSearchValue) && !_checkForSubNodes(value);
      default:
        return search(value, initialSearchValue) && _checkForSubNodes(value);
    }
  }

  bool _checkForSubNodes(T value) {
    switch (filterType) {
      case TREE_FILTER_TYPE.ALL:
        for (var i in _nodes) {
          if (!i._inShown(value, parentFilterType: filterType)) return false;
        }
        break;
      case TREE_FILTER_TYPE.ONLY:
        for (var i in _nodes) {
          if (i._inShown(value, parentFilterType: filterType)) return true;
        }
        if (_nodes.isNotEmpty) return false;
        return true;
      case TREE_FILTER_TYPE.NONE:
        for (var i in _nodes) {
          if (i._inShown(value, parentFilterType: filterType)) return false;
        }
        break;
    }
    return true;
  }

  @override
  String toString() {
    return 'searchType:$T, label:$label, subNodeCount:${_nodes.length}';
  }

  @override
  _TreeSearchNode<T, dynamic>? findNodeByLabel(String label) {
    if (this.label != label) {
      for (var i in _nodes) {
        var result = i.findNodeByLabel(label);
        if (result != null) {
          return result;
        }
      }
      return null;
    }
    return this;
  }

  void removeByLabel(String label) {
    _nodes.removeWhere((element) => element.label == label);
  }

  bool remove(_TreeSearchNode<T, dynamic> child) {
    return _nodes.remove(child);
  }

  _TreeSearchNode<T, dynamic>? _findParentNodeOf(String label) {
    if (_nodes.where((element) => element.label == label).length > 0) {
      return this;
    }
    for (var i in _nodes) {
      return i._findParentNodeOf(label);
    }
  }
}

/// it is for determining [_TreeSearchNode] to how to handle [_TreeSearchNode.inShwon]
/// method. [ALL] means all of the sub-nodes have to return true for value to be in shown,
/// [ONLY] means only one of the sub-nodes returning true is enough, and [NONE] is non of the sub-nodes
/// returning true.
enum TREE_FILTER_TYPE { ALL, ONLY, NONE }

/// A search delegate for complicated searches. It is for objects to meet specific
/// conditions. This class is multiple factor searching, meaning that when not one but many different
/// conditions individualy qualifies for the result this class handles them.
/// it has a [_TreeSearchNode] as start node.
class TreeSearchDelegate<T> extends Delegate<T, dynamic> {
  TREE_FILTER_TYPE rootFilter;
  _TreeSearchNode<T, dynamic>? root;
  TreeSearchDelegate(
    List<T> items, {
    this.rootFilter = TREE_FILTER_TYPE.ALL,
  }) : super(
          items,
        );

  _TreeSearchNode<T, dynamic>? findNodeByLabel(String label) =>
      this.root?.findNodeByLabel(label);

  _TreeSearchNode<T, dynamic>? findParentByLabel(String label) =>
      root!._findParentNodeOf(label);

  void clear() {
    root?.clear();
    root = null;
  }

  void clearNodeByLabel(String label) {
    try {
      var node = findNodeByLabel(label)!;
      print(node);
      node.clear();

      var parent = findParentByLabel(label);
      print(parent);
      parent?.remove(node);
    } catch (e) {
      throw 'NodeNotFoundException: no node found with label $label';
    }
  }

  ///creates a node from [search] and [initialValue ] parameter,
  ///adds it under the root and returns the created node.
  _TreeSearchNode<T, P> add<P>(Search<T, P> search, P initialValue,
      {String? nodeLabel,
      _TreeSearchNode<T, dynamic>? parentNode,
      TREE_FILTER_TYPE filterType = TREE_FILTER_TYPE.ALL,
      String? parentNodeLabel}) {
    assert(parentNode == null || parentNodeLabel == null,
        'both parentNode and nodeLabel should not be given.');

    var newNode = _TreeSearchNode<T, P>(search, initialValue, filterType,
        label: nodeLabel);
    if (root == null) {
      root = newNode;
      return newNode;
    }
    if (parentNodeLabel != null) {
      _TreeSearchNode<T, dynamic>? parent =
          root!.findNodeByLabel(parentNodeLabel);
      if (parent == null) {
        throw 'NodeNotFoundException: Can not found node with label $parentNodeLabel from TreeSearchDelegate, root label was:${root!.label}';
      }
      parent._nodes.add(newNode);
      return newNode;
    }
    parentNode ??= root;
    parentNode!.add(newNode);
    return newNode;
  }

  ///searches nodes regarding their [TREE_FILTER_TYPE]
  @override
  void searchItems() {
    if (root == null) {
      shown = List.from(items);
      notifyListeners();
      return;
    }
    shown.clear();
    for (var i in items) {
      if (root!._inShown(i)) {
        shown.add(i);
      }
    }
    notifyListeners();
  }

  ///This function creates a root node from [rootSearch] and [rootValue], and creates
  ///sub nodes for the root node from [subSearches]. if [inserIntoTree] is true, created nodes
  ///will be inserted to [root] node's nodes. this function returns the root node which you can
  ///insert it into another [_TreeSearchNode]s.
  ///[@Param subSearches] list of [TreeNodeData] objects that contains [Search]<T,V> search, V initialValue and [String?] label for each node that will be created and put under the root.
  ///[@Param rootSearch] [Search] function that will be used to create root node.
  ///[@Param rootValue] value that will be used in [rootSearch] function.
  ///[@Param insertIntoTree] if true this node will be inserted under the [root].
  ///[@Param filterType] roots [TREE_FILTER_TYPE] type to determine the result of [_inShown] function.
  _TreeSearchNode createNodeTrees(List<TreeNodeData<T, dynamic>> subSearches,
      Search<T, dynamic> rootSearch, dynamic rootValue,
      {bool insertIntoTree = true,
      TREE_FILTER_TYPE filterType = TREE_FILTER_TYPE.ALL}) {
    final _root = _TreeSearchNode<T, dynamic>(
      rootSearch,
      rootValue,
      filterType,
    );

    for (var i in subSearches) {
      final subnode = _TreeSearchNode<T, dynamic>(
          i.search, i.initialValue, filterType,
          label: i.label);
      _root.add(subnode);
    }
    if (insertIntoTree) {
      if (root == null) {
        root = _root;
      } else {
        root!.add(_root);
      }
    }
    return _root;
  }
}

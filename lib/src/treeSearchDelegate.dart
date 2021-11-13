import '../searchDelegate.dart';
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

  ///recursively checks all the subnodes of the class until the specific condition met.
  @override
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
  Node? findNodeByLabel(String label) {
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
  final Search<T, dynamic> search;
  final dynamic initialValue;
  TREE_FILTER_TYPE rootFilter;
  late _TreeSearchNode root;
  TreeSearchDelegate(
    List<T> items,
    List<T> shown, {
    required this.search,
    required this.initialValue,
    this.rootFilter = TREE_FILTER_TYPE.ALL,
  }) : super(items, shown, normalSearch: search) {
    root = _TreeSearchNode<T, dynamic>(
      search,
      initialValue,
      rootFilter,
    );
  }

  ///creates a node from [search] and [initialValue ] parameter,
  ///adds it under the root and returns the created node.
  _TreeSearchNode add<P>(Search<T, P> search, P initialValue,
      {_TreeSearchNode? parentNode,
      TREE_FILTER_TYPE filterType = TREE_FILTER_TYPE.ALL}) {
    var newNode = _TreeSearchNode<T, P>(search, initialValue, filterType);
    parentNode ??= root;
    parentNode.add(newNode);
    return newNode;
  }

  ///searches nodes regarding their [TREE_FILTER_TYPE]
  @override
  void searchItems() {
    shown.clear();
    for (var i in items) {
      if (root._inShown(i)) {
        shown.add(i);
      }
    }
    notifyListeners();
  }

  ///This function creates a root node from [rootSearch] and [rootValue], and creates
  ///sub nodes for the root node from [subSearches]. if [inserIntoTree] is true, created nodes
  ///will be inserted to [root] node's nodes. this function returns the root node which you can
  ///insert it into another [_TreeSearchNode]s.
  ///[@Param subSearches] pair of [Search]<T,V> and V values that will be used to create sub nodes for the root.
  ///[@Param rootSearch] [Search] function that will be used to create root node.
  ///[@Param rootValue] value that will be used in [rootSearch] function.
  ///[@Param insertIntoTree] if true this node will be inserted under the [root].
  ///[@Param filterType] roots [TREE_FILTER_TYPE] type to determine the result of [_inShown] function.
  _TreeSearchNode createNodeTrees(
      List<Truple<Search<T, dynamic>, dynamic, String?>> subSearches,
      Search<T, dynamic> rootSearch,
      dynamic rootValue,
      {bool insertIntoTree = true,
      TREE_FILTER_TYPE filterType = TREE_FILTER_TYPE.ALL}) {
    final _root = _TreeSearchNode<T, dynamic>(
      rootSearch,
      rootValue,
      filterType,
    );
    for (var i in subSearches) {
      final subnode = _TreeSearchNode<T, dynamic>(i.first, i.second, filterType,
          label: i.third);
      _root.add(subnode);
    }
    if (insertIntoTree) {
      root.add(_root);
    }
    return _root;
  }
}

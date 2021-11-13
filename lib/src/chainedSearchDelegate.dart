import '../searchDelegate.dart';
import 'delegate.dart';
import 'node.dart';

/// chains multiple [Search]es together and shows the values that
/// all of the conditions met. note that all of the [Node] based and
/// [Delegate] based classes' initialValue can be changed.
/// that will also effect the further comparisons and searches.
class ChainedSearchDelegate<T> extends Delegate<T, dynamic> {
  final Search<T, dynamic> search;
  dynamic initialValue;
  late _SearchNode<T, dynamic>? _startSearchNode;
  ChainedSearchDelegate(List<T> items, List<T> shown,
      {required this.search, required this.initialValue})
      : super(items, shown, normalSearch: search) {
    _startSearchNode = _SearchNode<T, dynamic>(search, initialValue);
  }

  _SearchNode<T, P> chain<P>(Search<T, P> search, P initialValue,
      [String? label]) {
    var node = _SearchNode<T, P>(search, initialValue, label: label);
    if (_startSearchNode == null) {
      _startSearchNode = node;
      return node;
    }
    _startSearchNode!.add(node);
    return node;
  }

  @override
  void searchItems() {
    shown.clear();
    if (_startSearchNode == null)
      throw 'Start node is null, nothing to search at.';
    for (T i in items) {
      if (_startSearchNode!._inShown(i)) {
        shown.add(i);
      }
    }
    notifyListeners();
  }

  /// removes the first occurence of the node.
  /// if the node is start node, changes the startnode to startnodes next
  /// node. if that is also null, disposes itself and sets startnode to null.
  void remove<P>(_SearchNode node) {
    if (_startSearchNode == null) return;
    if (_startSearchNode == node) {
      if (_startSearchNode!._next == null) {
        dispose();
        _startSearchNode = null;
      } else {
        _SearchNode<T, dynamic> next = _startSearchNode!._next!;
        _startSearchNode!._next = null;
        _startSearchNode = next;
      }
    } else {
      var next = _startSearchNode!._next;
      if (next == null) return;
      var before = _startSearchNode;
      while (next!._next != null) {
        if (next == node) {
          before!._next = next._next;
          next._next = null;
          return;
        } else {
          before = next;
          next = next._next;
        }
      }
      if (next == node) {
        before!._next = null;
      }
    }
  }
}

class _SearchNode<T, V> extends Node<T, V> {
  _SearchNode<T, dynamic>? _next;
  _SearchNode(Search<T, V> search, V initialSearchValue, {String? label})
      : super(search, initialSearchValue, label: label);

  @override
  void add<P>(Node<T, P> next) {
    if (!(next is _SearchNode)) return;
    _SearchNode start = this;
    while (start._next != null) {
      start = start._next!;
    }
    start._next = next as _SearchNode;
  }

  @override
  bool _inShown(T item) {
    return !search(item, initialSearchValue)
        ? false
        : _next != null
            ? _next!._inShown(item)
            : true;
  }

  @override
  Node? findNodeByLabel(String label) {
    if (this.label != label) {
      return _next != null ? _next!.findNodeByLabel(label) : null;
    }
    return this;
  }
}

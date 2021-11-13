import 'delegate.dart' show Search;

/// base class for [_SearchNode] and [_TreeSearchNode] classes.
abstract class Node<T, V> {
  String? label;
  final Search<T, V> search;
  V initialSearchValue;
  Node(this.search, this.initialSearchValue, {this.label});

  ///adds another node into this node.
  void add<P>(Node<T, P> added);
  Node<T, dynamic>? findNodeByLabel(String label);

  /// checks if the value meets the classes specified requirements
  /// for that to be in _shown list.
  bool _inShown(T value);
}

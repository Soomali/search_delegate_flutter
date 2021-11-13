import '../searchDelegate.dart';

class TreeNodeData<T, V> {
  final Search<T, V> search;
  final V initialValue;
  final String? label;

  TreeNodeData(
    this.label,
    this.initialValue,
    this.search,
  );
}

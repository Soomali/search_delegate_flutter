import 'package:flutter/cupertino.dart';

typedef SearchDelegateListener<T> = void Function(Iterable<T> shown);
typedef Search<T, V> = bool Function(T item, V param);

abstract class Delegate<T, V> extends ChangeNotifier {
  List<T> items;
  List<T> shown;

  Delegate(
    this.items,
  ) : shown = List.from(items);

  void searchItems();
}

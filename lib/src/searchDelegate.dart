import 'delegate.dart';

/// base class for search delegates. handles adding listeners, notifying listeners and initializng
/// [shown] and [items]. can be used for a simple search.
class SearchDelegate<T, V> extends Delegate<T, V> {
  final Search<T, V> normalSearch;
  SearchDelegate(List<T> items, {required this.normalSearch}) : super(items);
  @override
  void searchItems({V? param, Search<T, V>? search}) {
    if (param != null) {
      search ??= normalSearch;
      shown.clear();
      for (var i in items) {
        if (search(i, param)) {
          shown.add(i);
        }
      }
      notifyListeners();
    } else {
      print(
          'I/SearchDelegate: called function searchItems with null as parameter, no searching has been done.');
    }
  }

  SearchDelegate<T, P> changeSearch<P>(Search<T, P> search) {
    final _delegate = SearchDelegate<T, P>(items, normalSearch: search);
    return _delegate;
  }
}

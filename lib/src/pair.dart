//pair is simply a class that holds two values.
class Pair<T, V> {
  final T first;
  final V second;
  Pair(this.first, this.second);
}

class Truple<T, V, P> {
  final T first;
  final V second;
  final P third;
  Truple(this.first, this.second, this.third);
}

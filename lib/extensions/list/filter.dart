//gefiltere Version eines List-Streams, z.B. nur die Notizen des jeweiligen Nutzers sollen angezeigt werden
extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) =>
    map((items) => items.where(where).toList());
}
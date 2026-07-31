/// A minimal "did this load succeed" wrapper for controllers whose state
/// is just "the fetched data, or nothing yet" — `data == null &&
/// !hasError` means still loading (or never attempted); `hasError` means
/// the load failed and the screen should offer a retry instead of
/// spinning forever.
class LoadState<T> {
  const LoadState({this.data, this.hasError = false});

  final T? data;
  final bool hasError;
}

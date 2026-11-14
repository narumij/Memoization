/// A type that can serve as a memoization cache.
///
/// `Dictionary` conforms as is.
public protocol MemoCache<Key, Value>: ~Copyable {
  associatedtype Key
  associatedtype Value
  subscript(key: Key) -> Value? { mutating get set }
}

extension Dictionary: MemoCache {}

extension MemoCache where Self: ~Copyable {

  /// Returns the cached value if present; otherwise computes, stores, and returns it.
  @inlinable
  public mutating func value(for key: Key, orCompute compute: () throws -> Value) rethrows -> Value {
    if let v = self[key] { return v }
    let v = try compute()
    self[key] = v
    return v
  }
}

/// メモ化のキャッシュとして使える型。
///
/// `Dictionary`はそのまま適合する。
public protocol MemoCache<Key, Value>: ~Copyable {
  associatedtype Key
  associatedtype Value
  subscript(key: Key) -> Value? { mutating get set }
}

extension Dictionary: MemoCache {}

extension MemoCache where Self: ~Copyable {

  /// キャッシュにあればそれを返し、なければ計算して保存してから返す。
  @inlinable
  public mutating func value(for key: Key, orCompute compute: () throws -> Value) rethrows -> Value {
    if let v = self[key] { return v }
    let v = try compute()
    self[key] = v
    return v
  }
}

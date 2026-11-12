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

/// 引数列と戻り値の組。`Memo<引数..., 戻り値>.Cache<Dictionary>`でキャッシュの型になる。
///
/// キャッシュの型は型引数なしで書く。KeyとValueは`where`節から推論される。
public struct Memo<each T, Result> {
  public typealias Cache<Storage: MemoCache & ~Copyable> = Storage
  where Storage.Key == MemoizePack<repeat each T>, Storage.Value == Result
}

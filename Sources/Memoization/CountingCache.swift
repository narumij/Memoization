/// 任意のキャッシュにヒット数とミス数の計測を足すラッパー。
public struct CountingCache<Storage: MemoCache>: MemoCache {

  public var storage: Storage
  public private(set) var hits = 0
  public private(set) var misses = 0

  @inlinable
  public init(_ storage: Storage) {
    self.storage = storage
  }

  public subscript(key: Storage.Key) -> Storage.Value? {
    mutating get {
      if let v = storage[key] {
        hits &+= 1
        return v
      }
      misses &+= 1
      return nil
    }
    set {
      storage[key] = newValue
    }
  }
}

/// コピーできないキャッシュにヒット数とミス数の計測を足すラッパー。
public struct NoncopyableCountingCache<Storage: MemoCache & ~Copyable>: MemoCache, ~Copyable {

  public var storage: Storage
  public private(set) var hits = 0
  public private(set) var misses = 0

  @inlinable
  public init(_ storage: consuming Storage) {
    self.storage = storage
  }

  public subscript(key: Storage.Key) -> Storage.Value? {
    mutating get {
      if let v = storage[key] {
        hits &+= 1
        return v
      }
      misses &+= 1
      return nil
    }
    set {
      storage[key] = newValue
    }
  }
}

/// A wrapper that adds hit and miss counting to any cache.
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

/// A wrapper that adds hit and miss counting to a noncopyable cache.
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

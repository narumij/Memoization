import RedBlackTreeModule

public struct Pack<each T> {
  
  public
    typealias RawValue = (repeat each T)

  @usableFromInline
  var rawValue: RawValue
  
  @inlinable @inline(__always)
  public init(rawValue: (repeat each T)) {
    self.rawValue = (repeat each rawValue)
  }
  
  @inlinable @inline(__always)
  public init(_ rawValue: repeat each T) {
    self.rawValue = (repeat each rawValue)
  }
}

extension Pack: Equatable where repeat each T: Equatable {
  
  @inlinable
  public static func == (lhs: Pack<repeat each T>, rhs: Pack<repeat each T>) -> Bool {
    for (l, r) in repeat (each lhs.rawValue, each rhs.rawValue) {
      if l != r {
        return false
      }
    }
    return true
  }
}

extension Pack: Comparable where repeat each T: Comparable {
  
  @inlinable
  public static func < (lhs: Pack<repeat each T>, rhs: Pack<repeat each T>) -> Bool {
    for (l, r) in repeat (each lhs.rawValue, each rhs.rawValue) {
      if l != r {
        return l < r
      }
    }
    return false
  }
}

extension Pack: Hashable where repeat each T: Hashable {
  
  @inlinable
  public func hash(into hasher: inout Hasher) {
    for l in repeat (each rawValue) {
      hasher.combine(l)
    }
  }
}

extension Pack: _KeyCustomProtocol where repeat each T: Comparable {

  @inlinable
  public static func value_comp(_ lhs: Pack<repeat each T>, _ rhs: Pack<repeat each T>) -> Bool {
    for (l, r) in repeat (each lhs.rawValue, each rhs.rawValue) {
      if l != r {
        return l < r
      }
    }
    return false
  }
}

//extension Pack {
//  
//}

//extension Pack {
//  public struct Cache { }
//}

extension Pack {
  
  public typealias Standard<Result> = [Pack: Result]
  where repeat each T: Hashable

  public typealias Base<Result> = _MemoizeCacheBase<Pack, Result>
  where repeat each T: Comparable
  
  public typealias LRU<Result> = _MemoizeCacheLRU<Pack, Result>
  where repeat each T: Comparable
  
  public typealias CoW<Result> = _MemoizeCacheCoW<Pack, Result>
  where repeat each T: Comparable
}

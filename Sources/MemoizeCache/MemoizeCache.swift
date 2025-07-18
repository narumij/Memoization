import RedBlackTreeModule

@usableFromInline
struct MemoizeCache1<A, B>
where A: Comparable, B: Comparable {
  @usableFromInline
  enum Key: _KeyCustomProtocol {
    @inlinable
    static func value_comp(_ a: A, _ b: A) -> Bool {
      a < b
    }
  }
  @usableFromInline
  init(__memo: _MemoizeCacheBase<Key, B> = .init()) {
    self.__memo = __memo
  }
  @usableFromInline
  var __memo: _MemoizeCacheBase<Key, B> = .init()
  @inlinable
  subscript(a: A) -> B? {
    mutating get { __memo[a] }
    _modify { yield &__memo[a] }
  }
}

@usableFromInline
struct MemoizeCache2<A, B, C>
where A: Comparable, B: Comparable {
  @usableFromInline
  enum Key: _KeyCustomProtocol {
    @inlinable
    static func value_comp(_ a: (A, B), _ b: (A, B)) -> Bool {
      a < b
    }
  }
  @usableFromInline
  init(__memo: _MemoizeCacheBase<Key, C> = .init()) {
    self.__memo = __memo
  }
  @usableFromInline
  var __memo: _MemoizeCacheBase<Key, C> = .init()
  @inlinable
  subscript(a: A, b: B) -> C? {
    mutating get { __memo[(a, b)] }
    _modify { yield &__memo[(a, b)] }
  }
}

@usableFromInline
struct MemoizeCache3<A, B, C, D>
where A: Comparable, B: Comparable, C: Comparable {
  @usableFromInline
  enum Key: _KeyCustomProtocol {
    @inlinable
    static func value_comp(_ a: (A, B, C), _ b: (A, B, C)) -> Bool {
      a < b
    }
  }
  @usableFromInline
  init(__memo: _MemoizeCacheBase<Key, D> = .init()) {
    self.__memo = __memo
  }
  @usableFromInline
  var __memo: _MemoizeCacheBase<Key, D> = .init()
  @inlinable
  subscript(a: A, b: B, c: C) -> D? {
    mutating get { __memo[(a, b, c)] }
    _modify { yield &__memo[(a, b, c)] }
  }
}

@usableFromInline
struct MemoizeCache4<A, B, C, D, E>
where A: Comparable, B: Comparable, C: Comparable, D: Comparable {
  @usableFromInline
  enum Key: _KeyCustomProtocol {
    @inlinable
    static func value_comp(_ a: (A, B, C, D), _ b: (A, B, C, D)) -> Bool {
      a < b
    }
  }
  @usableFromInline
  init(__memo: _MemoizeCacheBase<Key, E> = .init()) {
    self.__memo = __memo
  }
  @usableFromInline
  var __memo: _MemoizeCacheBase<Key, E> = .init()
  @inlinable
  subscript(a: A, b: B, c: C, d: D) -> E? {
    mutating get { __memo[(a, b, c, d)] }
    _modify { yield &__memo[(a, b, c, d)] }
  }
}

@usableFromInline
struct MemoizeCacheComparable<each T, Result>
where repeat each T: Comparable {
  @usableFromInline
  init() { }
  @usableFromInline
  var __memo: _MemoizeCacheBase<Pack<repeat each T>, Result> = .init()
  @inlinable
  subscript(pack: Pack<repeat each T>) -> Result? {
    mutating get { __memo[pack] }
    _modify { yield &__memo[pack] }
  }
}

@usableFromInline
struct MemoizeCacheHashable<each T, Result>
where repeat each T: Hashable {
  @usableFromInline
  init() { }
  @usableFromInline
  var __memo: [Pack<repeat each T>: Result] = .init()
  @inlinable
  subscript(pack: Pack<repeat each T>) -> Result? {
    _read { yield __memo[pack] }
    _modify { yield &__memo[pack] }
  }
}

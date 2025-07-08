public
struct Cache<each T, Result> { }
  
extension Cache {
  
  public
  final class Standard where repeat each T: Hashable {
    
    @nonobjc
    @inlinable
    @inline(__always)
    public init() {
      self.storage = .init()
    }
    
    @usableFromInline
    var storage: Pack<repeat each T>.Standard<Result> = .init()
    
    @nonobjc
    @inlinable
    public subscript(key: Pack<repeat each T>, fallBacking _fallback: (repeat each T) -> Result) -> Result {
      @inline(__always)
      get {
        if let result = storage[key] {
          return result
        }
        let r = _fallback(repeat each key.rawValue)
        storage[key] = r
        return r
      }
    }
  }
}

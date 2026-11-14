// Copyright 2025 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

public struct MemoizePack<each T> {

  public
    typealias RawValue = (repeat each T)

  public
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

extension MemoizePack: Equatable where repeat each T: Equatable {

  @inlinable
  public static func == (lhs: MemoizePack<repeat each T>, rhs: MemoizePack<repeat each T>) -> Bool {
    for (l, r) in repeat (each lhs.rawValue, each rhs.rawValue) {
      if l != r {
        return false
      }
    }
    return true
  }
}

extension MemoizePack: Comparable where repeat each T: Comparable {

  @inlinable
  public static func < (lhs: MemoizePack<repeat each T>, rhs: MemoizePack<repeat each T>) -> Bool {
    for (l, r) in repeat (each lhs.rawValue, each rhs.rawValue) {
      if l != r {
        return l < r
      }
    }
    return false
  }
}

extension MemoizePack: Hashable where repeat each T: Hashable {

  @inlinable
  public func hash(into hasher: inout Hasher) {
    for l in repeat (each rawValue) {
      hasher.combine(l)
    }
  }
}

extension MemoizePack: Sendable where repeat each T: Sendable { }

public struct MemoizePack2<A, B> {
  public var a: A
  public var b: B
  @inlinable public init(_ a: A, _ b: B) { (self.a, self.b) = (a, b) }
}
extension MemoizePack2: Equatable where A: Equatable, B: Equatable {}
extension MemoizePack2: Hashable where A: Hashable, B: Hashable {}
extension MemoizePack2: Comparable where A: Comparable, B: Comparable {
  @inlinable public static func < (l: Self, r: Self) -> Bool { (l.a, l.b) < (r.a, r.b) }
}
extension MemoizePack2: Sendable where A: Sendable, B: Sendable {}

public struct MemoizePack3<A, B, C> {
  public var a: A
  public var b: B
  public var c: C
  @inlinable public init(_ a: A, _ b: B, _ c: C) { (self.a, self.b, self.c) = (a, b, c) }
}

extension MemoizePack3: Equatable where A: Equatable, B: Equatable, C: Equatable {}
extension MemoizePack3: Hashable where A: Hashable, B: Hashable, C: Hashable {}
extension MemoizePack3: Comparable where A: Comparable, B: Comparable, C: Comparable {
  @inlinable public static func < (l: Self, r: Self) -> Bool { (l.a, l.b, l.c) < (r.a, r.b, r.c) }
}
extension MemoizePack3: Sendable where A: Sendable, B: Sendable, C: Sendable {}

public struct MemoizePack4<A, B, C, D> {
  public var a: A
  public var b: B
  public var c: C
  public var d: D
  @inlinable public init(_ a: A, _ b: B, _ c: C, _ d: D) { (self.a, self.b, self.c, self.d) = (a, b, c, d) }
}

extension MemoizePack4: Equatable where A: Equatable, B: Equatable, C: Equatable, D: Equatable {}
extension MemoizePack4: Hashable where A: Hashable, B: Hashable, C: Hashable, D: Hashable {}
extension MemoizePack4: Comparable where A: Comparable, B: Comparable, C: Comparable, D: Comparable {
  @inlinable public static func < (l: Self, r: Self) -> Bool { (l.a, l.b, l.c, l.d) < (r.a, r.b, r.c, r.d) }
}
extension MemoizePack4: Sendable where A: Sendable, B: Sendable, C: Sendable, D: Sendable {}

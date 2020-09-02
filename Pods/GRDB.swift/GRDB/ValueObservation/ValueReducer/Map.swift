extension ValueObservation {
    /// Returns a ValueObservation which notifies the results of calling the
    /// given transformation which each element notified by this
    /// value observation.
    public func map<T>(_ transform: @escaping (Reducer.Value) -> T)
        -> ValueObservation<ValueReducers.Map<Reducer, T>>
    {
        mapReducer { ValueReducers.Map($0, transform) }
    }
}

extension ValueReducers {
    /// [**Experimental**](http://github.com/groue/GRDB.swift#what-are-experimental-features)
    ///
    /// A _ValueReducer whose values consist of those in a Base _ValueReducer passed
    /// through a transform function.
    ///
    /// See _ValueReducer.map(_:)
    ///
    /// :nodoc:
    public struct Map<Base: _ValueReducer, Value>: _ValueReducer {
        private var base: Base
        private let transform: (Base.Value) -> Value
        public var isSelectedRegionDeterministic: Bool { base.isSelectedRegionDeterministic }
        
        init(_ base: Base, _ transform: @escaping (Base.Value) -> Value) {
            self.base = base
            self.transform = transform
        }
        
        public func fetch(_ db: Database) throws -> Base.Fetched {
            try base.fetch(db)
        }
        
        public mutating func value(_ fetched: Base.Fetched) -> Value? {
            guard let value = base.value(fetched) else { return nil }
            return transform(value)
        }
    }
}

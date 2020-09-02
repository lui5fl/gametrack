#if canImport(Combine)
import Combine
#endif
import Dispatch
import Foundation

/// ValueObservation tracks changes in the results of database requests, and
/// notifies fresh values whenever the database changes.
///
/// For example:
///
///     let observation = ValueObservation.tracking { db in
///         try Player.fetchAll(db)
///     }
///
///     let cancellable = try observation.start(
///         in: dbQueue,
///         onError: { error in ... },
///         onChange: { players: [Player] in
///             print("Players have changed.")
///         })
public struct ValueObservation<Reducer: _ValueReducer> {
    var events = ValueObservationEvents()
    
    /// The reducer is created when observation starts, and is triggered upon
    /// each database change.
    var makeReducer: () -> Reducer
    
    /// Default is false. Set this property to true when the observation
    /// requires write access in order to fetch fresh values. Fetches are then
    /// wrapped inside a savepoint.
    ///
    /// Don't set this flag to true unless you really need it. A read/write
    /// observation is less efficient than a read-only observation.
    public var requiresWriteAccess: Bool = false
    
    /// Returns a ValueObservation with a transformed reducer.
    func mapReducer<R>(_ transform: @escaping (Reducer) -> R) -> ValueObservation<R> {
        let makeReducer = self.makeReducer
        return ValueObservation<R>(
            events: events,
            makeReducer: { transform(makeReducer()) },
            requiresWriteAccess: requiresWriteAccess)
    }
}

struct ValueObservationEvents: Refinable {
    var willStart: (() -> Void)?
    var willTrackRegion: ((DatabaseRegion) -> Void)?
    var databaseDidChange: (() -> Void)?
    var didFail: ((Error) -> Void)?
    var didCancel: (() -> Void)?
}

extension ValueObservation: Refinable {
    
    // MARK: - Starting Observation
    
    /// Starts the value observation in the provided database reader (such as
    /// a database queue or database pool).
    ///
    /// The observation lasts until the returned cancellable is cancelled
    /// or deallocated.
    ///
    /// For example:
    ///
    ///     let observation = ValueObservation.tracking { db in
    ///         try Player.fetchAll(db)
    ///     }
    ///
    ///     let cancellable = try observation.start(
    ///         in: dbQueue,
    ///         onError: { error in ... },
    ///         onChange: { players: [Player] in
    ///             print("fresh players: \(players)")
    ///         })
    ///
    /// By default, fresh values are dispatched asynchronously on the
    /// main queue. You can change this behavior by providing a scheduler.
    /// For example, `.immediate` notifies all values on the main queue as well,
    /// and the first one is immediately notified when the start() method
    /// is called:
    ///
    ///     let cancellable = try observation.start(
    ///         in: dbQueue,
    ///         scheduling: .immediate, // <-
    ///         onError: { error in ... },
    ///         onChange: { players: [Player] in
    ///             print("fresh players: \(players)")
    ///         })
    ///     // <- here "fresh players" is already printed.
    ///
    /// - parameter reader: A DatabaseReader.
    /// - parameter scheduler: A Scheduler. By default, fresh values are
    ///   dispatched asynchronously on the main queue.
    /// - parameter onError: A closure that is provided eventual errors that
    ///   happen during observation
    /// - parameter onChange: A closure that is provided fresh values
    /// - returns: a DatabaseCancellable
    public func start(
        in reader: DatabaseReader,
        scheduling scheduler: ValueObservationScheduler = .async(onQueue: .main),
        onError: @escaping (Error) -> Void,
        onChange: @escaping (Reducer.Value) -> Void) -> DatabaseCancellable
    {
        let observation = map(\.events) { events in
            events.map(\.didFail) { concat($0, onError) }
        }
        observation.events.willStart?()
        return reader._add(
            observation: observation,
            scheduling: scheduler,
            onChange: onChange)
    }
    
    // MARK: - Debugging
    
    /// Performs the specified closures when ValueObservation events occur.
    ///
    /// - parameters:
    ///     - willStart: A closure that executes when the observation starts.
    ///       Defaults to `nil`.
    ///     - willFetch: A closure that executes when the observed value is
    ///       about to be fetched. Defaults to `nil`.
    ///     - willTrackRegion: A closure that executes when the observation
    ///       starts tracking a database region. Defaults to `nil`.
    ///     - databaseDidChange: A closure that executes after the observation
    ///       was impacted by a database change. Defaults to `nil`.
    ///     - didReceiveValue: A closure that executes on fresh values. Defaults
    ///       to `nil`.
    ///
    ///       NOTE: This closure runs on an unspecified DispatchQueue.
    ///     - didFail: A closure that executes when the observation fails.
    ///       Defaults to `nil`.
    ///     - didCancel: A closure that executes when the observation is
    ///       cancelled. Defaults to `nil`.
    /// - returns: A `ValueObservation` that performs the specified closures
    ///   when ValueObservation events occur.
    public func handleEvents(
        willStart: (() -> Void)? = nil,
        willFetch: (() -> Void)? = nil,
        willTrackRegion: ((DatabaseRegion) -> Void)? = nil,
        databaseDidChange: (() -> Void)? = nil,
        didReceiveValue: ((Reducer.Value) -> Void)? = nil,
        didFail: ((Error) -> Void)? = nil,
        didCancel: (() -> Void)? = nil)
        -> ValueObservation<ValueReducers.Trace<Reducer>>
    {
        self
            .mapReducer({ reducer in
                ValueReducers.Trace(
                    base: reducer,
                    // Adding the willFetch handler to the reducer is handy: we
                    // are sure not to miss any fetch.
                    willFetch: willFetch ?? { },
                    // Adding the didReceiveValue handler to the reducer is necessary:
                    // the type of the value may change with the `map` operator.
                    didReceiveValue: didReceiveValue ?? { _ in })
            })
            .map(\.events, { events in
                events
                    .map(\.willStart) { concat($0, willStart) }
                    .map(\.willTrackRegion) { concat($0, willTrackRegion) }
                    .map(\.databaseDidChange) { concat($0, databaseDidChange) }
                    .map(\.didFail) { concat($0, didFail) }
                    .map(\.didCancel) { concat($0, didCancel) }
            })
    }
    
    /// Prints log messages for all ValueObservation events.
    public func print(
        _ prefix: String = "",
        to stream: TextOutputStream? = nil)
        -> ValueObservation<ValueReducers.Trace<Reducer>>
    {
        let prefix = prefix.isEmpty ? "" : "\(prefix): "
        var stream = stream ?? PrintOutputStream()
        return handleEvents(
            willStart: { stream.write("\(prefix)start") },
            willFetch: { stream.write("\(prefix)fetch") },
            willTrackRegion: { stream.write("\(prefix)tracked region: \($0)") },
            databaseDidChange: { stream.write("\(prefix)database did change") },
            didReceiveValue: { stream.write("\(prefix)value: \($0)") },
            didFail: { stream.write("\(prefix)failure: \($0)") },
            didCancel: { stream.write("\(prefix)cancel") })
    }
    
    // MARK: - Fetching Values
    
    /// Returns the value.
    func fetchValue(_ db: Database) throws -> Reducer.Value {
        var reducer = makeReducer()
        guard let value = try reducer.fetchAndReduce(db, requiringWriteAccess: requiresWriteAccess) else {
            fatalError("Contract broken: reducer has no initial value")
        }
        return value
    }
}

#if canImport(Combine)
extension ValueObservation {
    // MARK: - Publishing Observed Values
    
    /// Creates a publisher which tracks changes in database values.
    ///
    /// For example:
    ///
    ///     let observation = ValueObservation.tracking { db in
    ///         try Player.fetchAll(db)
    ///     }
    ///     let cancellable = observation
    ///         .publisher(in: dbQueue)
    ///         .sink(
    ///             receiveCompletion: { completion in ... },
    ///             receiveValue: { players: [Player] in
    ///                 print("fresh players: \(players)")
    ///             })
    ///
    /// By default, fresh values are dispatched asynchronously on the
    /// main queue. You can change this behavior by by providing a scheduler.
    ///
    /// For example, `.immediate` notifies all values on the main queue as well,
    /// and the first one is immediately notified when the publisher
    /// is subscribed:
    ///
    ///     let cancellable = observation
    ///         .publisher(
    ///             in: dbQueue,
    ///             scheduling: .immediate) // <-
    ///         .sink(
    ///             receiveCompletion: { completion in ... },
    ///             receiveValue: { players: [Player] in
    ///                 print("fresh players: \(players)")
    ///             })
    ///     // <- here "fresh players" is already printed.
    ///
    /// Note that the `.immediate` scheduler requires that the publisher is
    /// subscribed from the main thread. It raises a fatal error otherwise.
    ///
    /// - parameter reader: A DatabaseReader.
    /// - parameter scheduler: A Scheduler. By default, fresh values are
    ///   dispatched asynchronously on the main queue.
    /// - returns: A Combine publisher
    @available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
    public func publisher(
        in reader: DatabaseReader,
        scheduling scheduler: ValueObservationScheduler = .async(onQueue: .main))
        -> DatabasePublishers.Value<Reducer.Value>
    {
        return DatabasePublishers.Value(self, in: reader, scheduling: scheduler)
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension DatabasePublishers {
    fileprivate typealias Start<T> = (
        _ onError: @escaping (Error) -> Void,
        _ onChange: @escaping (T) -> Void) -> DatabaseCancellable
    
    /// A publisher that tracks changes in the database.
    ///
    /// See `ValueObservation.publisher(in:scheduling:)`.
    public struct Value<Output>: Publisher {
        public typealias Failure = Error
        private let start: Start<Output>
        
        init<Reducer>(
            _ observation: ValueObservation<Reducer>,
            in reader: DatabaseReader,
            scheduling scheduler: ValueObservationScheduler)
            where Reducer.Value == Output
        {
            start = { [weak reader] (onError, onChange) in
                guard let reader = reader else {
                    return AnyDatabaseCancellable(cancel: { })
                }
                return observation.start(
                    in: reader,
                    scheduling: scheduler,
                    onError: onError,
                    onChange: onChange)
            }
        }
        
        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = ValueSubscription(
                start: start,
                downstream: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
    
    private class ValueSubscription<Downstream: Subscriber>: Subscription
        where Downstream.Failure == Error
    {
        private struct WaitingForDemand {
            let downstream: Downstream
            let start: Start<Downstream.Input>
        }
        
        private struct Observing {
            let downstream: Downstream
            var remainingDemand: Subscribers.Demand
        }
        
        private enum State {
            /// Waiting for demand, not observing the database.
            case waitingForDemand(WaitingForDemand)
            
            /// Observing the database. Self.observer is not nil.
            case observing(Observing)
            
            /// Completed or cancelled, not observing the database.
            case finished
        }
        
        // Cancellable is not stored in self.state because we must enter the
        // .observing state *before* the observation starts, so that the user
        // can change the state even before the cancellable is known.
        private var cancellable: DatabaseCancellable?
        private var state: State
        private var lock = NSRecursiveLock() // Allow re-entrancy
        
        init(
            start: @escaping Start<Downstream.Input>,
            downstream: Downstream)
        {
            state = .waitingForDemand(WaitingForDemand(
                downstream: downstream,
                start: start))
        }
        
        func request(_ demand: Subscribers.Demand) {
            lock.synchronized {
                switch state {
                case let .waitingForDemand(info):
                    guard demand > 0 else {
                        return
                    }
                    state = .observing(Observing(
                        downstream: info.downstream,
                        remainingDemand: demand))
                    let cancellable = info.start(
                        { [weak self] error in self?.receiveCompletion(.failure(error)) },
                        { [weak self] value in self?.receive(value) })
                    
                    // State may have been altered (error or cancellation)
                    switch state {
                    case .waitingForDemand:
                        preconditionFailure()
                    case .observing:
                        self.cancellable = cancellable
                    case .finished:
                        cancellable.cancel()
                    }
                    
                case var .observing(info):
                    info.remainingDemand += demand
                    state = .observing(info)
                    
                case .finished:
                    break
                }
            }
        }
        
        func cancel() {
            lock.synchronized { sideEffect in
                let cancellable = self.cancellable
                self.cancellable = nil
                self.state = .finished
                sideEffect = {
                    cancellable?.cancel()
                }
            }
        }
        
        private func receive(_ value: Downstream.Input) {
            lock.synchronized {
                if case let .observing(info) = state,
                    info.remainingDemand > .none
                {
                    let additionalDemand = info.downstream.receive(value)
                    if case var .observing(info) = state {
                        info.remainingDemand += additionalDemand
                        info.remainingDemand -= 1
                        state = .observing(info)
                    }
                }
            }
        }
        
        private func receiveCompletion(_ completion: Subscribers.Completion<Error>) {
            lock.synchronized { sideEffect in
                if case let .observing(info) = state {
                    cancellable = nil
                    state = .finished
                    sideEffect = {
                        info.downstream.receive(completion: completion)
                    }
                }
            }
        }
    }
}
#endif

extension ValueObservation where Reducer == ValueReducers.Auto {
    
    // MARK: - Creating ValueObservation
    
    /// Creates a ValueObservation which notifies the values returned by the
    /// *fetch* function whenever a database transaction changes them.
    ///
    /// The *fetch* function must always performs the same database requests.
    /// The stability of the observed database region allows optimizations.
    ///
    /// When you want to observe a varying database region, use the
    /// `ValueObservation.trackingVaryingRegion(_:)` method instead.
    ///
    /// For example:
    ///
    ///     let observation = ValueObservation.tracking { db in
    ///         try Player.fetchAll(db)
    ///     }
    ///
    ///     let cancellable = try observation.start(
    ///         in: dbQueue,
    ///         onError: { error in ... },
    ///         onChange:) { players: [Player] in
    ///             print("Players have changed")
    ///         })
    ///
    /// - parameter fetch: A function that fetches the observed value from
    ///   the database.
    public static func tracking<Value>(
        _ fetch: @escaping (Database) throws -> Value)
        -> ValueObservation<ValueReducers.Fetch<Value>>
    {
        .init(makeReducer: { .init(isSelectedRegionDeterministic: true, fetch: fetch) })
    }
    
    /// Creates a ValueObservation which notifies the values returned by the
    /// *fetch* function whenever a database transaction changes them.
    ///
    /// - parameter fetch: A function that fetches the observed value from
    ///   the database.
    public static func trackingVaryingRegion<Value>(
        _ fetch: @escaping (Database) throws -> Value)
        -> ValueObservation<ValueReducers.Fetch<Value>>
    {
        .init(makeReducer: { .init(isSelectedRegionDeterministic: false, fetch: fetch) })
    }
}

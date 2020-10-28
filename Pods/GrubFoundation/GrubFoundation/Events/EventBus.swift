//
//  EventBus.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 8/26/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `BusEvent`s represent events that occur during an application’s runtime. While the protocol contains no requirements
/// itself, conforming types are typically value types—or minimally referentially transparent—and contain data about the
/// event that occurred. Only types conforming to `BusEvent` or `NamedBusEvent` can be posted to a `EventBus`.
///
/// - Note: You should generally only conform to either `BusEvent` *or* `NamedBusEvent`. There is virtually no benefit
///   to conforming to both, and doing so will likely complicate consuming your events.
public protocol BusEvent { }


/// `NamedBusEvent`s represent events that occur during an application’s runtime that have a name. Like `BusEvent`s,
/// conforming types are typically value types—or minimally referentially transparent—and contain data about the event
/// that occurred, including a name.
///
/// The `name` property of a `NamedBusEvent` is useful for differentiating between two events of the same type. For
/// example, you might have a `ModuleDidLoad` event that indicates that a module was loaded. When observing that event,
/// you might want to perform a different action based on which module was loaded. You can use the `name` property to
/// differentiate between the modules.
///
/// - Note: You should generally only conform to either `BusEvent` *or* `NamedBusEvent`. There is virtually no benefit
///   to conforming to both, and doing so will likely complicate consuming your events.
public protocol NamedBusEvent {
    /// The type of the event’s name. This is often a `TypedExtensibleEnum` or an `enum` with a `RawValue`.
    associatedtype Name : Hashable

    /// The event’s name.
    var name: Name { get }
}


/// `BusEventObserver`s can observe events posted by a `EventBus`.
///
/// While you can implement this protocol yourself, it is often easier to use a `ContextualBusEventObserver`. See that
/// type’s documentation for more details.
public protocol BusEventObserver : AnyObject {
    /// Observes the specified event.
    ///
    /// - Parameter event: The event that was posted.
    func observe<Event>(_ event: Event) where Event : BusEvent

    /// Observes the specified named event.
    ///
    /// - Parameter namedEvent: The named event that was posted.
    func observe<NamedEvent>(_ namedEvent: NamedEvent) where NamedEvent : NamedBusEvent
}


/// `EventBus`s post events for observers to observe. While broadly modeled after `NotificationCenter`, it is
/// different in that event centers send *all* posted events to their observers.
///
/// To begin receiving events from a `EventBus`, you can add your observer using `addObserver(_:)`. You can stop
/// receiving events by using `removeObserver(_:)`. To send an event to all a center’s observers, you can use one of the
/// `post(_:)` methods.
public class EventBus {
    /// The default `EventBus` instance.
    public static let `default` = EventBus()

    /// A concurrent accessor that controls access to the instance’s observers.
    private let observersAccessor = ConcurrentAccessor<[BusEventObserver]>([])


    /// Creates a new `EventBus`.
    public init() {
    }


    /// Adds the specified observer to the event center’s list of observers. That observer will receive all events
    /// posted to the center until it is removed from the center using `removeObserver(_:)`.
    ///
    /// - Parameter observer: The observer that should begin receiving events.
    public func addObserver(_ observer: BusEventObserver) {
        observersAccessor.syncWrite { (observers) in
            observers.append(observer)
        }
    }


    /// Removes the specified observer from the event center’s list of observers.
    ///
    /// - Parameter observer: The observer that should stop receiving events.
    public func removeObserver(_ observer: BusEventObserver) {
        observersAccessor.syncWrite { (observers) in
            observers.removeAll { $0 === observer }
        }
    }


    /// Posts the specified event to instance’s list of event observers.
    ///
    /// - Parameter event: The event to post.
    public func post<Event>(_ event: Event) where Event : BusEvent {
        let observers = observersAccessor.read { $0 }
        for observer in observers {
            observer.observe(event)
        }
    }


    /// Posts the specified named event to instance’s list of event observers.
    ///
    /// - Parameter namedEvent: The named event to post.
    public func post<NamedEvent>(_ namedEvent: NamedEvent) where NamedEvent : NamedBusEvent {
        let observers = observersAccessor.read { $0 }
        for observer in observers {
            observer.observe(namedEvent)
        }
    }
}

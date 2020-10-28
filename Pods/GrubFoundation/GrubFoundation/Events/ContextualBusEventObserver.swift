//
//  ContextualBusEventObserver.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 8/26/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `ContextualBusEventObserver`s are designed to make it easy for multiple decoupled software components to handle
/// events while sharing information and behavior. Each contextual event observer stores that shared information in a
/// *context* object. Event handlers—closures that handle a specific event—are passed that context whenever a relevant
/// event is received.
///
/// Typically, a contextual event observer is used to form an understanding of program state by observing events; it can
/// then use that understanding to determine how to respond to other events. For example, you might create a contextual
/// event observer to help measure the duration of important user activities. The app can post events when relevant
/// activities begin and end. The handler for the activity-began event can store the start date in the shared `context`.
/// Later, in the activity-ended event handler, the duration of the activity can be calculated using the stored start
/// date. The context can even provide methods for handlers to post performance data. In code,
///
///     let performanceMonitor = ContextualBusEventObserver(context: PerformanceMonitoringContext())
///     EventBus.default.addObserver(performanceMonitor)
///
///     performanceMonitor.addHandler(for: ActivityStartedEvent.self, name: .someActivity) { (event, context) in
///         context.screen1LoadStartDate = event.date
///     }
///
///     performanceMonitor.addHandler(for: ActivityEndedEvent.self, name: .someActivity) { (event, context) in
///         defer { context.screen1LoadStartDate = nil }
///         let duration = event.date.timeIntervalSince(context.screen1LoadStartDate)
///         context.postDuration(duration, of: .someActivity)
///     }
///
/// The important thing to note here is that the handlers for the `ActivityStarted` and `ActivityEnded` events could be
/// located in separate targets. By using a contextual event observer, the events can be handled without littering
/// contextual information throughout the code.
public class ContextualBusEventObserver<Context> : BusEventObserver {
    /// The context object in which handlers can share state and behavior.
    private var context: Context

    /// A concurrent accessor to a dictionary that maps event handler keys to their `Handler`s. The keys are derived
    /// from the event’s type. The values are `[Handler<Event>]`, where `Event` is the type of event being handled.
    private let eventHandlersAccessor = ConcurrentAccessor<[EventHandlersKey : [AnyObject]]>([:])

    /// A concurrent accessor to a dictionary that maps named event handler keys to their `Handler`s. The keys are
    /// derived from the event’s type and name. The values are `[Handler<Event>]`, where `Event` is the type of event
    /// being handled.
    private let namedEventHandlersAccessor = ConcurrentAccessor<[NamedEventHandlersKey : [AnyObject]]>([:])

    /// The serial queue on which handlers are invoked.
    private var handlerQueue = DispatchQueue(label: "ContextualBusEventObserver.handlerQueue")


    /// Creates a new `ContextualBusEventObserver` with the specified context.
    ///
    /// - Parameter context: The context for the new observer.
    public init(context: Context) {
        self.context = context
    }


    // MARK: - Observing Events

    public func observe<Event>(_ event: Event) where Event : BusEvent {
        let key = EventHandlersKey(eventType: Event.self)
        guard let handlers = eventHandlersAccessor.read({ $0[key] }) as? [Handler<Event>] else {
            return
        }

        handlerQueue.async {
            for handler in handlers {
                handler.handle(event, with: &self.context)
            }
        }
    }


    public func observe<NamedEvent>(_ namedEvent: NamedEvent) where NamedEvent : NamedBusEvent {
        let key = NamedEventHandlersKey(eventType: NamedEvent.self, name: namedEvent.name)
        guard let handlers = namedEventHandlersAccessor.read({ $0[key] }) as? [Handler<NamedEvent>] else {
            return
        }

        handlerQueue.async {
            for handler in handlers {
                handler.handle(namedEvent, with: &self.context)
            }
        }
    }


    // MARK: - Managing Handlers

    /// Adds a handler for `BusEvent`s of the specified type.
    ///
    /// - Parameters:
    ///   - eventType: The type of event to handle.
    ///   - body: The closure to handle the event. This closure is passed the event and the instance’s `context`.
    /// - Returns: An opaque object that represents the added handler. This object can be used to remove the handler
    ///   later using `removeHandler(_:)`.
    @discardableResult
    public func addHandler<Event>(for eventType: Event.Type, body: @escaping (Event, inout Context) -> Void) -> AnyObject
        where Event : BusEvent {
            let handler = Handler(body: body)
            eventHandlersAccessor.syncWrite { (handlers) in
                handlers[EventHandlersKey(eventType: eventType), default: []].append(handler)
            }
            return handler
    }


    /// Adds a handler for `NamedBusEvent`s with the specified type and name.
    ///
    /// - Parameters:
    ///   - eventType: The type of event to handle.
    ///   - name: The name of the event to handle.
    ///   - body: The closure to handle the event. This closure is passed the event and the instance’s `context`.
    /// - Returns: An opaque object that represents the added handler. This object can be used to remove the handler
    ///   later using `removeHandler(_:)`.
    @discardableResult
    public func addHandler<Event>(for eventType: Event.Type,
                                  name: Event.Name,
                                  body: @escaping (Event, inout Context) -> Void) -> AnyObject
        where Event : NamedBusEvent {
            let key = NamedEventHandlersKey(eventType: eventType, name: name)
            let handler = Handler(name: name, body: body)
            namedEventHandlersAccessor.syncWrite { (namedHandlers) in
                namedHandlers[key, default: []].append(handler)
            }
            return handler
    }


    /// Removes a previously added handler.
    ///
    /// - Parameter handler: The opaque object that represents the handler. This object must have been returned by an
    ///   earlier invocation of `addHandler(for:body:)` or `addHandler(for:name:body:)`.
    public func removeHandler(_ handler: AnyObject) {
        guard let handler = handler as? EventHandler else {
            return
        }

        if let key = NamedEventHandlersKey(eventHandler: handler) {
            namedEventHandlersAccessor.syncWrite { (namedHandlers) in
                namedHandlers[key]?.removeAll { $0 === handler }
            }
        } else {
            let key = EventHandlersKey(eventHandler: handler)
            eventHandlersAccessor.syncWrite { (handlers) in
                handlers[key]?.removeAll { $0 === handler }
            }
        }
    }


    // MARK: - Supporting Types

    /// `EventHandlersKey`s represent keys in the `eventHandlers` dictionary above. They are little more than an event
    /// type’s object identifier. We created a separate type to simplify the code that creates and uses these keys.
    private struct EventHandlersKey : Hashable {
        /// The object identifier for the handled event’s metatype.
        private let eventTypeObjectIdentifier: ObjectIdentifier


        /// Creates a new `EventHandlersKey` using the object identifier of `eventType`.
        ///
        /// - Parameter eventType: The handled event’s metatype.
        init<Event>(eventType: Event.Type) where Event : BusEvent {
            self.eventTypeObjectIdentifier = ObjectIdentifier(eventType)
        }


        /// Creates a new `EventHandlersKey` using the same `eventTypeObjectIdentifier` as that of `eventHandler`.
        ///
        /// - Parameter eventHandler: The event handler from which to get the `eventTypeObjectIdentifier` for the new
        ///   key.
        init(eventHandler: EventHandler) {
            self.eventTypeObjectIdentifier = eventHandler.eventTypeObjectIdentifier
        }
    }


    /// `NamedEventHandlersKey`s represent keys in the `namedEventHandlers` dictionary. They are a combination of the
    /// event type’s object identifier and the name.
    private struct NamedEventHandlersKey : Hashable {
        /// The object identifier for the handled event’s metatype.
        private let eventTypeObjectIdentifier: ObjectIdentifier

        /// The name of the handled event.
        private let name: AnyHashable


        /// Creates a new `NamedEventHandlersKey` using the object identifier of `eventType` and `name`.
        ///
        /// - Parameters:
        ///   - eventType: The handled event’s metatype.
        ///   - name: The handled event’s name.
        init<NamedEvent>(eventType: NamedEvent.Type, name: NamedEvent.Name) where NamedEvent : NamedBusEvent {
            self.eventTypeObjectIdentifier = ObjectIdentifier(eventType)
            self.name = name
        }


        /// Creates a new `NamedEventHandlersKey` using the same `eventTypeObjectIdentifier` and `name` as that of
        /// `eventHandler`. Returns `nil` if `eventHandler.name` is `nil`.
        ///
        /// - Parameter eventHandler: The event handler from which to get the `eventTypeObjectIdentifier` and `name` for
        ///   the new key.
        init?(eventHandler: EventHandler) {
            guard let name = eventHandler.name else {
                return nil
            }

            self.eventTypeObjectIdentifier = eventHandler.eventTypeObjectIdentifier
            self.name = name
        }
    }


    /// `Handler`s represent individual handlers stored by contextual event observers. Each handler stores the body of
    /// the handler plus an optional name for which the handler is registered.
    private class Handler<Event> : EventHandler {
        let name: AnyHashable?

        /// The closure to execute when a relevant event is observed.
        private let body: (Event, inout Context) -> Void


        /// Creates a new `Handler` with the specified name and body.
        ///
        /// - Parameters:
        ///   - name: The name of events handled by this handler. `nil` if the handler is for `BusEvent`s.
        ///   - body: The closure to execute when a relevant event is observed.
        init(name: AnyHashable? = nil, body: @escaping (Event, inout Context) -> Void) {
            self.name = name
            self.body = body
        }


        /// Executes the handler’s closure with the specified event and context.
        ///
        /// - Parameters:
        ///   - event: The observed event.
        ///   - context: The context to pass to the handler’s body.
        func handle(_ event: Event, with context: inout Context) {
            body(event, &context)
        }


        var eventTypeObjectIdentifier: ObjectIdentifier {
            return ObjectIdentifier(Event.self)
        }
    }
}


/// The `EventHandler` protocol provides a polymorphic interface for working with `Handler<Event>`s when the `Event`
/// type is unknown. It is used by `ContextualBusEventObserver` to remove handlers.
private protocol EventHandler : AnyObject {
    /// The object identifier for the handled event’s metatype.
    var eventTypeObjectIdentifier: ObjectIdentifier { get }

    /// The name for events handled by this handler. `nil` if the handler is for `BusEvent`s.
    var name: AnyHashable? { get }
}

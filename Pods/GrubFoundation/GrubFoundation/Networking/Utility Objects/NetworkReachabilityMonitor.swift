//
//  NetworkReachabilityMonitor.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 10/7/2017.
//  Copyright © 2017 Grubhub, Inc. All rights reserved.
//

import Foundation
import SystemConfiguration


/// `NetworkReachability` indicates a network’s reachability.
public enum NetworkReachability : CustomStringConvertible, CaseIterable {
    /// Indicates that the reachability is unknown.
    case unknown

    /// Indicates that there is no reachability.
    case none

    /// Indicates that the network is reachable via a cellular connection.
    case cellular

    /// Indicates that the network is reachable via Wi-Fi.
    case ethernetOrWiFi


    /// Returns whether the network is reachable, i.e., if the instance is `.cellular` or `.ethernetOrWiFi`.
    public var isReachable: Bool {
        return self == .cellular || self == .ethernetOrWiFi
    }


    public var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .none:
            return "None"
        case .cellular:
            return "Cellular"
        case .ethernetOrWiFi:
            return "Ethernet or Wi-Fi"
        }
    }
}


/// `NetworkReachabilityMonitor` monitors a network’s reachability and posts notifications when reachability changes.
/// The nature of network reachability means that you really shouldn’t use monitors to pre-emptively determine if a
/// network is reachable. Instead, you should attempt to connect, and if the network is unreachable, you can use a
/// network reachability monitor to determine when it becomes reachable again.
public class NetworkReachabilityMonitor {
    /// The default queue on which reachability change notifications are posted.
    public static let defaultNotificationQueue = DispatchQueue(
        label: "com.grubhub.GrubFoundation.NetworkReachabilityMonitor",
        attributes: [.concurrent]
    )

    /// Posted when network reachability changes. The object associated with this notification is the instance of
    /// `NetworkReachabilityMonitor` that monitored the change.
    public static let networkReachabilityDidChangeNotification = Notification.Name(
        "NetworkReachabilityMonitor.networkReachabilityDidChange"
    )


    /// The notification center on which reachability change notifications are posted.
    public var notificationCenter: NotificationCenter = .default

    /// The queue on which reachability change notifications are posted.
    public var notificationQueue: DispatchQueue = NetworkReachabilityMonitor.defaultNotificationQueue

    /// The notifier that the instance uses to monitor reachability changes.
    let notifier: NetworkReachabilityChangeNotifier


    /// Creates a new network reachability monitor with the specified notifier. The instance will post change
    /// notifications to the default notification center.
    ///
    /// - Parameters:
    ///   - notifier: The notifier that the instance uses to monitor network reachability changes.
    init(notifier: NetworkReachabilityChangeNotifier) {
        self.notifier = notifier
    }


    /// Creates a new instance that monitors network reachability to the specified host. Returns `nil` if a monitor
    /// could not be created due to an underlying system framework issue.
    ///
    /// - Parameter host: The host whose network reachability should be monitored.
    public convenience init?(host: String) {
        guard let reachability = SCNetworkReachability.reachability(forHost: host) else {
            return nil
        }

        self.init(notifier: SCNetworkReachabilityChangeNotifier(networkReachability: reachability))
    }


    /// Creates and returns a new network reachability monitor that monitors general network reachability. Returns `nil`
    /// if a monitor could not be created due to an underlying system framework issue.
    /// - Returns: A general network reachability monitor.
    public static func generalMonitor() -> NetworkReachabilityMonitor? {
        guard let reachability = SCNetworkReachability.generalReachability() else {
            return nil
        }

        return NetworkReachabilityMonitor(notifier: SCNetworkReachabilityChangeNotifier(networkReachability: reachability))
    }


    deinit {
        /// Stop monitoring if we were monitoring.
        stop()
    }


    /// Starts monitoring network reachability.
    ///
    /// - Returns: Whether monitoring could start. Returns `false` if a system framework error occurred.
    @discardableResult
    public func start() -> Bool {
        var lastReachability: NetworkReachability?
        return notifier.scheduleNotifications(on: notificationQueue) { [unowned self] (_) in
            if self.reachability != lastReachability {
                networkingLogger.logInfo("Reachability did change to \(self.reachability)")
                lastReachability = self.reachability
                self.notificationCenter.post(
                    name: NetworkReachabilityMonitor.networkReachabilityDidChangeNotification,
                    object: self
                )
            }
        }
    }


    /// Stops monitoring network reachability.
    ///
    /// - Returns: Whether monitoring could be stopped. Returns `false` if a system framework error occurred.
    @discardableResult
    public func stop() -> Bool {
        return notifier.unscheduleNotifications()
    }


    /// Returns the current reachability of the network being monitored.
    public var reachability: NetworkReachability {
        return notifier.flags?.networkReachability ?? .unknown
    }
}


private extension SCNetworkReachability {
    /// Returns an instance of `SCNetworkReachability` for the 0.0.0.0 address. This can be used to monitor general
    /// network reachability. Returns `nil` if an underyling system framework error occurs.
    ///
    /// - Returns: An instance of `SCNetworkReachability` for the 0.0.0.0 address.
    static func generalReachability() -> SCNetworkReachability? {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        return withUnsafePointer(to: &zeroAddress) { addressPointer in
            return addressPointer.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr>.size) { (address) in
                return SCNetworkReachabilityCreateWithAddress(nil, address)
            }
        }
    }

    /// Returns an instance of `SCNetworkReachability` for the specified host. Returns `nil` if an underyling system
    /// framework error occurs.

    /// - Parameter host: The host.
    /// - Returns: An instance of `SCNetworkReachability` for the specified host.
    static func reachability(forHost host: String) -> SCNetworkReachability? {
        return SCNetworkReachabilityCreateWithName(nil, host)
    }
}


public extension SCNetworkReachabilityFlags {
    /// The network reachability given the instance’s flags.
    var networkReachability: NetworkReachability {
        // This code is adapted from Apple’s Reachability sample, which is available at:
        // https://developer.apple.com/library/content/samplecode/Reachability/Introduction/Intro.html
        guard contains(.reachable) else {
            return .none
        }

        var reachability: NetworkReachability = .none

        // If the target is reachable and no connection is required then we'll assume ethernet or wi-fi (for now)
        if !contains(.connectionRequired) {
            reachability = .ethernetOrWiFi
        } else if !contains(.interventionRequired) && (contains(.connectionOnDemand) || contains(.connectionOnTraffic)) {
            reachability = .ethernetOrWiFi
        }

        #if !os(macOS)
            // If WWAN is mentioned at all, it’s cellular
            if contains(.isWWAN) {
                reachability = .cellular
            }
        #endif

        return reachability
    }
}


/// Types that conform to `NetworkReachabilityChangeNotifier` can notify an interested party of changes to
/// network reachability.
protocol NetworkReachabilityChangeNotifier {
    /// The network reachability flags for the network whose reachability is being monitored for changes.
    var flags: SCNetworkReachabilityFlags? { get }

    /// Schedules change notifications to be delivered by executing `notifyBody` on the `queue`. Scheduling
    /// notifications while notifications are already scheduled replaces the previous queue and closure with the new
    /// one.
    ///
    /// - Parameters:
    ///   - queue: The dispatch queue on which notifications are delivered.
    ///   - notifyBody: The closure that executes to notify the interested party of reachability changes.
    /// - Returns: Whether notifications could be scheduled or not.
    func scheduleNotifications(on queue: DispatchQueue, notifyBody: @escaping (SCNetworkReachabilityFlags) -> Void) -> Bool

    /// Unschedules change notifications to the previously set dispatch queue.
    /// - Returns: Whether notifications could be unscheduled or not.
    func unscheduleNotifications() -> Bool
}


/// `SCNetworkReachabilityChangeNotifier` wraps `SCNetworkReachability` instances so that they can notify changes
/// via the `NetworkReachabilityChangeNotifier` protocol.
private final class SCNetworkReachabilityChangeNotifier : NetworkReachabilityChangeNotifier {
    /// The network reachability object being whose changes are being monitored.
    private let networkReachability: SCNetworkReachability

    /// The closure that is executed to notify interested parties.
    private var notifyBody: ((SCNetworkReachabilityFlags) -> Void)?


    /// Creates a new instance that monitors changes to the specified `SCNetworkReachability` instance.
    ///
    /// - Parameter networkReachability: The network address to monitor.
    init(networkReachability: SCNetworkReachability) {
        self.networkReachability = networkReachability
    }


    public var flags: SCNetworkReachabilityFlags? {
        var flags: SCNetworkReachabilityFlags = []
        return SCNetworkReachabilityGetFlags(networkReachability, &flags) ? flags : nil
    }


    public func scheduleNotifications(
        on queue: DispatchQueue,
        notifyBody: @escaping (SCNetworkReachabilityFlags) -> Void
    ) -> Bool {
        self.notifyBody = notifyBody

        // Our info object will be an unretained pointer to self
        var context = SCNetworkReachabilityContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )

        let setCallbackSucceeded = SCNetworkReachabilitySetCallback(networkReachability, { (_, flags, info) in
            // Grab self back out of the info object and invoke notifyBody on it
            let notifier = Unmanaged<SCNetworkReachabilityChangeNotifier>.fromOpaque(info!).takeUnretainedValue()
            notifier.notifyBody?(flags)
        }, &context)

        return setCallbackSucceeded && SCNetworkReachabilitySetDispatchQueue(networkReachability, queue)
    }


    public func unscheduleNotifications() -> Bool {
        return SCNetworkReachabilitySetCallback(networkReachability, nil, nil) &&
            SCNetworkReachabilitySetDispatchQueue(networkReachability, nil)
    }
}

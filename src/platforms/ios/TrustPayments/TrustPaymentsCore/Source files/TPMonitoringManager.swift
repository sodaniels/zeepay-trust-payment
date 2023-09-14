//
//  TPMonitoringManager.swift
//  TrustPaymentsCore
//

import Sentry
import UIKit

protocol TPMonitoringManagerDataSource: AnyObject {
    var environmentType: String? { get }
    var gatewayType: String? { get }
    var gatewayUrl: String? { get }
    var username: String? { get }
}

/// A common place for managing logs.
class TPMonitoringManager {

    private let undefinedParameterPlaceholder = "undefined"
    private let sentryHub: SentryHub
    weak var dataSource: TPMonitoringManagerDataSource?

    init(dataSource: TPMonitoringManagerDataSource) {
        self.dataSource = dataSource
        let options = Options()
        if UserDefaults.standard.bool(forKey: "isTesting") == false {
            options.dsn = "https://39b1202f93d84a6fabc8967b9ef92755@o402164.ingest.sentry.io/6066724"
        }
        let client = Client(options: options)
        sentryHub = SentryHub(client: client, andScope: nil)
    }

    private var commonTags: [String: String] {
        [
            "os.name": UIDevice.current.systemName,
            "os.version": UIDevice.current.systemVersion,
            "device": UIDevice.current.model
        ]
    }

    func log(severity: LogSeverity, message: String, additionals: [String: String?] = [:]) {
        var tags = commonTags
        tags["level"] = severity == .error ? "error" : "info"
        tags["gateway.type"] = dataSource?.gatewayType
        tags["gateway.url"] = dataSource?.gatewayUrl

        let username = dataSource?.username ?? undefinedParameterPlaceholder
        let user = User(userId: username)
        user.username = username

        let breadcrumbs = Breadcrumb()
        breadcrumbs.timestamp = Date()
        var breadcrumbsData: [String: String] = additionals.compactMapValues { $0 }
        breadcrumbsData["username"] = username
        breadcrumbsData["timestamp"] = Date().description
        breadcrumbs.data = breadcrumbsData

        let event = Event()
        event.level = severity == .error ? .error : .info
        event.message = SentryMessage(formatted: message)
        event.logger = message
        event.tags = tags
        event.user = user
        event.breadcrumbs = [breadcrumbs]
        event.environment = dataSource?.environmentType
        event.releaseName = Bundle(for: TPMonitoringManager.self).releaseVersionNumber ?? undefinedParameterPlaceholder

        // Send event to Sentry
        if UserDefaults.standard.bool(forKey: "isTesting") == false, dataSource?.gatewayType != "devbox" {
            sentryHub.capture(event: event)
        }
    }
}

extension TPMonitoringManager {
    enum LogSeverity {
        case info
        case error
    }
}

// Copyright © 2021 Stormbird PTE. LTD.

import UIKit

protocol FiatOnRampCoordinatorDelegate: AnyObject, CanOpenURL {
}

class FiatOnRampCoordinator: Coordinator {
    private let wallet: Wallet
    private let server: RPCServer
    private let sourceViewController: UIViewController
    private let source: Analytics.FiatOnRampSource
    private let analytics: AnalyticsLogger

    var coordinators: [Coordinator] = []
    weak var delegate: FiatOnRampCoordinatorDelegate?

    init(wallet: Wallet, server: RPCServer, viewController: UIViewController, source: Analytics.FiatOnRampSource, analytics: AnalyticsLogger) {
        self.wallet = wallet
        self.server = server
        self.sourceViewController = viewController
        self.source = source
        self.analytics = analytics
    }

    func start() {
        let ramp = Ramp(account: wallet)
        if let url = ramp.url(token: MultipleChainsTokensDataStore.functional.etherToken(forServer: server)) {
            FiatOnRampCoordinator.logStartOnRamp(name: "Ramp", source: source, analytics: analytics)
            delegate?.didPressOpenWebPage(url, in: sourceViewController)
        } else {
            let fallbackUrl = URL(string: "https://alphawallet.com/browser-item-category/utilities/")!
            delegate?.didPressOpenWebPage(fallbackUrl, in: sourceViewController)
        }
    }

    static func logStartOnRamp(name: String, source: Analytics.FiatOnRampSource, analytics: AnalyticsLogger) {
        analytics.log(navigation: Analytics.Navigation.onRamp, properties: [Analytics.Properties.name.rawValue: name, Analytics.Properties.source.rawValue: source.rawValue])
    }
}

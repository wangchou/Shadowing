//
//  IAPHelper.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/26/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Alamofire
import FirebaseAnalytics
import Promises
import StoreKit
import UIKit

enum IAPProduct: String {
    case unlimitedForever
    case unlimitedOneMonth
    case unlimitedThreeMonths
}

let productIds: Set<String> = [
    IAPProduct.unlimitedForever.rawValue,
    IAPProduct.unlimitedOneMonth.rawValue,
    IAPProduct.unlimitedThreeMonths.rawValue,
]

enum RequestURL: String {
    case production = "https://buy.itunes.apple.com/verifyReceipt"
    case sandbox = "https://sandbox.itunes.apple.com/verifyReceipt"

    var url: URL {
        return URL(string: rawValue)!
    }
}

enum GetExpirationError: Error {
    case noReceiptToSumit
    case networkError
    case otherError
}

class IAPHelper: NSObject {
    static let shared = IAPHelper()
    var products: [SKProduct] = []
    var timer: Timer?
    var processingAlertView: UIAlertController?

    func startListening() {
        SKPaymentQueue.default().add(self)
    }

    func requsestProducts() {
        let productsRequest = SKProductsRequest(productIdentifiers: productIds)
        productsRequest.delegate = self
        productsRequest.start()
    }

    func buy(_ product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            showOkAlert(title: i18n.cannotMakePayment)
        }
    }

//    func restorePurchases() {
//        SKPaymentQueue.default().restoreCompletedTransactions()
//    }

    func showPurchaseView(isChallenge: Bool = true) {
        let eventName = "iap_view_\(isChallenge ? "challenge_button" : "free_button")"
        #if !(targetEnvironment(macCatalyst))
        Analytics.logEvent("\(eventName)_show", parameters: nil)
        #endif
        let actionSheet = UIAlertController(
            title: isChallenge ? i18n.purchaseViewTitle : i18n.itIsfreeVersion,
            message: isChallenge ? i18n.purchaseViewMessage : i18n.freeButtonPurchaseMessage,
            preferredStyle: .actionSheet
        )

        let cancelTitle = isChallenge ? i18n.startChallenge : i18n.close

        let cancelAction = UIAlertAction(title: cancelTitle, style: isIPad ? .default : .cancel)

        // Add the actions
        if isChallenge || !isIPad {
            actionSheet.addAction(cancelAction)
        }

        #if targetEnvironment(macCatalyst)
        actionSheet.addAction(cancelAction)
        #endif

        let restoreAction = UIAlertAction(title: i18n.restorePreviousPurchase, style: .destructive) { [weak self] _ in
            actionSheet.dismiss(animated: true, completion: nil)
            self?.refreshReceipt()
        }
        actionSheet.addAction(restoreAction)

        // Create the actions
        let sortedProducts = products.sorted {
            $0.price.doubleValue >= $1.price.doubleValue
        }
        for product in sortedProducts {
            var priceString = ""
            var localizedTitle = ""

            switch product.priceLocale.currencyCode {
            case "JPY":
                priceString = "\(product.price)円"
            default:
                priceString = "\(product.priceLocale.currencySymbol ?? "")\(product.price) \(product.priceLocale.currencyCode ?? "")"
            }

            switch product.productIdentifier {
            case IAPProduct.unlimitedOneMonth.rawValue:
                localizedTitle = i18n.buyOneMonth
            case IAPProduct.unlimitedThreeMonths.rawValue:
                continue
            case IAPProduct.unlimitedForever.rawValue:
                localizedTitle = i18n.buyForever
            default:
                ()
            }

            let title = "\(localizedTitle) \(priceString)"
            let buyAction = UIAlertAction(title: title, style: .default) { [weak self] _ in
                actionSheet.dismiss(animated: true, completion: nil)
                self?.buy(product)
                #if !(targetEnvironment(macCatalyst))
                Analytics.logEvent("\(eventName)_buy",
                                   parameters: [AnalyticsParameterItemID: product.productIdentifier])
                #endif
            }
            actionSheet.addAction(buyAction)
        }

        // https://medium.com/@nickmeehan/actionsheet-popover-on-ipad-in-swift-5768dfa82094
        if let popoverController = actionSheet.popoverPresentationController,
            let vc = UIApplication.getPresentedViewController() {
            popoverController.sourceView = vc.view
            popoverController.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        UIApplication.getPresentedViewController()?.present(actionSheet, animated: true)
    }
}

// MARK: - SKProductsRequestDelegate

extension IAPHelper: SKProductsRequestDelegate {
    func productsRequest(_: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKReceiptRefreshRequest {
            processingAlertView?.dismiss(animated: false) { self.processingAlertView = nil }
            showOkAlert(title: error.localizedDescription)
        }
    }

    func requestDidFinish(_ request: SKRequest) {
        if request is SKReceiptRefreshRequest {
            processReceipt()
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                if isEverReceiptProcessed {
                    self?.timer?.invalidate()
                    self?.processingAlertView?.dismiss(animated: false) { [weak self] in
                        self?.processingAlertView = nil
                        showOkAlert(title: i18n.previousPurchaseRestored)
                        rootViewController.rerenderTopView()
                    }
                }
            }
        }
    }
}

// MARK: - SKPaymentTransactionObserver

extension IAPHelper: SKPaymentTransactionObserver {
    func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        var shouldProcessReceipt = false
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                print("=== Purchased Transaction ===")
                shouldProcessReceipt = true
                updateExpirationDate(
                    productId: transaction.payment.productIdentifier,
                    purchaseDateInMS: transaction.transactionDate?.ms ?? Date().ms
                )
                SKPaymentQueue.default().finishTransaction(transaction)

            case .failed:
                processingAlertView?.dismiss(animated: false) { self.processingAlertView = nil }
                showOkAlert(title: transaction.error?.localizedDescription)
                print("purchase failed", transaction.error as Any)
                SKPaymentQueue.default().finishTransaction(transaction)

            case .restored:
                print("=== Restore Transaction ===")
                shouldProcessReceipt = true
                updateExpirationDate(
                    productId: transaction.payment.productIdentifier,
                    purchaseDateInMS: transaction.original?.transactionDate?.ms ?? Date().ms
                )
                SKPaymentQueue.default().finishTransaction(transaction)

            case .purchasing:
                processingAlertView = showProcessingAlert()

            default:
                NSLog("do nothing")
            }
        }

        if shouldProcessReceipt {
            processingAlertView?.dismiss(animated: false) { self.processingAlertView = nil }
            showOkAlert(title: i18n.previousPurchaseRestored)
            rootViewController.rerenderTopView()
            processReceipt()
        }
    }
}

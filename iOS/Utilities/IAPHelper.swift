//
//  IAPHelper.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/26/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import StoreKit

let productIds: Set<String> = [
    "unlimitedForever",
    "unlimitedOneMonth",
    "unlimitedThreeMonths"
]

class IAPHelper: NSObject {

    static let shared = IAPHelper()

    func requsestProducts() {
        let productsRequest = SKProductsRequest(productIdentifiers: productIds)
        productsRequest.delegate = self
        productsRequest.start()
    }

    func buy(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}

func showReceipt() {
    let receipt = NSData(contentsOf:
        Bundle.main.appStoreReceiptURL!
    )
    print(receipt)
}

extension IAPHelper: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Start to list products:")
        for p in response.products {
            print("Found product: \(p.productIdentifier) \(p.isDownloadable) \(p.localizedTitle) \(p.price.floatValue) \(p.priceLocale)")
        }
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}

extension IAPHelper: SKPaymentTransactionObserver {

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                //complete(transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .failed:
                //fail(transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .restored:
                //restore(transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
}

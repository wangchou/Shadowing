//
//  IAPHelper.swift
//  今話したい
//
//  Created by Wangchou Lu on 11/26/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import StoreKit
import Alamofire
import Promises

enum IAPProduct: String {
    case unlimitedForever
    case unlimitedOneMonth
    case unlimitedThreeMonths
}

let productIds: Set<String> = [
    IAPProduct.unlimitedForever.rawValue,
    IAPProduct.unlimitedOneMonth.rawValue,
    IAPProduct.unlimitedThreeMonths.rawValue
]

enum RequestURL: String {
    case production = "https://buy.itunes.apple.com/verifyReceipt"
    case sandbox = "https://sandbox.itunes.apple.com/verifyReceipt"

    var url: URL {
        return URL(string: self.rawValue)!
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

    public func startListening() {
        SKPaymentQueue.default().add(self)
    }

    func requsestProducts() {
        let productsRequest = SKProductsRequest(productIdentifiers: productIds)
        productsRequest.delegate = self
        productsRequest.start()
    }

    func buy(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        if SKPaymentQueue.canMakePayments() {
            print("can make payments")
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("X cannot make payments")
        }
    }

    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

}

extension IAPHelper: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Start to list products:")
        for p in response.products {
            print("Found product: \(p.productIdentifier) \(p.isDownloadable) \(p.localizedTitle) \(p.price.floatValue) \(p.priceLocale)")
            products = response.products
        }
        buy(products[1])
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}

extension IAPHelper: SKRequestDelegate {
    public func requestDidFinish(_ request: SKRequest) {
        if request is SKReceiptRefreshRequest {
            print("refresh request finished")
            processReceipt()
        }
    }
}

extension IAPHelper: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                print("=== Purchased Transation ===")
                updateExpirationDateByProduct(
                    productId: transaction.payment.productIdentifier,
                    purchaseDateInMS: transaction.transactionDate?.millisecondsSince1970 ?? Date().millisecondsSince1970)
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                print("purchase failed", transaction.error as Any)
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                print("=== Restore Transation ===")

                // https://stackoverflow.com/questions/14328374/skpaymenttransaction-what-is-transactiondate-exactly
                updateExpirationDateByProduct(
                    productId: transaction.payment.productIdentifier,
                    purchaseDateInMS: transaction.original?.transactionDate?.millisecondsSince1970 ?? Date().millisecondsSince1970)
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                NSLog("do nothing")
            }
        }
    }
}

// validate receipt
extension IAPHelper {
    func processReceipt() {
        if let receiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: receiptURL.path) {
            validateReceiptBySendingTo(RequestURL.production.url)
        } else {
            let request = SKReceiptRefreshRequest(receiptProperties: nil)
            request.delegate = self
            request.start()
        }
    }

    func validateReceiptBySendingTo(_ requestURL: URL) {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: receiptURL.path) else {
            NSLog("No receipt available to submit")
            return
        }

        do {
            let receipt: Data = try Data(contentsOf: receiptURL)
            let parameters: Parameters =  [
                "receipt-data": receipt.base64EncodedString(),
                "password": sharedSecret
            ]
            Alamofire.request(
                requestURL,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default
                ).responseJSON { response in
                    switch response.result {
                    case .success:
                        if let value = response.result.value as? [String: Any] {
                            let status = value["status"] as? Int ?? -1
                            switch status {
                            case 0:
                                let receipt = value["receipt"] as! [String: Any]
                                self.updateExpirationDateByReceipt(receipt)

                            case 21007:  // special code for sandbox from Apple
                                self.validateReceiptBySendingTo(RequestURL.sandbox.url)

                            default:
                                print("something wrong with error code:", status)
                            }
                        } else {
                            print("Receiving receipt from App Store failed: \(response.result)")

                        }
                    case .failure:
                        print("Network Error")
                    }
            }
        } catch {
            print("Error occurs in getExpirationDate")
        }
    }

    private func updateExpirationDateByReceipt(_ receipt: [String: Any]) {
        let receiptType = receipt["receipt_type"] as? String ?? ""
        let isSandbox = receiptType.range(of: "andbox") != nil //sandbox
        let originalAppVerison = receipt["original_application_version"] as? String ?? "0.0"
        let inApp = (receipt["in_app"] as? [[String: Any]]) ?? []
        let keyInfoInApp = inApp.map { dict -> (String, Int64) in
            return (
                dict["product_id"] as? String ?? "unknown",
                Int64(dict["purchase_date_ms"] as? String ?? "") ?? 0
            )
        }
        debugPrint(originalAppVerison, keyInfoInApp)
        if !isSandbox {
            updateExpirationDateByOriginalAppVersion(appVersion: originalAppVerison)
        }
        print("=== Receipt Validation ===")

        keyInfoInApp.forEach {(arg) in
            let (productId, dateInMS) = arg
            updateExpirationDateByProduct(productId: productId, purchaseDateInMS: dateInMS)
        }
    }
}

/*
 KEY INFOS from Example Receipt from sandbox
 {
     "in_app" =     (
         {
         "original_purchase_date_ms" = 1543388813000;
         "product_id" = unlimitedOneMonth;
         },
         {
         "original_purchase_date_ms" = 1543388982000;
         "product_id" = unlimitedOneMonth;
         }
     );
     "original_application_version" = "1.0";
 }

 Full Example Receipt from sandbox
 {
     "adam_id" = 0;
     "app_item_id" = 0;
     "application_version" = 1;
     "bundle_id" = "idv.wcl.imahanashitai";
     "download_id" = 0;
     "in_app" =     (
         {
         "is_trial_period" = false;
         "original_purchase_date" = "2018-11-28 07:06:53 Etc/GMT";
         "original_purchase_date_ms" = 1543388813000;
         "original_purchase_date_pst" = "2018-11-27 23:06:53 America/Los_Angeles";
         "original_transaction_id" = 1000000479095355;
         "product_id" = unlimitedOneMonth;
         "purchase_date" = "2018-11-28 07:06:53 Etc/GMT";
         "purchase_date_ms" = 1543388813000;
         "purchase_date_pst" = "2018-11-27 23:06:53 America/Los_Angeles";
         quantity = 1;
         "transaction_id" = 1000000479095355;
         },
         {
         "is_trial_period" = false;
         "original_purchase_date" = "2018-11-28 07:09:42 Etc/GMT";
         "original_purchase_date_ms" = 1543388982000;

         "original_purchase_date_pst" = "2018-11-27 23:09:42 America/Los_Angeles";
         "original_transaction_id" = 1000000479096895;
         "product_id" = unlimitedOneMonth;
         "purchase_date" = "2018-11-28 07:09:42 Etc/GMT";
         "purchase_date_ms" = 1543388982000;
         "purchase_date_pst" = "2018-11-27 23:09:42 America/Los_Angeles";
         quantity = 1;
         "transaction_id" = 1000000479096895;
         }
      );
     "original_application_version" = "1.0";
     "original_purchase_date" = "2013-08-01 07:00:00 Etc/GMT";
     "original_purchase_date_ms" = 1375340400000;
     "original_purchase_date_pst" = "2013-08-01 00:00:00 America/Los_Angeles";
     "receipt_creation_date" = "2018-11-28 12:45:16 Etc/GMT";
     "receipt_creation_date_ms" = 1543409116000;
     "receipt_creation_date_pst" = "2018-11-28 04:45:16 America/Los_Angeles";
     "receipt_type" = ProductionSandbox;
     "request_date" = "2018-11-29 03:30:34 Etc/GMT";
     "request_date_ms" = 1543462234332;
     "request_date_pst" = "2018-11-28 19:30:34 America/Los_Angeles";
     "version_external_identifier" = 0;
 }
*/

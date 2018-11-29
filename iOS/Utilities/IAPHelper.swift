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

let productIds: Set<String> = [
    "unlimitedForever",
    "unlimitedOneMonth",
    "unlimitedThreeMonths"
]

enum RequestURL: String {
    case production = "https://buy.itunes.apple.com/verifyReceipt"
    case sandbox = "https://sandbox.itunes.apple.com/verifyReceipt"
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

    public func requestDidFinish(_ request: SKRequest) {
        if let _ = request as? SKReceiptRefreshRequest {
            print("refresh request finished")
            processReceipt()
        }
    }
}

extension IAPHelper: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        var shouldProcessReceipt = false
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                print("purchased")
                shouldProcessReceipt = true
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                print("purchase failed", transaction.error as Any)
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                print("purchase restored")
                shouldProcessReceipt = true
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                NSLog("do nothing")
            }
        }
        if shouldProcessReceipt {
            processReceipt()
        }
    }
}

// validate receipt
extension IAPHelper {
    func processReceipt() {
        if let receiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: receiptURL.path) {

            expirationDateFromProd(completion: { (date, sandbox, error) in
                if error != nil {
                    //self.completionBlock?(false, "The purchase failed.", error)
                    print("purchase fail \(String(describing: error))")
                } else if let date = date, Date().compare(date) == .orderedAscending {
                    //self.completionBlock?(true, self.productIdentifier, nil)
                    print("purchase success with dat = \(date) \(sandbox)")
                }
            })
        } else {
            let request = SKReceiptRefreshRequest(receiptProperties: nil)
            request.delegate = self
            request.start()
        }
    }

    func expirationDateFromProd(completion: @escaping (Date?, Bool, Error?) -> Void) {
        if let requestURL = URL(string: RequestURL.production.rawValue) {
            getExpirationDate(requestURL).then { (expiration, status, error) in
                if status == 21007 {
                    self.expirationDateFromSandbox(completion: completion)
                } else {
                    completion(expiration, false, error)
                }
            }
        }
    }

    func expirationDateFromSandbox(completion: @escaping (Date?, Bool, Error?) -> Void) {
        if let requestURL = URL(string: RequestURL.sandbox.rawValue) {
            getExpirationDate(requestURL).then { (expiration, status, error) in
                completion(expiration, true, error)
            }
        }
    }

    func getExpirationDate(_ requestURL: URL) -> Promise<(Date?, Int?, Error?)> {
        let promise = Promise<(Date?, Int?, Error?)>.pending()
        guard let receiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: receiptURL.path) else {
            NSLog("No receipt available to submit")
            promise.fulfill((nil, nil, GetExpirationError.noReceiptToSumit))
            return promise
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
                            if status != 0 {
                                print(status, value)
                            } else {
                                let receipt = value["receipt"] as! [String: Any]
                                let originalAppVerison = receipt["original_application_version"] ?? "0.0"
                                let inApp = (receipt["in_app"] as? [[String: Any]]) ?? []
                                let keyInfoInApp = inApp.map { dict -> (String, Int) in
                                    return (dict["product_id"] as? String ?? "unknown", Int(dict["purchase_date_ms"] as? String ?? "") ?? 0)
                                }
                                debugPrint(status, originalAppVerison, keyInfoInApp)
                            }
                            promise.fulfill((nil, status, nil))
                        } else {
                            print("Receiving receipt from App Store failed: \(response.result)")
                            promise.fulfill((nil, nil, nil))
                        }
                    case .failure:
                        promise.fulfill((nil, nil, GetExpirationError.networkError))
                    }
            }
        } catch {
            print("Error occurs in getExpirationDate")
            promise.fulfill((nil, nil, GetExpirationError.otherError))
            return promise
        }
        return promise
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

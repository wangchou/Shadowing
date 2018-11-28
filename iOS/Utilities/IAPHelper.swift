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

class IAPHelper: NSObject {

    static let shared = IAPHelper()

    func requsestProducts() {
        let productsRequest = SKProductsRequest(productIdentifiers: productIds)
        productsRequest.delegate = self
        productsRequest.start()
    }

    func buy(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }

    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    func processReceipt() {
        if let receiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: receiptURL.path) {

            expirationDateFromProd(completion: { (date, sandbox, error) in
                if error != nil {
                    //self.completionBlock?(false, "The purchase failed.", error)
                    print("purchase fail \(error)")
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
            expirationDate(requestURL) { (expiration, status, error) in
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
            expirationDate(requestURL) { (expiration, status, error) in
                completion(expiration, true, error)
            }
        }
    }

    func getExpirationDate(_ kanjiString: String) -> Promise<Date?> {
        let promise = Promise<Date?>.pending()
        let receiptURL = Bundle.main.appStoreReceiptURL!
        do {
        let receiptData : Data = try Data(contentsOf:receiptURL)
        let parameters: Parameters =  ["receipt-data": receiptData.base64EncodedString(),
                                       "password" : sharedSecret]

        Alamofire.request(
            receiptURL,
            method: .post,
            parameters: parameters
            ).responseJSON { response in
                switch response.result {
                case .success:
                    guard let date = response.result.value as? Date else {
                        print("parse date response error")
                        promise.fulfill(nil)
                        return
                    }
                    promise.fulfill(date)

                case .failure:
                    promise.fulfill(nil)
                }
        }
        } catch {
            print("Error occurs in getExpirationDate")
            promise.fulfill(nil)
            return promise
        }
        return promise
    }


    func expirationDate(_ requestURL: URL, completion: @escaping (Date?, Int?, Error?) -> Void) {
        guard let receiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: receiptURL.path) else {
            NSLog("No receipt available to submit")
            completion(nil, nil, nil)
            return;
        }

        do {
            let request = try receiptValidationRequest(for: requestURL)

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                var code : Int = -1
                var date : Date?

                if error != nil {
                    if let httpR = response as? HTTPURLResponse {
                        code = httpR.statusCode
                    }
                } else if let data = data {
                    (code, date) = self.extractValues(from: data)
                } else {
                    NSLog("No response!")
                }
                completion(date, code, error)
                }.resume()
        } catch let error {
            completion(nil, -1, error)
        }
    }

    func receiptValidationRequest(for requestURL: URL) throws -> URLRequest {
        let receiptURL = Bundle.main.appStoreReceiptURL!
        let receiptData : Data = try Data(contentsOf:receiptURL)
        let payload = ["receipt-data": receiptData.base64EncodedString().toJSON(),
                       "password" : sharedSecret.toJSON()]
        let serializedPayload = try JSON.dictionary(payload).serialize()

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.httpBody = serializedPayload

        return request
    }

    func extractValues(from data: Data) -> (Int, Date?) {
        var date : Date?
        var statusCode : Int = -1

        do {
            let jsonData = try JSON(data: data)
            statusCode = try jsonData.getInt(at: "status")

            let receiptInfo = try jsonData.getArray(at: "latest_receipt_info")
            if let lastReceipt = receiptInfo.last {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
                date = formatter.date(from: try lastReceipt.getString(at: "expires_date"))
            }
        } catch {
        }

        return (statusCode, date)
    }
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
        var shouldProcessReceipt = false
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                shouldProcessReceipt = true
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                shouldProcessReceipt = true
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                NSLog("do nothing")
            }
        }
        if(shouldProcessReceipt) {
            processReceipt()
        }
    }
}

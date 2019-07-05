//
//  IAPHelper+ValidateReceipt.swift
//  今話したい
//
//  Created by Wangchou Lu on 12/23/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

import Alamofire
import StoreKit

private var isSandbox = false

// MARK: - validate receipt

extension IAPHelper {
    // https://stackoverflow.com/questions/43146453/ios-receipt-not-found
    // There is no receipt on debug mode / testflight / sandbox mode
    // until make first IAP purchase or SKReceiptRefreshRequest

    func processReceipt() {
        if let receiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: receiptURL.path) {
            validateReceiptBySendingTo(RequestURL.production.url)
        }
    }

    // make SKReceiptRefreshRequest will popup an Apple Id login box
    func refreshReceipt() {
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self
        request.start()
        processingAlertView = showProcessingAlert()
    }

    private func validateReceiptBySendingTo(_ requestURL: URL) {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: receiptURL.path) else {
            NSLog("No receipt available to submit")
            return
        }

        do {
            let receipt: Data = try Data(contentsOf: receiptURL)
            let parameters: Parameters = [
                "receipt-data": receipt.base64EncodedString(),
                "password": sharedSecret,
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
                            if let receipt = value["receipt"] as? [String: Any] {
                                self.updateExpirationDateByReceipt(receipt)
                            }

                        case 21007: // special code for sandbox from Apple
                            isSandbox = true
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
        gameExpirationDate = Date(ms: 0)
        // let receiptType = receipt["receipt_type"] as? String ?? ""
        // let isSandbox = receiptType.range(of: "andbox") != nil //sandbox
        let originalPurchaseDateMS = Int64(receipt["original_purchase_date_ms"] as? String ?? "0") ?? 0

        let inApp = (receipt["in_app"] as? [[String: Any]]) ?? []
        let keyInfoInApp = inApp.map { dict -> (productId: String, ms: Int64) in
            guard dict["cancellation_date"] == nil else { return ("cancelled", 0) }
            return (
                dict["product_id"] as? String ?? "unknown",
                Int64(dict["purchase_date_ms"] as? String ?? "") ?? 0
            )
        }

        if !isSandbox {
            updateExpirationDate(originalPurchaseDateMS: originalPurchaseDateMS)
        }
        print("=== Receipt Validation ===")

        keyInfoInApp
            .sorted {
                return $0.ms < $1.ms
            }
            .forEach { arg in
                let (productId, dateInMS) = arg
                updateExpirationDate(productId: productId, purchaseDateInMS: dateInMS)
            }

        isEverReceiptProcessed = true
        saveGameExpirationDate()
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

// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit

struct GetTransactionRequest: JSONRPCKit.Request {
    typealias Response = PendingTransaction?

    let hash: String

    var method: String {
        return "eth_getTransactionByHash"
    }

    var parameters: Any? {
        return [hash]
    }

    func response(from resultObject: Any) throws -> Response {
        if resultObject is NSNull {
            debugLog("[RPC] Fetch transaction by hash: \(hash) is null")
            return nil
        }
        guard
            let dict = resultObject as? [String: AnyObject],
            let transaction = PendingTransaction.from(dict)
        else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
        return transaction
    }
}

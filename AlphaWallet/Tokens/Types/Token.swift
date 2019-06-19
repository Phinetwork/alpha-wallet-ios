//
//  Token.swift
//  Alpha-Wallet
//
//  Created by Oguzhan Gungor on 2/25/18.
//  Copyright © 2018 Alpha-Wallet. All rights reserved.
//

import Foundation
import BigInt

struct Token {
    enum Status {
        case available, sold, redeemed, forSale, transferred, pending, availableButDataUnavailable
    }

    let id: BigUInt
    let index: UInt16
    let name: String
    let symbol: String
    let status: Status
    let values: [AttributeId: AssetAttributeSyntaxValue]

    static var empty: Token {
        return Token(
                id: Constants.nullTokenIdBigUInt,
                index: 0,
                name: R.string.localizable.tokensTitlecase(),
                symbol: "",
                status: .available,
                values: [
                    "locality": .init(defaultValueWithSyntax: .directoryString),
                    "venue": .init(defaultValueWithSyntax: .directoryString),
                    "match": .init(defaultValueWithSyntax: .integer),
                    "time": .init(defaultValueWithSyntax: .generalisedTime),
                    "numero": .init(defaultValueWithSyntax: .integer),
                    "category": .init(defaultValueWithSyntax: .directoryString),
                    "countryA": .init(defaultValueWithSyntax: .directoryString),
                    "countryB": .init(defaultValueWithSyntax: .directoryString)
                ]
        )
    }

    //TODO have a better way to test for spawnable meetup contracts
    var isSpawnableMeetupContract: Bool {
        return values["expired"] != nil && values["locality"] != nil && values["building"] != nil
    }
}

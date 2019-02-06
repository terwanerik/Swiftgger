//
//  OpenAPIObjectProperty.swift
//  Swiftgger
//
//  Created by Marcin Czachurski on 21.03.2018.
//

import Foundation

/// Information about property which exists in schema (input/output) data.
public class OpenAPIObjectProperty: Encodable {

    public private(set) var type: String
    public private(set) var example: AnyCodable?

    init(type: String, example: AnyCodable?) {
        self.type = type
        self.example = example
    }
}

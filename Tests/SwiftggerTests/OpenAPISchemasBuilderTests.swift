//
//  OpenAPISchemasBuilderTests.swift
//  SwiftggerTests
//
//  Created by Marcin Czachurski on 26.03.2018.
//

import XCTest
@testable import Swiftgger

class Vehicle: Codable {
    var name: String
    var age: Int?

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

struct Spaceship: Codable {
    var name: String
    var speed: Double?
    
    init(name: String, speed: Double) {
        self.name = name
        self.speed = speed
    }
}

struct Galaxy: Codable {
    var name: String
    var vehicle: Vehicle
    var spaceships: [Spaceship]
    var strings: [String]
}

/**
    Tests for schames part of OpenAPI standard (/components/schemas).

    ```
    "components": {
        "schemas": {
            "Vehicle" : {
                 "type": "object",
                 "properties": {
                     "age": {
                         "type": "int",
                     },
                     "name": {
                        "type": "string"
                     }
                 },
                 "required": [
                    "name"
                 ],
                 "example": {
                     "name": "Ford",
                     "age": 21
                 }
            }
        }
    }
    ```
 */
class OpenAPISchemasBuilderTests: XCTestCase {

    func testSchemaNameShouldBeTranslatedToOpenAPIDocument() {

        // Arrange.
        let openAPIBuilder = OpenAPIBuilder(
            title: "Title",
            version: "1.0.0",
            description: "Description"
        )
        .add([
            APIObject(object: Vehicle(name: "Ford", age: 21))
        ])

        // Act.
        let openAPIDocument = openAPIBuilder.built()

        // Assert.
        XCTAssertNotNil(openAPIDocument.components?.schemas!["Vehicle"], "Schema name not exists")
    }

    func testSchemaTypeShouldBeTranslatedToOpenAPIDocument() {

        // Arrange.
        let openAPIBuilder = OpenAPIBuilder(
            title: "Title",
            version: "1.0.0",
            description: "Description"
        )
        .add([
            APIObject(object: Vehicle(name: "Ford", age: 21))
        ])

        // Act.
        let openAPIDocument = openAPIBuilder.built()

        // Assert.
        XCTAssertEqual("object", openAPIDocument.components?.schemas!["Vehicle"]?.type)
    }

    func testSchemaStringPropertyShouldBeTranslatedToOpenAPIDocument() {

        // Arrange.
        let openAPIBuilder = OpenAPIBuilder(
            title: "Title",
            version: "1.0.0",
            description: "Description"
        )
        .add([
            APIObject(object: Vehicle(name: "Ford", age: 21))
        ])

        // Act.
        let openAPIDocument = openAPIBuilder.built()

        // Assert.
        XCTAssertNotNil(openAPIDocument.components?.schemas!["Vehicle"]?.properties!["name"], "String property not exists in schema")
        XCTAssertEqual("string", openAPIDocument.components?.schemas!["Vehicle"]?.properties!["name"]?.type)
        XCTAssertEqual("Ford", openAPIDocument.components?.schemas!["Vehicle"]?.properties!["name"]?.example?.description.description)
    }

    func testSchemaIntegerPropertyShouldBeTranslatedToOpenAPIDocument() {

        // Arrange.
        let openAPIBuilder = OpenAPIBuilder(
            title: "Title",
            version: "1.0.0",
            description: "Description"
        )
        .add([
            APIObject(object: Vehicle(name: "Ford", age: 21))
        ])

        // Act.
        let openAPIDocument = openAPIBuilder.built()

        // Assert.
        XCTAssertNotNil(openAPIDocument.components?.schemas!["Vehicle"]?.properties!["age"], "Integer property not exists in schema")
        XCTAssertEqual("int", openAPIDocument.components?.schemas!["Vehicle"]?.properties!["age"]?.type)
        XCTAssertEqual("21", openAPIDocument.components?.schemas!["Vehicle"]?.properties!["age"]?.example?.description)
    }

    func testSchemaRequiredFieldsShouldBeTranslatedToOpenAPIDocument() {

        // Arrange.
        let openAPIBuilder = OpenAPIBuilder(
            title: "Title",
            version: "1.0.0",
            description: "Description"
        )
        .add([
            APIObject(object: Vehicle(name: "Ford", age: 21))
        ])

        // Act.
        let openAPIDocument = openAPIBuilder.built()

        // Assert.
        XCTAssert(openAPIDocument.components?.schemas!["Vehicle"]?.required?.contains("name") == true, "Required property not exists in schema")
    }

    func testSchemaNotRequiredFieldsShouldNotBeTranslatedToOpenAPIDocument() {

        // Arrange.
        let openAPIBuilder = OpenAPIBuilder(
            title: "Title",
            version: "1.0.0",
            description: "Description"
        )
        .add([
            APIObject(object: Vehicle(name: "Ford", age: 21))
        ])

        // Act.
        let openAPIDocument = openAPIBuilder.built()

        // Assert.
        XCTAssert(openAPIDocument.components?.schemas!["Vehicle"]?.required?.contains("age") == false, "Not required property exists in schema")
    }
    
    func testSchemaStructTypeShouldBeTranslatedToOpenAPIDocument() {
        
        // Arrange.
        let openAPIBuilder = OpenAPIBuilder(
            title: "Title",
            version: "1.0.0",
            description: "Description"
            )
            .add([
                APIObject(object: Spaceship(name: "Star Trek", speed: 923211))
                ])
        
        // Act.
        let openAPIDocument = openAPIBuilder.built()
        
        // Assert.
        XCTAssertNotNil(openAPIDocument.components?.schemas!["Spaceship"], "Schema name not exists")
        XCTAssertEqual("string", openAPIDocument.components?.schemas!["Spaceship"]?.properties!["name"]?.type)
        XCTAssertEqual("Star Trek", openAPIDocument.components?.schemas!["Spaceship"]?.properties!["name"]?.example?.description)
        XCTAssertEqual("double", openAPIDocument.components?.schemas!["Spaceship"]?.properties!["speed"]?.type)
        XCTAssertEqual("923211.0", openAPIDocument.components?.schemas!["Spaceship"]?.properties!["speed"]?.example?.description)
    }
    
    func testSchemaNestedTypesShouldBeTranslated() {
        
        // Arrange.
        let openAPIBuilder = OpenAPIBuilder(
            title: "Title",
            version: "1.0.0",
            description: "Description"
            )
            .add([
                APIObject(object: Galaxy(name: "MyGalaxy",
                                         vehicle: Vehicle(name: "MainShip", age: 20),
                                         spaceships: [
                                            Spaceship(name: "Star Trek", speed: 923211),
                                            Spaceship(name: "Other Trek", speed: 293910)],
                                         strings: ["Test", "Two"]))
                ])
        
        // Act.
        let openAPIDocument = openAPIBuilder.built()
        
        // Assert.
        XCTAssertEqual(openAPIDocument.components?.schemas!["Galaxy"]?.properties!["vehicle"]?.type, "vehicle")
        
        let encoder = JSONEncoder()
        XCTAssertNoThrow(try encoder.encode(openAPIDocument))
        
        let data = try? encoder.encode(openAPIDocument)
        
        XCTAssertNotNil(data)
        
        let json = String(data: data ?? Data(), encoding: .utf8)
        
        XCTAssertNotNil(json)
    }

    static var allTests = [
        ("testSchemaNameShouldBeTranslatedToOpenAPIDocument", testSchemaNameShouldBeTranslatedToOpenAPIDocument),
        ("testSchemaTypeShouldBeTranslatedToOpenAPIDocument", testSchemaTypeShouldBeTranslatedToOpenAPIDocument),
        ("testSchemaStringPropertyShouldBeTranslatedToOpenAPIDocument", testSchemaStringPropertyShouldBeTranslatedToOpenAPIDocument),
        ("testSchemaIntegerPropertyShouldBeTranslatedToOpenAPIDocument", testSchemaIntegerPropertyShouldBeTranslatedToOpenAPIDocument),
        ("testSchemaRequiredFieldsShouldBeTranslatedToOpenAPIDocument", testSchemaRequiredFieldsShouldBeTranslatedToOpenAPIDocument),
        ("testSchemaNotRequiredFieldsShouldNotBeTranslatedToOpenAPIDocument", testSchemaNotRequiredFieldsShouldNotBeTranslatedToOpenAPIDocument),
        ("testSchemaStructTypeShouldBeTranslatedToOpenAPIDocument", testSchemaStructTypeShouldBeTranslatedToOpenAPIDocument),
        ("testSchemaNestedTypesShouldBeTranslated",
         testSchemaNestedTypesShouldBeTranslated),
    ]
}

//
//  OpenAPISchemasBuilder.swift
//  Swiftgger
//
//  Created by Marcin Czachurski on 24.03.2018.
//

import Foundation

/// Builder for object information stored in `components/schemas` part of OpenAPI.
class OpenAPISchemasBuilder {

    let objects: [APIObject]
    let jsonEncoder = JSONEncoder()

    init(objects: [APIObject]) {
        self.objects = objects
    }

    func built() -> [String: OpenAPISchema] {

        var schemas: [String: OpenAPISchema] = [:]
        for object in self.objects where object.object != nil {
            add(object: object.object!, toSchemas: &schemas)
        }

        return schemas
    }

    private func add(object: Any, toSchemas schemas: inout [String: OpenAPISchema]) {
        let requestMirror: Mirror = Mirror(reflecting: object)
        let mirrorObjectType = String(describing: requestMirror.subjectType)

        if schemas[mirrorObjectType] == nil {
            let required = self.getRequiredProperties(properties: requestMirror.children)
            let properties = self.getAllProperties(properties: requestMirror.children)
            let requestSchema = OpenAPISchema(type: "object", required: required, properties: properties)
            schemas[mirrorObjectType] = requestSchema
        }
    }

    private func getAllProperties(properties: Mirror.Children) -> [(name: String, type: OpenAPIObjectProperty)] {

        var array:  [(name: String, type: OpenAPIObjectProperty)] = []
        for property in properties {
            let value = unwrap(property.value)
            let someType = type(of: value)
            let typeName = String(describing: someType)
            var example = AnyCodable(value: value)
            
            let childMirror = Mirror(reflecting: value)

            if childMirror.displayStyle != nil {
                var jsonable: Any = toDict(obj: value)

                if value is [Any] {
                    jsonable = toArray(arr: value as! [Any])
                }

                example = AnyCodable(value: jsonable)
            }
            
            let objectType = OpenAPIObjectProperty(type: typeName.lowercased(), example: example)
            
            if let label = property.label {
                array.append((name: label, type: objectType))
            }
        }

        return array
    }
    
    private func toArray(arr: [Any]) -> [Any] {
       return arr.map { toDict(obj: $0) }
    }
    
    private func toDict(obj: Any) -> [String:Any] {
        var dict = [String:Any]()
        let otherSelf = Mirror(reflecting: obj)
        for child in otherSelf.children {
            if let key = child.label {
                dict[key] = String(describing: child.value)
            }
        }
        return dict
    }

    private func getRequiredProperties(properties: Mirror.Children) -> [String] {
        var array: [String] = []

        for property in properties {
            if !isOptional(property.value) {
                array.append(property.label!)
            }
        }

        return array
    }

    private func unwrap<T>(_ any: T) -> Any {
        let mirror = Mirror(reflecting: any)
        guard mirror.displayStyle == .optional, let first = mirror.children.first else {
            return any
        }
        return first.value
    }

    private func isOptional<T>(_ any: T) -> Bool {
        let mirror = Mirror(reflecting: any)
        return mirror.displayStyle == .optional
    }
}

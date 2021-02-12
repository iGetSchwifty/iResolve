import XCTest
@testable import iResolve

final class iResolveTests: XCTestCase {
    func test_register() {
        let iResolveInstance = iResolve()
        let mySimpleObject = SimpleObject()
        try? iResolveInstance.register(obj: mySimpleObject)
        XCTAssertEqual(iResolveInstance.currentTotal, 1)
    }
    
    func test_register_alreadyExists() {
        let iResolveInstance = iResolve()
        let mySimpleObject = SimpleObject()
        try? iResolveInstance.register(obj: mySimpleObject)
        XCTAssertEqual(iResolveInstance.currentTotal, 1)
        do {
            try iResolveInstance.register(obj: SimpleObject())
            XCTFail()
        } catch {
            XCTAssertEqual(iResolveInstance.currentTotal, 1)
        }
    }
    
    func test_unregister() {
        let iResolveInstance = iResolve()
        let mySimpleObject = SimpleObject()
        try? iResolveInstance.register(obj: mySimpleObject)
        XCTAssertEqual(iResolveInstance.currentTotal, 1)
        print(String(describing: SimpleObject.self))
        try? iResolveInstance.unregister(type: SimpleObject.self)
        XCTAssertEqual(iResolveInstance.currentTotal, 0)
    }
    
    func test_unregister_none() {
        let iResolveInstance = iResolve()
        let mySimpleObject = SimpleObject()
        try? iResolveInstance.register(obj: mySimpleObject)
        XCTAssertEqual(iResolveInstance.currentTotal, 1)
        do {
            try iResolveInstance.unregister(type: DoesntExist.self)
            XCTFail()
        } catch {
            XCTAssertEqual(iResolveInstance.currentTotal, 1)
        }
    }
    
    func test_load() {
        let iResolveInstance = iResolve()
        let mySimpleObject = SimpleObject()
        try? iResolveInstance.register(obj: mySimpleObject)
        
        let found = try? iResolveInstance.get(type: SimpleObject.self) as? SimpleObjectProtocol
        XCTAssertEqual(found?.sound, "Foo")
    }
    
    func test_load_doesNotExist() {
        let iResolveInstance = iResolve()
        let mySimpleObject = SimpleObject()
        try? iResolveInstance.register(obj: mySimpleObject)
        
        let found = try? iResolveInstance.get(type: DoesntExist.self) as? SimpleObjectProtocol
        XCTAssertEqual(found?.sound, nil)
    }
    
    func test_registerForTesting() {
        let iResolveInstance = iResolve()
        let mySimpleObject = SimpleObject()
        try? iResolveInstance.register(obj: mySimpleObject)
        
        var found = try? iResolveInstance.get(type: SimpleObject.self) as? SimpleObjectProtocol
        XCTAssertEqual(found?.sound, "Foo")
        try? iResolveInstance.registerForTesting(obj: MockSimpleObject())
        found = try? iResolveInstance.get(type: SimpleObject.self) as? SimpleObjectProtocol
        XCTAssertEqual(found?.sound, "Bar")
    }
}

class DoesntExist: NSObject, iResolveInjectable  {}

protocol SimpleObjectProtocol: class {
    var sound: String { get }
}

class SimpleObject: NSObject, iResolveInjectable, SimpleObjectProtocol {
    var sound: String {
        return "Foo"
    }
}

class MockSimpleObject: NSObject, iResolveInjectable, SimpleObjectProtocol {
    func serviceName() -> String {
        return iResolve.serviceName(fromType: SimpleObject.self)
    }
    
    var sound: String {
        return "Bar"
    }
}

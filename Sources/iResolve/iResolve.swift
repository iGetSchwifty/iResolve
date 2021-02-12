import Foundation

public protocol iResolveInjectable: class {
    func serviceName() -> String
}

extension iResolveInjectable {
    func serviceName() -> String {
        return String(describing: type(of: self))
    }
}

///
/// iResolve
///
public class iResolve {
    private var _objects = Set<AnyHashable>()
    
    public var currentTotal: Int {
        return _objects.count
    }
    
    public func register<T>(obj: T) throws where T: iResolveInjectable, T: Hashable {
        for item in _objects {
            if (item as? iResolveInjectable)?.serviceName() == obj.serviceName() {
                throw NSError(domain: "Object is already registered", code: 42, userInfo: nil)
            }
        }
        
        if _objects.insert(obj).inserted == false {
            throw NSError(domain: "Object is already registered", code: 42, userInfo: nil)
        }
    }
    
    public func unregister<T>(type: T) throws {
        let serviceName = iResolve.serviceName(fromType: T.self)
        if let indexOf = _objects.firstIndex(where: { ($0 as? iResolveInjectable)?.serviceName() == serviceName }) {
            _objects.remove(at: indexOf)
        } else {
            throw NSError(domain: "Uh.. Awkward couldnt remove the element because it wasnt there in the first place", code: 420, userInfo: nil)
        }
    }
    
    public func get<T>(type: T) throws -> AnyHashable {
        let serviceName = iResolve.serviceName(fromType: T.self)
        if let found = _objects.first(where: { ($0 as? iResolveInjectable)?.serviceName() == serviceName }) {
            return found
        }
        throw NSError(domain: "Could not find registered object for type", code: 24, userInfo: nil)
    }
    
    public func registerForTesting<T>(obj: T) throws where T: iResolveInjectable, T: Hashable {
        guard NSClassFromString("XCTestCase") != nil else {
            throw NSError(domain: "This method is only used for testing...", code: 1, userInfo: nil)
        }
        
        if let indexOf = _objects.firstIndex(where: { ($0 as? iResolveInjectable)?.serviceName() == obj.serviceName() }) {
            _objects.remove(at: indexOf)
            if _objects.insert(obj).inserted == false {
                throw NSError(domain: "Something went wrong when inserting the object for testing", code: 4, userInfo: nil)
            }
        } else {
            throw NSError(domain: "Uh.. Awkward couldnt find the element your testing for", code: 420, userInfo: nil)
        }
    }
    
    static func serviceName<T>(fromType: T) -> String {
        return String(describing: T.self).replacingOccurrences(of: ".Type", with: "")
    }
}

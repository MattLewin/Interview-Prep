import Foundation

//: # General Helper Methods

public func intAddress(of obj: AnyObject) -> Int {
    let basePtr = UnsafeRawPointer(bitPattern: 1)!
    let ptr = Unmanaged.passUnretained(obj).toOpaque()
    return basePtr.distance(to: ptr)
}

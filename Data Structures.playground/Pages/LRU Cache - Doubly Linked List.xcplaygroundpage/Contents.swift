import Foundation

let cache = LRUCache<Int, String>(capacity: 2)
cache.getValue(for: 1)
cache.setValue("one", for: 1)
cache.setValue("two", for: 2)
cache.setValue("forty-two", for: 42)
cache.getValue(for: 1)
cache.getValue(for: 42)

let cap = 100

var start: Date
var end: Date
var delta: TimeInterval
start = Date()
print("beginning cache allocation at \(start)")
let bigCache = LRUCache<Int, String>(capacity: cap)
end = Date()
delta = end.timeIntervalSince(start)
print("it took \(delta) seconds to allocate the cache")

start = Date()
print("beginning value insertion at \(start)")
for index in 0..<(cap*2) {
    bigCache.setValue(String(format: "%00000d", index), for: index)
}
end = Date()
delta = end.timeIntervalSince(start)
print("it took \(delta) seconds to insert \(cap*2) values")


//: ---
//: [Next](@next)

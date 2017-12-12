//: [Previous](@previous)

import Foundation

class MinHeap {
    private(set) var heap: [Int]
    private(set) var elementCount = 0

    init(size: Int = 3) {
        heap = Array<Int>(repeatElement(Int.max, count: size))
    }

    private func resizeHeap() {
        var newHeap = Array<Int>(repeatElement(Int.max, count: (2 * heap.count)))
        newHeap[0..<heap.count] = heap[...]
        heap = newHeap
    }

    private func swap(_ index1: Int, _ index2: Int) {
        let temp = heap[index1]
        heap[index1] = heap[index2]
        heap[index2] = temp
    }

    private func bubbleUp(_ index: Int) {
        var currentIndex = index
        var parentIndex = currentIndex / 2

        while parentIndex > 0 &&
            (heap[parentIndex] > heap[currentIndex]) {
                swap(parentIndex, currentIndex)
                currentIndex = parentIndex
                parentIndex = currentIndex / 2
        }
    }

    private func bubbleDown(_ index: Int) {
        var currentIndex = index
        var leftIndex = currentIndex * 2
        var rightIndex = leftIndex + 1

        while currentIndex <= elementCount {
            if leftIndex <= elementCount &&
                (heap[currentIndex] > heap[leftIndex]) {
                swap(currentIndex, leftIndex)
                currentIndex = leftIndex
            }
            else if rightIndex < elementCount &&
                (heap[currentIndex] > heap[rightIndex]) {
                swap(currentIndex, rightIndex)
                currentIndex = rightIndex
            }
            else {
                break
            }

            leftIndex = currentIndex * 2
            rightIndex = leftIndex + 1
        }
    }

    public func insert(_ element: Int) {
        elementCount += 1
        if elementCount >= heap.count {
            resizeHeap()
        }

        heap[elementCount] = element
        bubbleUp(elementCount)
    }

    public func removeMin() -> Int {
        let retVal = heap[1]
        heap[1] = heap[elementCount]
        heap[elementCount] = Int.max
        elementCount -= 1
        bubbleDown(1)
        return retVal
    }
}

let minHeap = MinHeap()
minHeap.insert(4)
minHeap.insert(50)
minHeap.insert(7)
minHeap.insert(55)
minHeap.insert(90)
minHeap.insert(87)

minHeap.insert(2)

minHeap.removeMin()
minHeap

//: [Next](@next)

import Utils
import SwiftUI

extension ShuffleDeck {
    internal func performShuffling(_ direction: ShuffleDeckDirection) {
        self.autoShuffling = true
        self.direction = direction
        performSpreadingOut()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
            self.performRestoring()
        }
    }

    internal func performSpreadingOut() {
        let maxSwipeDistance = size.width * 0.25
        withAnimation(animation.timing(duration: 0.1)) {
            switch direction {
            case .left:
                xPosition = maxSwipeDistance
            case .right:
                xPosition = -maxSwipeDistance
            }
        }
    }

    internal func performRestoring() {
        let midX = size.width * 0.5
        let maxSwipeDistance = size.width * 0.25
        if xPosition > 0 {
            let newIndex: Data.Index?
            switch style {
            case .infiniteShuffle:
                newIndex = data.previousIndex(forLoop: index, offset: 1)
            case .finiteShuffle:
                newIndex = data.previousIndex(forUnloop: index, offset: 1)
            }
            if xPosition >= maxSwipeDistance, let nextIndex = newIndex {
                withAnimation(animation.timing(duration: 0.1)) {
                    xPosition = midX + midX * 0.2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                    withAnimation(animation.timing(duration: 0.03)) {
                        isShiftedRight = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
                    let context = ShuffleDeckContext(
                        index: data.distance(from: data.startIndex, to: nextIndex),
                        previousIndex: data.distance(from: data.startIndex, to: index),
                        direction: .left
                    )
                    notifyListener(context: context)
                    withAnimation(animation.timing(duration: 0.1)) {
                        isLockedLeft = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.23) {
                    index = nextIndex
                    isShiftedRight = false
                    isLockedLeft = false
                    xPosition = 0
                    autoShuffling = false
                }
            } else {
                withAnimation(animation.timing(duration: 0.15)) {
                    xPosition = 0
                }
            }
        } else if xPosition < 0 {
            let newIndex: Data.Index?
            switch style {
            case .infiniteShuffle:
                newIndex = data.nextIndex(forLoop: index, offset: 1)
            case .finiteShuffle:
                newIndex = data.nextIndex(forUnloop: index, offset: 1)
            }
            if xPosition <= -maxSwipeDistance, let nextIndex = newIndex {
                withAnimation(animation.timing(duration: 0.1)) {
                    xPosition = -midX - midX * 0.2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                    withAnimation(animation.timing(duration: 0.03)) {
                        isShiftedLeft = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
                    let context = ShuffleDeckContext(
                        index: data.distance(from: data.startIndex, to: nextIndex),
                        previousIndex: data.distance(from: data.startIndex, to: index),
                        direction: .right
                    )
                    notifyListener(context: context)
                    withAnimation(animation.timing(duration: 0.1)) {
                        isLockedRight = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.23) {
                    index = nextIndex
                    isShiftedLeft = false
                    isLockedRight = false
                    xPosition = 0
                    autoShuffling = false
                }
            } else {
                withAnimation(animation.timing(duration: 0.15)) {
                    xPosition = 0
                }
            }
        }
    }

    private func notifyListener(context: ShuffleDeckContext) {
        shuffleDeckContext?(context)
    }

    internal var translation: CGFloat {
        return size.width > 0 ? min(abs(xPosition) / (size.width * 0.5), 1) : 0
    }

    internal var factor: CGFloat {
        return size.width > 0 ? xPosition / (size.width * 0.5) : 0
    }
}

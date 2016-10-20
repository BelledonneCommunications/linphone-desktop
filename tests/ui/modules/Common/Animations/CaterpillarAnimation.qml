import QtQuick 2.7

import Common.Styles 1.0

// ===================================================================

Row {
  id: container

  property color sphereColor: CaterpillarAnimationStyle.sphere.color
  property int animationDuration: CaterpillarAnimationStyle.animation.duration
  property int nSpheres: CaterpillarAnimationStyle.nSpheres
  property int sphereSize: CaterpillarAnimationStyle.sphere.size
  property int animationSpace: CaterpillarAnimationStyle.animation.space

  spacing: 6

  Repeater {
    id: repeater

    model: nSpheres

    Rectangle {
      id: sphere

      property bool forceRunning: false
      property int previousY: 0

      function startAnimation () {
        if (!animator.running) {
          animator.running = true
        } else {
          forceRunning = true
        }
      }

      color: sphereColor
      height: width
      radius: width / 2
      width: container.sphereSize

      // y can be: `0`, `animationSpace` or `animationSpace / 2`
      onYChanged: {
        // No call executed by last sphere.
        if (index === nSpheres - 1) {
          return
        }

        if (y === (animationSpace / 2) && previousY === 0) {
          repeater.itemAt(index + 1).startAnimation()
        }

        previousY = y
      }

      Component.onCompleted: {
        // Only start first sphere.
        if (index === 0) {
          animator.running = true
        }
      }

      YAnimator on y {
        id: animator

        duration: container.animationDuration
        from: 0
        running: false
        to: animationSpace / 2

        onRunningChanged: {
          if (running) {
            return
          }

          var mid = animationSpace / 2
          if (from === animationSpace && to === mid) {
            from = mid
            to = 0
          } else if (from === mid && to === 0) {
            from = 0
            to = mid

            if (index !== 0 && !forceRunning) {
              return
            }
          } else if (from === 0 && to === mid) {
            from = mid
            to = animationSpace
          } else {
            from = animationSpace
            to = mid
          }

          forceRunning = false
          animator.running = true
        }
      }
    }
  }
}

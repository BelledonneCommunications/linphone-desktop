import QtQuick 2.7

Row {
  id: container

  property int duration: 200
  property int nSpheres: 3
  property color sphereColor: '#8F8F8F'
  property int sphereSize: 10
  property int sphereSpaceSize: 10

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

      onYChanged: {
        // No call executed by last sphere.
        if (index === nSpheres - 1) {
          return
        }

        if (y === (sphereSpaceSize / 2) && previousY === 0) {
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
        duration: container.duration
        from: 0
        id: animator
        running: false
        to: sphereSpaceSize / 2

        onRunningChanged: {
          if (running) {
            return
          }

          var mid = sphereSpaceSize / 2
          if (from === sphereSpaceSize && to === mid) {
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
            to = sphereSpaceSize
          } else {
            from = sphereSpaceSize
            to = mid
          }

          forceRunning = false
          animator.running = true
        }
      }
    }
  }
}

import QtQuick 2.7

Row {
  id: container

  property int sphereSize: 10
  property int nSpheres: 3

  spacing: 6

  Repeater {
    model: nSpheres

    Rectangle {
      id: ymovingBox

      color: '#8F8F8F'
      height: container.sphereSize
      radius: container.sphereSize / 2
      width: container.sphereSize

      onYChanged: console.log('y changed', y)

      YAnimator on y {
        id: animator

        duration: 500
        from: 10
        running: true
        to: 0

        onRunningChanged: {
          if (!running) {
            if (to === 0) {
              to = 10
              from = 0
            } else {
              to = 0
              from = 10
            }

            animator.running = true
          }
        }
      }
    }
  }
}

import QtQuick

Item {
    id: root
    property real size: 150
    property color borderColor
    property color innerColor
    width: size
    height: size

	onBorderColorChanged: c.requestPaint()

	function requestPaint(animated) {
		c.animated = animated
		if (animated) animationTimer.restart()
		else {
			animationTimer.stop()
			c.requestPaint()
		}
	}

    Canvas {
        id: c
		property bool animated: false
        property real offset: 0
        anchors.fill: parent
        antialiasing: true
        onOffsetChanged: requestPaint()
		Timer {
			id: animationTimer
			interval: 200
			repeat: true
			onTriggered: c.offset = (c.offset + 1)%360
		}

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset()
			ctx.setLineDash([3, 2]);
			ctx.lineWidth = 2;

			ctx.lineDashOffset = offset;

            var x = root.width / 2;
            var y = root.height / 2;

            var radius = root.size / 2
            var startAngle = (Math.PI / 180) * 270;
            var fullAngle = (Math.PI / 180) * (270 + 360);

            ctx.strokeStyle = root.borderColor;
            ctx.fillStyle = root.innerColor;
            ctx.beginPath();
			ctx.arc(x, y, radius - 1, 0, 2 * Math.PI);
			ctx.fill();
			if (animated) {
				ctx.stroke();
			}
		}
	}
}

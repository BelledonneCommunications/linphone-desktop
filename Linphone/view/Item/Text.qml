import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
import Linphone

Text {
	property double scaleLettersFactor: 1.
	font.family: DefaultStyle.defaultFont
	font.pointSize: DefaultStyle.defaultFontPointSize
	transform: Scale { yScale: scaleLettersFactor}
}

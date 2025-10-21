pragma Singleton
import QtQuick
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

QtObject {

	// Title/H4 - Bloc title
	property font h4: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(16),
        weight: Math.min(Utils.getSizeWithScreenRatio(800), 1000)
	})

	// Title/H3M -  Bloc title
	property font h3m: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(16),
        weight: Math.min(Utils.getSizeWithScreenRatio(700), 1000)
	})
	
	// Title/H3 -  Bloc title
	property font h3: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(22),
        weight: Math.min(Utils.getSizeWithScreenRatio(800), 1000)
	})

	// Title/H2M -  Large bloc title
	property font h2m: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(20),
        weight: Math.min(Utils.getSizeWithScreenRatio(800), 1000)
	})

	// Title/H2 -  Large bloc title
	property font h2: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(29),
        weight: Math.min(Utils.getSizeWithScreenRatio(800), 1000)
	})

	// Title/H1 -  Large bloc title
	property font h1: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(36),
        weight: Math.min(Utils.getSizeWithScreenRatio(800), 1000)
	})

	// Text/P4 - Xsmall paragraph text
    property font p4: Qt.font( {
        family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(10),
        weight: Math.min(Utils.getSizeWithScreenRatio(300), 1000)
    })

    // Text/P3 - Reduced paragraph text
    property font p3: Qt.font( {
        family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(12),
        weight: Math.min(Utils.getSizeWithScreenRatio(300), 1000)
    })
		
	// Text/P2 - Bold, reduced paragraph text
	property font p2: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(13),
        weight: Math.min(Utils.getSizeWithScreenRatio(700), 1000)
	})

	// Text/P2l - Large Bold, reduced paragraph text
	property font p2l: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(14),
        weight: Math.min(Utils.getSizeWithScreenRatio(700), 1000)
	})
		
	// Text/P1 - Paragraph text
	property font p1: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(14),
        weight: Math.min(Utils.getSizeWithScreenRatio(400), 1000)
	})
	
	// Text/P1s - Paragraph text
	property font p1s: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(13),
        weight: Math.min(Utils.getSizeWithScreenRatio(400), 1000)
	})
	
	// Text/P1 - Paragraph text
	property font p1b: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(15),
        weight: Math.min(Utils.getSizeWithScreenRatio(400), 1000)
	})
	
	// Button/B1 - Big Button
	property font b1: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(18),
        weight: Math.min(Utils.getSizeWithScreenRatio(600), 1000)
	})

	// Button/B2 - Medium Button
	property font b2: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(15),
        weight: Math.min(Utils.getSizeWithScreenRatio(600), 1000)
	})
	
	// Button/B3 - Small Button
	property font b3: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(13),
        weight: Math.min(Utils.getSizeWithScreenRatio(600), 1000)
	})

	// FileView/F1 - File View name text
	property font f1: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(11),
        weight: Math.min(Utils.getSizeWithScreenRatio(700), 1000)
	})

	// FileView/F1light - File View size text
	property font f1l: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(10),
        weight: Math.min(Utils.getSizeWithScreenRatio(500), 1000)
	})

	// FileView/F1light - Duration text
	property font d1: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(8),
        weight: Math.min(Utils.getSizeWithScreenRatio(600), 1000)
	})
}

pragma Singleton
import QtQuick
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

QtObject {

	// Title/H4 - Bloc title
	property font h4: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(16),
        weight: Font.ExtraBold
	})

	// Title/H3M -  Bloc title
	property font h3m: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(16),
        weight: Font.Bold
	})
	
	// Title/H3 -  Bloc title
	property font h3: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(22),
        weight: Font.ExtraBold
	})

	// Title/H2M -  Large bloc title
	property font h2m: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(20),
        weight: Font.ExtraBold
	})

	// Title/H2 -  Large bloc title
	property font h2: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(29),
        weight: Font.ExtraBold
	})

	// Title/H1 -  Large bloc title
	property font h1: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(36),
        weight: Font.ExtraBold
	})

	// Text/P4 - Xsmall paragraph text
    property font p4: Qt.font( {
        family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(10),
        weight: Font.Light
    })

    // Text/P3 - Reduced paragraph text
    property font p3: Qt.font( {
        family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(12),
        weight: Font.Light
    })
		
	// Text/P2 - Bold, reduced paragraph text
	property font p2: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(13),
        weight: Font.Bold
	})

	// Text/P2l - Large Bold, reduced paragraph text
	property font p2l: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(14),
        weight: Font.Bold
	})
		
	// Text/P1 - Paragraph text
	property font p1: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(14),
        weight: Font.Normal
	})
	
	// Text/P1s - Paragraph text
	property font p1s: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(13),
        weight: Font.Normal
	})
	
	// Text/P1 - Paragraph text
	property font p1b: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(15),
        weight: Font.Normal
	})
	
	// Button/B1 - Big Button
	property font b1: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(18),
        weight: Font.DemiBold
	})

	// Button/B2 - Medium Button
	property font b2: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(15),
        weight: Font.DemiBold
	})
	
	// Button/B3 - Small Button
	property font b3: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(13),
        weight: Font.DemiBold
	})

	// FileView/F1 - File View name text
	property font f1: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(11),
        weight: Font.Bold
	})

	// FileView/F1light - File View size text
	property font f1l: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(10),
        weight: Font.Medium
	})

	// FileView/F1light - Duration text
	property font d1: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Utils.getSizeWithScreenRatio(8),
        weight: Font.DemiBold
	})
}

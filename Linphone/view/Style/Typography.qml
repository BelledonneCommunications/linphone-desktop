pragma Singleton
import QtQuick

QtObject {

	// Title/H4 - Bloc title
	property font h4: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Math.round(16 * DefaultStyle.dp),
        weight: Math.min(Math.round(800 * DefaultStyle.dp), 1000)
	})
	
	// Title/H3 -  Bloc title
	property font h3: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Math.round(22 * DefaultStyle.dp),
        weight: Math.min(Math.round(800 * DefaultStyle.dp), 1000)
	})
	
	// Title/H2 -  Large bloc title
	property font h2: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Math.round(29 * DefaultStyle.dp),
        weight: Math.min(Math.round(800 * DefaultStyle.dp), 1000)
	})

	// Title/H1 -  Large bloc title
	property font h1: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Math.round(36 * DefaultStyle.dp),
        weight: Math.min(Math.round(800 * DefaultStyle.dp), 1000)
	})

    // Text/P3 - Reduced paragraph text
    property font p3: Qt.font( {
        family: DefaultStyle.defaultFont,
        pixelSize: Math.round(12 * DefaultStyle.dp),
        weight: Math.min(Math.round(300 * DefaultStyle.dp), 1000)
    })
		
	// Text/P2 - Bold, reduced paragraph text
	property font p2: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Math.round(13 * DefaultStyle.dp),
        weight: Math.min(Math.round(700 * DefaultStyle.dp), 1000)
	})
	
	// Text/P2 - Large Bold, reduced paragraph text
	property font p2l: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Math.round(14 * DefaultStyle.dp),
        weight: Math.min(Math.round(700 * DefaultStyle.dp), 1000)
	})
		
	// Text/P1 - Paragraph text
	property font p1: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Math.round(14 * DefaultStyle.dp),
        weight: Math.min(Math.round(400 * DefaultStyle.dp), 1000)
	})
	
	// Text/P1 - Paragraph text
	property font p1s: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Math.round(13 * DefaultStyle.dp),
        weight: Math.min(Math.round(400 * DefaultStyle.dp), 1000)
	})
	
	// Button/B1 - Big Button
	property font b1: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Math.round(18 * DefaultStyle.dp),
        weight: Math.min(Math.round(600 * DefaultStyle.dp), 1000)
	})

	// Button/B2 - Medium Button
	property font b2: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Math.round(15 * DefaultStyle.dp),
        weight: Math.min(Math.round(600 * DefaultStyle.dp), 1000)
	})
	
	// Button/B3 - Small Button
	property font b3: Qt.font( {
		family: DefaultStyle.defaultFont,
        pixelSize: Math.round(13 * DefaultStyle.dp),
        weight: Math.min(Math.round(600 * DefaultStyle.dp), 1000)
	})

}

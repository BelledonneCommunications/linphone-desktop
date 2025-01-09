pragma Singleton
import QtQuick

QtObject {

	// Title/H4 - Bloc title
	property font h4: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 16 * DefaultStyle.dp,
		weight: 800 * DefaultStyle.dp
	})
	
	// Title/H3 -  Bloc title
	property font h3: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 22 * DefaultStyle.dp,
		weight: 800 * DefaultStyle.dp
	})
	
	// Title/H2 -  Large bloc title
	property font h2: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 29 * DefaultStyle.dp,
		weight: 800 * DefaultStyle.dp
	})

	// Title/H1 -  Large bloc title
	property font h1: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 36 * DefaultStyle.dp,
		weight: 800 * DefaultStyle.dp
	})
		
	// Text/P2 - Bold, reduced paragraph text
	property font p2: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 13 * DefaultStyle.dp,
		weight: 700 * DefaultStyle.dp
	})
	
	// Text/P2 - Large Bold, reduced paragraph text
	property font p2l: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 14 * DefaultStyle.dp,
		weight: 700 * DefaultStyle.dp
	})
		
	// Text/P1 - Paragraph text
	property font p1: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 14 * DefaultStyle.dp,
		weight: 400 * DefaultStyle.dp
	})
	
	// Text/P1 - Paragraph text
	property font p1s: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 13 * DefaultStyle.dp,
		weight: 400 * DefaultStyle.dp
	})
	
	// Button/B1 - Big Button
	property font b1: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 18 * DefaultStyle.dp,
		weight: 600 * DefaultStyle.dp
	})

	// Button/B2 - Medium Button
	property font b2: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 15 * DefaultStyle.dp,
		weight: 600 * DefaultStyle.dp
	})
	
	// Button/B3 - Small Button
	property font b3: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 13 * DefaultStyle.dp,
		weight: 600 * DefaultStyle.dp
	})

}

pragma Singleton
import QtQuick

QtObject {

	// Title/H4 - Bloc title
	property font h4: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 16 * DefaultStyle.dp,
		weight: 800 * DefaultStyle.dp
	})
	
	// Title/H3M -  Bloc title medium
	property font h3m: Qt.font( {
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
		
	// Text/P2 - Bold, reduced paratraph text
	property font p2: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 13 * DefaultStyle.dp,
		weight: 700 * DefaultStyle.dp
	})
	
	// Text/P2 - Large Bold, reduced paratraph text
	property font p2l: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 14 * DefaultStyle.dp,
		weight: 700 * DefaultStyle.dp
	})
		
	// Text/P1 - Paratraph text
	property font p1: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 14 * DefaultStyle.dp,
		weight: 400 * DefaultStyle.dp
	})
	
	// Text/P1 - Paratraph text
	property font p1s: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 13 * DefaultStyle.dp,
		weight: 400 * DefaultStyle.dp
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

pragma Singleton
import QtQuick

QtObject {

	// Title/H4 - Bloc title
	property font h4: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 16 * DefaultStyle.dp,
		weight: 800 * DefaultStyle.dp
	})
	
	// Title/H3M -  Bloc title
	property font h3m: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 16 * DefaultStyle.dp,
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
		
	// Text/P1 - Paratraph text
	property font p1: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 14 * DefaultStyle.dp,
		weight: 400 * DefaultStyle.dp
	})
	
	// Bouton/B2 - Medium Bouton
	property font b2: Qt.font( {
		family: DefaultStyle.defaultFont,
		pixelSize: 15 * DefaultStyle.dp,
		weight: 600 * DefaultStyle.dp
	})
	
}

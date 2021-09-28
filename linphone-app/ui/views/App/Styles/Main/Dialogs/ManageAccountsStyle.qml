pragma Singleton
import QtQml 2.2

// =============================================================================

QtObject {
	property int height: 383
	property int heightWithoutPresence: 314
	property int width: 450
	
	property QtObject accountSelector: QtObject {
		property int height: 176
	}
}

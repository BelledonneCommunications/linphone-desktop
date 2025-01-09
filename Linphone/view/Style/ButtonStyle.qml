pragma Singleton
import QtQuick
import Linphone
import QtQuick.Effects

QtObject {

// Orange
	property QtObject main: QtObject {
		property QtObject color: QtObject {
			property color normal: DefaultStyle.main1_500_main
			property color hovered: DefaultStyle.main1_600
			property color pressed: DefaultStyle.main1_700
		}
		property QtObject text: QtObject {
			property color normal: DefaultStyle.grey_0
			property color pressed: DefaultStyle.grey_0
		}
	}

// White with orange border
	property QtObject secondary: QtObject {
		property QtObject color: QtObject {
			property color normal: DefaultStyle.grey_0
			property color hovered: DefaultStyle.main1_100
			property color pressed: DefaultStyle.main1_500_main
		}
		property color borderColor: DefaultStyle.main1_500_main
		property QtObject text: QtObject {
			property color normal: DefaultStyle.main1_500_main
			property color pressed: DefaultStyle.grey_0
		}
		property QtObject image: QtObject {
			property color normal: DefaultStyle.main1_500_main
			property color pressed: DefaultStyle.grey_0
		}
	}

// Light orange
	property QtObject tertiary: QtObject {
		property QtObject color: QtObject {
			property color normal: DefaultStyle.main1_100
			property color hovered: DefaultStyle.main1_200
			property color pressed: DefaultStyle.main1_300
		}
		property QtObject text: QtObject {
			property color normal: DefaultStyle.main1_500_main
			property color pressed: DefaultStyle.main1_500_main
		}
		property QtObject image: QtObject {
			property color normal: DefaultStyle.main1_500_main
			property color pressed: DefaultStyle.main1_500_main
		}
	}

// Blue-grey
	property QtObject grey: QtObject {
		property QtObject color: QtObject {
			property color normal: DefaultStyle.main2_200
			property color hovered: DefaultStyle.main2_300
			property color pressed: DefaultStyle.main2_400
		}
		property QtObject text: QtObject {
			property color normal: DefaultStyle.main2_500main
			property color pressed: DefaultStyle.main2_700
		}
		property QtObject image: QtObject {
			property color normal: DefaultStyle.main2_500main
			property color pressed: DefaultStyle.main2_700
		}
	}

// Red phone
	property QtObject phoneRed: QtObject {
		property var iconSource: AppIcons.endCall
		property QtObject color: QtObject {
			property color normal: DefaultStyle.danger_500main
			property color hovered: DefaultStyle.danger_700
			property color pressed: DefaultStyle.danger_900
		}
		property QtObject text: QtObject {
			property color normal: DefaultStyle.grey_0
			property color pressed: DefaultStyle.grey_0
		}
		property QtObject image: QtObject {
			property color normal: DefaultStyle.grey_0
			property color pressed: DefaultStyle.grey_0
		}
	}

// Green phone
	property QtObject phoneGreen: QtObject {
		property var iconSource: AppIcons.phone
		property QtObject color: QtObject {
			property color normal: DefaultStyle.success_500main
			property color hovered: DefaultStyle.success_700
			property color pressed: DefaultStyle.success_900
		}
		property QtObject text: QtObject {
			property color normal: DefaultStyle.grey_0
			property color pressed: DefaultStyle.grey_0
		}
		property QtObject image: QtObject {
			property color normal: DefaultStyle.grey_0
			property color pressed: DefaultStyle.grey_0
		}
	}

// Checkable
	property QtObject checkable: QtObject {
		property QtObject color: QtObject {
			property color normal: DefaultStyle.grey_500
			property color hovered: DefaultStyle.grey_600
			property color pressed: DefaultStyle.main2_400
		}

		property QtObject text: QtObject {
			property color normal: DefaultStyle.grey_0
			property color pressed: DefaultStyle.grey_0
		}

		property QtObject image: QtObject {
			property color normal: DefaultStyle.grey_0
			property color pressed: DefaultStyle.grey_0
		}
	}

// No background
	property QtObject noBackground: QtObject {
		property QtObject color: QtObject {
			property color normal: "transparent"
			property color hovered: "transparent"
			property color pressed: "transparent"
		}
		property QtObject text: QtObject {
			property color normal: DefaultStyle.main2_600
			property color hovered: DefaultStyle.main2_700
			property color pressed: DefaultStyle.main2_800
		}
		property QtObject image: QtObject {
			property color normal: DefaultStyle.main2_600
			property color hovered: DefaultStyle.main2_700
			property color pressed: DefaultStyle.main2_800
		}
	}

// No background red
	property QtObject noBackgroundRed: QtObject {
		property QtObject color: QtObject {
			property color normal: "transparent"
			property color hovered: "transparent"
			property color pressed: "transparent"
		}
		property QtObject text: QtObject {
			property color normal: DefaultStyle.danger_500main
			property color hovered: DefaultStyle.danger_700
			property color pressed: DefaultStyle.danger_900
		}
		property QtObject image: QtObject {
			property color normal: DefaultStyle.danger_500main
			property color hovered: DefaultStyle.danger_700
			property color pressed: DefaultStyle.danger_900
		}
	}

// No background orange
	property QtObject noBackgroundOrange: QtObject {
		property QtObject color: QtObject {
			property color normal: "transparent"
			property color hovered: "transparent"
			property color pressed: "transparent"
		}
		property QtObject text: QtObject {
			property color normal: DefaultStyle.main1_500_main
			property color hovered: DefaultStyle.main1_600
			property color pressed: DefaultStyle.main1_700
		}
		property QtObject image: QtObject {
			property color normal: DefaultStyle.main1_500_main
			property color hovered: DefaultStyle.main1_600
			property color pressed: DefaultStyle.main1_700
		}
	}

// Icon + label button
	property QtObject hoveredBackground: QtObject {
		property QtObject color: QtObject {
			property color normal: "transparent"
			property color hovered: DefaultStyle.main2_100
			property color pressed: DefaultStyle.main2_100
		}
		property QtObject text: QtObject {
			property color normal: DefaultStyle.main2_500main
			property color hovered: DefaultStyle.main2_500main
			property color pressed: DefaultStyle.main2_500main
		}
		property QtObject image: QtObject {
			property color normal: DefaultStyle.main2_500main
			property color hovered: DefaultStyle.main2_500main
			property color pressed: DefaultStyle.main2_500main
		}
	}

	property QtObject hoveredBackgroundRed: QtObject {
		property QtObject color: QtObject {
			property color normal: "transparent"
			property color hovered: DefaultStyle.main2_100
			property color pressed: DefaultStyle.main2_100
		}
		property QtObject text: QtObject {
			property color normal: DefaultStyle.danger_500main
			property color hovered: DefaultStyle.danger_700
			property color pressed: DefaultStyle.danger_900
		}
		property QtObject image: QtObject {
			property color normal: DefaultStyle.danger_500main
			property color hovered: DefaultStyle.danger_700
			property color pressed: DefaultStyle.danger_900
		}
	}

// Numpad
	property QtObject numericPad: QtObject {
		property QtObject color: QtObject {
			property color normal: DefaultStyle.grey_0
			property color hovered: DefaultStyle.grey_200
			property color pressed: DefaultStyle.grey_300
		}
		property QtObject text: QtObject {
			property color normal: DefaultStyle.main2_600
			property color pressed: DefaultStyle.main2_700
		}
	}

// Green toast
	property QtObject toast: QtObject {
		property QtObject color: QtObject {
			property color normal: DefaultStyle.grey_0
			property color hovered: DefaultStyle.grey_0
			property color pressed: DefaultStyle.grey_0
		}
		property color borderColor: DefaultStyle.success_500main
		property QtObject text: QtObject {
			property color normal: DefaultStyle.success_500main
			property color pressed: DefaultStyle.success_700
		}
	}

// Security blue toast
	property QtObject securityToast: QtObject {
		property QtObject color: QtObject {
			property color normal: DefaultStyle.grey_0
			property color hovered: DefaultStyle.grey_0
			property color pressed: DefaultStyle.grey_0
		}
		property color borderColor: DefaultStyle.info_500_main
		property QtObject text: QtObject {
			property color normal: DefaultStyle.info_500_main
			property color pressed: DefaultStyle.info_500_main
		}
	}

// Security red toast
	property QtObject securityToastError: QtObject {
		property QtObject color: QtObject {
			property color normal: DefaultStyle.grey_0
			property color hovered: DefaultStyle.grey_0
			property color pressed: DefaultStyle.grey_0
		}
		property color borderColor: DefaultStyle.danger_500main
		property QtObject text: QtObject {
			property color normal: DefaultStyle.danger_500main
			property color pressed: DefaultStyle.danger_500main
		}
	}
}

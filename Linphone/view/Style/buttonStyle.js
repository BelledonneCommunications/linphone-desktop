.pragma library
.import QtQuick as QtQuick
.import Linphone as Linphone


// Orange
	var main = {
		color: {
			normal: Linphone.DefaultStyle.main1_500_main,
			hovered: Linphone.DefaultStyle.main1_600,
			pressed: Linphone.DefaultStyle.main1_700
		},
		text: {
			normal: Linphone.DefaultStyle.grey_0,
			pressed: Linphone.DefaultStyle.grey_0
		},
		image: {
			normal: Linphone.DefaultStyle.grey_0,
			pressed: Linphone.DefaultStyle.grey_0
		}
	}

// White with orange border
	var secondary = {
		color: {
			normal: Linphone.DefaultStyle.grey_0,
			hovered: Linphone.DefaultStyle.main1_100,
			pressed: Linphone.DefaultStyle.main1_500_main
		},
		borderColor: Linphone.DefaultStyle.main1_500_main,
		text: {
			normal: Linphone.DefaultStyle.main1_500_main,
			pressed: Linphone.DefaultStyle.grey_0
		},
		image: {
			normal: Linphone.DefaultStyle.main1_500_main,
			pressed: Linphone.DefaultStyle.grey_0
		}
	}

// Light orange
	var tertiary = {
		color: {
			normal: Linphone.DefaultStyle.main1_100,
			hovered: Linphone.DefaultStyle.main1_200,
			pressed: Linphone.DefaultStyle.main1_300
		},
		text: {
			normal: Linphone.DefaultStyle.main1_500_main,
			pressed: Linphone.DefaultStyle.main1_500_main
		},
		image: {
			normal: Linphone.DefaultStyle.main1_500_main,
			pressed: Linphone.DefaultStyle.main1_500_main
		}
	}

// Blue-grey
	var grey = {
		color: {
			normal: Linphone.DefaultStyle.main2_200,
			hovered: Linphone.DefaultStyle.main2_300,
			pressed: Linphone.DefaultStyle.main2_400
		},
		text: {
			normal: Linphone.DefaultStyle.main2_500main,
			pressed: Linphone.DefaultStyle.main2_700
		},
		image: {
			normal: Linphone.DefaultStyle.main2_500main,
			pressed: Linphone.DefaultStyle.main2_700
		}
	}

// Red phone
	var phoneRed = {
		iconSource: Linphone.AppIcons.endCall,
		color: {
			normal: Linphone.DefaultStyle.danger_500main,
			hovered: Linphone.DefaultStyle.danger_700,
			pressed: Linphone.DefaultStyle.danger_900
		},
		text: {
			normal: Linphone.DefaultStyle.grey_0,
			pressed: Linphone.DefaultStyle.grey_0
		},
		image: {
			normal: Linphone.DefaultStyle.grey_0,
			pressed: Linphone.DefaultStyle.grey_0
		}
	}

// Green phone
	var phoneGreen = {
		iconSource: Linphone.AppIcons.phone,
		color: {
			normal: Linphone.DefaultStyle.success_500main,
			hovered: Linphone.DefaultStyle.success_700,
			pressed: Linphone.DefaultStyle.success_900
		},
		text: {
			normal: Linphone.DefaultStyle.grey_0,
			pressed: Linphone.DefaultStyle.grey_0
		},
		image: {
			normal: Linphone.DefaultStyle.grey_0,
			pressed: Linphone.DefaultStyle.grey_0
		}
	}

// Checkable
	var checkable = {
		color: {
			normal: Linphone.DefaultStyle.grey_500,
			hovered: Linphone.DefaultStyle.grey_600,
			pressed: Linphone.DefaultStyle.main2_400
		},
		text: {
			normal: Linphone.DefaultStyle.grey_0,
			pressed: Linphone.DefaultStyle.grey_0
		},
		image: {
			normal: Linphone.DefaultStyle.grey_0,
			pressed: Linphone.DefaultStyle.grey_0,
			checked: Linphone.DefaultStyle.grey_0
		}
	}

// No background
	var noBackground = {
		color: {
			normal: "#00000000",
			hovered: "#00000000",
            pressed: "#00000000",
            checked: Linphone.DefaultStyle.main1_500main
		},
		text: {
			normal: Linphone.DefaultStyle.main2_600,
			hovered: Linphone.DefaultStyle.main2_700,
            pressed: Linphone.DefaultStyle.main2_800,
            checked: Linphone.DefaultStyle.main1_500main
		},
		image: {
			normal: Linphone.DefaultStyle.main2_600,
			hovered: Linphone.DefaultStyle.main2_700,
            pressed: Linphone.DefaultStyle.main2_800,
            checked: Linphone.DefaultStyle.main1_500main
		}
	}

// No background red
	var noBackgroundRed = {
		color: {
			normal: "#00000000",
			hovered: "#00000000",
			pressed: "#00000000"
		},
		text: {
			normal: Linphone.DefaultStyle.danger_500main,
			hovered: Linphone.DefaultStyle.danger_700,
			pressed: Linphone.DefaultStyle.danger_900
		},
		image: {
			normal: Linphone.DefaultStyle.danger_500main,
			hovered: Linphone.DefaultStyle.danger_700,
			pressed: Linphone.DefaultStyle.danger_900
		}
	}

// No background orange
	var noBackgroundOrange = {
		color: {
			normal: "#00000000",
			hovered: "#00000000",
			pressed: "#00000000"
		},
		text: {
			normal: Linphone.DefaultStyle.main1_500_main,
			hovered: Linphone.DefaultStyle.main1_600,
			pressed: Linphone.DefaultStyle.main1_700
		},
		image: {
			normal: Linphone.DefaultStyle.main1_500_main,
			hovered: Linphone.DefaultStyle.main1_600,
			pressed: Linphone.DefaultStyle.main1_700
		}
	}

	// Popup button
	var popupButton = {
		color: {
			normal: "#00000000",
			hovered: Linphone.DefaultStyle.grey_100,
			pressed: Linphone.DefaultStyle.main2_300
		},
		text: {
			normal: Linphone.DefaultStyle.main2_600,
			hovered: Linphone.DefaultStyle.main2_600,
			pressed: Linphone.DefaultStyle.main2_600
		},
		image: {
			normal: Linphone.DefaultStyle.main2_600,
			hovered: Linphone.DefaultStyle.main2_600,
			pressed: Linphone.DefaultStyle.main2_600
		}
	}

// Icon + label button
	var hoveredBackground = {
		color: {
			normal: "#00000000",
			hovered: Linphone.DefaultStyle.main2_100,
			pressed: Linphone.DefaultStyle.main2_100
		},
		text: {
			normal: Linphone.DefaultStyle.main2_500main,
			hovered: Linphone.DefaultStyle.main2_500main,
			pressed: Linphone.DefaultStyle.main2_500main
		},
		image: {
			normal: Linphone.DefaultStyle.main2_500main,
			hovered: Linphone.DefaultStyle.main2_500main,
			pressed: Linphone.DefaultStyle.main2_500main
		}
	}

// Icon + label red button
	var hoveredBackgroundRed = {
		color: {
			normal: "#00000000",
			hovered: Linphone.DefaultStyle.main2_100,
			pressed: Linphone.DefaultStyle.main2_100
		},
		text: {
			normal: Linphone.DefaultStyle.danger_500main,
			hovered: Linphone.DefaultStyle.danger_700,
			pressed: Linphone.DefaultStyle.danger_900
		},
		image: {
			normal: Linphone.DefaultStyle.danger_500main,
			hovered: Linphone.DefaultStyle.danger_700,
			pressed: Linphone.DefaultStyle.danger_900
		}
	}

// Numpad
	var numericPad = {
		color: {
			normal: Linphone.DefaultStyle.grey_0,
			hovered: Linphone.DefaultStyle.grey_200,
			pressed: Linphone.DefaultStyle.grey_300
		},
		text: {
			normal: Linphone.DefaultStyle.main2_600,
			pressed: Linphone.DefaultStyle.main2_700
		}
	}

// Green toast
	var toast = {
		color: {
			normal: Linphone.DefaultStyle.grey_0,
			hovered: Linphone.DefaultStyle.grey_0,
			pressed: Linphone.DefaultStyle.grey_0
		},
		borderColor: Linphone.DefaultStyle.success_500main,
		text: {
			normal: Linphone.DefaultStyle.success_500main,
			pressed: Linphone.DefaultStyle.success_700
		}
	}

// Security blue toast
	var securityToast = {
		color: {
			normal: Linphone.DefaultStyle.grey_0,
			hovered: Linphone.DefaultStyle.grey_0,
			pressed: Linphone.DefaultStyle.grey_0
		},
		borderColor: Linphone.DefaultStyle.info_500_main,
		text: {
			normal: Linphone.DefaultStyle.info_500_main,
			pressed: Linphone.DefaultStyle.info_500_main
		}
	}

// Security red toast
	var securityToastError = {
		color: {
			normal: Linphone.DefaultStyle.grey_0,
			hovered: Linphone.DefaultStyle.grey_0,
			pressed: Linphone.DefaultStyle.grey_0
		},
		borderColor: Linphone.DefaultStyle.danger_500main,
		text: {
			normal: Linphone.DefaultStyle.danger_500main,
			pressed: Linphone.DefaultStyle.danger_500main
		}
	}

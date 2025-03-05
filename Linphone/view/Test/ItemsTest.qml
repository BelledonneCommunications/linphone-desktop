import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone

Window {
	width: 960
	height: 600
	visible: true
    title: ("Test")
	ColumnLayout {
		RowLayout {
			ColumnLayout {
				Text {
					text: "Combobox with image"
				}
				ComboBox {
					model: [
						{text: "item 1", img: AppIcons.info},
						{text: "item 2", img: AppIcons.info},
						{text: "item 3", img: AppIcons.info}
					]
				}
			}
			ColumnLayout {
				Text {
					text: "Combobox without image"
				}
				ComboBox {
					model: [
						{text: "item 1"},
						{text: "item 2"},
						{text: "item 3"}
					]
				}
			}
		}
		RowLayout {
			Button {
				text: "button"
			}
			Button {
				capitalization: Font.AllUppercase
				text: "capital button"
			}
			Button {
				text: "button with long tooltip"
				hoverEnabled: true
				ToolTip {
					visible: parent.hovered
					delay: 1000
					text: " Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc ultrices, arcu ut egestas tincidunt, nisi velit hendrerit nunc, malesuada feugiat enim ipsum eu tortor. Nam a nibh posuere, hendrerit lacus non, blandit nisi. Aliquam quis ipsum sed elit euismod consequat. Donec vitae bibendum justo. Vestibulum ornare quam sit amet velit vestibulum maximus. Curabitur venenatis convallis eros, vitae pulvinar turpis. Pellentesque consequat sodales massa, dapibus sollicitudin nunc ultricies consectetur. Cras id quam luctus, rhoncus neque vitae, aliquet nibh. Quisque placerat, ipsum eu tincidunt elementum, mauris augue rutrum sem, ac accumsan turpis tellus at turpis. Quisque sollicitudin velit vel libero rhoncus tempor. Maecenas ut turpis aliquet, auctor ante sit amet, volutpat orci. Donec purus quam, venenatis a massa in, placerat finibus nulla. Vestibulum ac nunc eu sapien sollicitudin convallis. Aliquam elit quam, scelerisque at diam sed, vestibulum dapibus ligula. Suspendisse lobortis, neque eget iaculis efficitur, lorem ligula posuere urna, id tempor ipsum mi sed lacus. Mauris faucibus fringilla dapibus. Pellentesque quis vulputate odio. Integer pretium, est non fermentum tristique, eros metus vulputate ante, eu laoreet nulla odio in justo. Mauris mollis nulla sit amet erat malesuada interdum. Donec pretium risus ut justo sodales, sed sollicitudin felis consequat. Praesent semper porta leo, nec finibus urna molestie porttitor. Etiam sagittis odio nec turpis consequat dignissim. Sed pellentesque sodales rutrum. Donec varius neque nec ex imperdiet interdum. Suspendisse dignissim elit et dignissim blandit. "
				}
			}
		}

		Carousel {
			itemsList: [
				Component {
					ColumnLayout {
						Text {
							text: "item 1"
						}
						Text {
							text: "item 1"
						}
					}
				},
				Component {
					RowLayout {
						Text {
							text: "item 2"
						}
						Text {
							text: "item 2"
						}
					}
				},
				Component {
					Text {
						text: "item 3"
					}
				}, 
				Component {
					Text {
						text: "item 4"
					}
				}
			]
		}

		Text {
			text: "default text"
		}
		Text {
			id: testText
			scaleLettersFactor: 2
			text: "scaled text"
		}
		RowLayout {
			TextField {
				label: "mandatory text input"
				placeholderText: "default text"
				// mandatory: true
			}
			TextField {
				label: "password text input"
				placeholderText: "default text"
				hidden: true
			}
			TextField {
				id: next
				label: "text input with long long looooooooooooooooooooooooooooooooooooooooooooooooooooooooong label"
				placeholderText: "long long long default text"
			}
			TextField {
				label: "number text input"
				validator: IntValidator{}
			}
		}

		ColumnLayout {
			Text {
				text: "4 digit inputs"
			}
			RowLayout {
				Repeater {
					model: 4
					DigitInput {
					}
				}
			}
		}
		TabBar {
			spacing: 10
			contentWidth: 400
            model: [("A"), ("Lot"), ("Of"), ("Tab"), ("Buttons (which one has a very long label)"), ("For"), ("The"), ("Tab"), ("Bar"), ("To"), ("Not"), ("Have"), ("Enough"), ("Space"), ("To"), ("Display"), ("Them"), ("All")]
		}
		
	}
}

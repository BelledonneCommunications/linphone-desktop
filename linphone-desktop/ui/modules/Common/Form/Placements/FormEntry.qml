import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common.Styles 1.0

// =============================================================================
// Like a `FormGroup` but without label.
// =============================================================================

RowLayout {
  default property alias _content: content.data

  // ---------------------------------------------------------------------------

	spacing: 0
	width: FormGroupStyle.content.width

  Item {
    id: content

    readonly property int currentHeight: _content[0] ? _content[0].height : 0

    Layout.alignment: (
			currentHeight < FormGroupStyle.legend.height ? Qt.AlignVCenter : Qt.AlignTop
		) | Qt.AlignHCenter

    Layout.preferredHeight: currentHeight
		Layout.maximumWidth: FormGroupStyle.content.width
  }
}

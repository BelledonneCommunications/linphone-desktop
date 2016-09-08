import QtQuick 2.7
import QtQuick.Controls 2.0

Button {
    property alias image: backgroundImage.source

    Image {
        anchors.fill: parent
        id: backgroundImage
        fillMode: Image.PreserveAspectFit
    }
}

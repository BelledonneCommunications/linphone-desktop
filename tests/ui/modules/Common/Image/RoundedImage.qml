import QtQuick 2.7

// ===================================================================

Item {
  property alias source: image.source

  Item {
    id: imageContainer

    anchors.fill: parent
    layer.enabled: true
    visible: false

    Image {
      id: image

      anchors.fill: parent
      fillMode: Image.PreserveAspectCrop
    }
  }

  Rectangle {
    anchors.fill: parent

    layer {
      effect: ShaderEffect {
        property var image: imageContainer

        fragmentShader: '
          uniform lowp sampler2D image;
          uniform lowp sampler2D mask;
          uniform lowp float qt_Opacity;

          varying highp vec2 qt_TexCoord0;

          void main () {
            gl_FragColor = texture2D(image, qt_TexCoord0) *
              texture2D(mask, qt_TexCoord0).a *
              qt_Opacity;
          }
        '
      }

      enabled: true
      samplerName: 'mask'
    }

    radius: parent.width / 2
  }
}

import QtQuick 2.7

// ===================================================================

Item {
  property alias source: image.source
  property color colorMask: '#00000000'
  // vec4(0.812, 0.843, 0.866, 1.0) 0.9

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
        property var color: colorMask

        fragmentShader: '
          uniform lowp sampler2D image;
          uniform lowp sampler2D mask;
          uniform lowp vec4 color;

          uniform lowp float qt_Opacity;
          varying highp vec2 qt_TexCoord0;

          void main () {
            vec4 tex = texture2D(image, qt_TexCoord0);

            gl_FragColor = mix(tex, vec4(color.rgb, 1.0), color.a) *
              texture2D(mask, qt_TexCoord0) *
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

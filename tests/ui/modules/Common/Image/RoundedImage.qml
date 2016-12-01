import QtQuick 2.7

// ===================================================================

Item {
  id: item

  property alias source: image.source
  property color backgroundColor: '#00000000'
  property color foregroundColor: '#00000000'
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
        property color backgroundColor: item.backgroundColor
        property color foregroundColor: item.foregroundColor
        property var image: imageContainer

        fragmentShader: '
          uniform lowp sampler2D image;
          uniform lowp sampler2D mask;
          uniform lowp vec4 backgroundColor;
          uniform lowp vec4 foregroundColor;

          uniform lowp float qt_Opacity;
          varying highp vec2 qt_TexCoord0;

          void main () {
            vec4 tex = texture2D(image, qt_TexCoord0);
            vec4 interpolation = mix(backgroundColor, vec4(tex.rgb, 1.0), tex.a);
            interpolation = mix(interpolation, vec4(foregroundColor.rgb, 1.0), foregroundColor.a);

            gl_FragColor = interpolation * texture2D(mask, qt_TexCoord0) * qt_Opacity;
          }
        '
      }

      enabled: true
      samplerName: 'mask'
    }

    radius: parent.width / 2
  }
}

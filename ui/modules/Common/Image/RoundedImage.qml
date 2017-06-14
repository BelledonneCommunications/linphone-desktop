import QtQuick 2.7

// =============================================================================

Item {
  id: item

  property alias source: image.source
  property color backgroundColor: '#00000000'
  property color foregroundColor: '#00000000'
  readonly property alias status: image.status

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

        // See: https://www.opengl.org/sdk/docs/man/html/mix.xhtml
        fragmentShader: '
          #ifdef GL_ES
            precision lowp float;
          #endif
          uniform sampler2D image;
          uniform sampler2D mask;
          uniform vec4 backgroundColor;
          uniform vec4 foregroundColor;

          uniform float qt_Opacity;
          varying vec2 qt_TexCoord0;

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

    radius: width / 2
  }
}

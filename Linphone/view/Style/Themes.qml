pragma Singleton
import QtQuick

QtObject {
    property var themes: {
        return {
            "orange": {
                "main100": "#FFEACB",
                "main200": "#FFD098",
                "main300": "#FFB266",
                "main500": "#FF5E00",
                "main600": "#DA4400",
                "main700": "#B72D00"
            },
            "yellow": {
                "main100": "#FFF5D6",
                "main200": "#FFEFB2",
                "main300": "#FFE799",
                "main500": "#F5BC00",
                "main600": "#C69300",
                "main700": "#A37D00"
            },
            "green": {
                "main100": "#DCF9E7",
                "main200": "#BDF0CF",
                "main300": "#A8F0C2",
                "main500": "#25D366",
                "main600": "#1FA352",
                "main700": "#1C9C4B"
            },
            "blue": {
                "main100": "#D6F4FF",
                "main200": "#B2E9FF",
                "main300": "#99E4FF",
                "main500": "#00AFF0",
                "main600": "#008CC0",
                "main700": "#0078A3"
            },
            "red": {
                "main100": "#FBE1DA",
                "main200": "#F8C1B6",
                "main300": "#F5B53A",
                "main500": "#E14318",
                "main600": "#C23814",
                "main700": "#A63211"
            },
            "pink": {
                "main100": "#FFD6F1",
                "main200": "#FFB8E8",
                "main300": "#FF99DD",
                "main500": "#FF00A9",
                "main600": "#D60090",
                "main700": "#B8007A"
            },
            "purple": {
                "main100": "#FFD6FF",
                "main200": "#F0B3F0",
                "main300": "#FF99FF",
                "main500": "#800080",
                "main600": "#660066",
                "main700": "#520052"
            }
        }
    }
}

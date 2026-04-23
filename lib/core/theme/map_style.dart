class AppMapStyle {
  static const String darkStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      { "color": "#121212" }
    ]
  },
  {
    "elementType": "labels",
    "stylers": [
      { "visibility": "simplified" }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#8a8a8a" }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      { "color": "#121212" }
    ]
  },

  {
    "featureType": "poi",
    "stylers": [
      { "visibility": "off" }
    ]
  },

  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      { "color": "#2c2c2c" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#1a1a1a" }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      { "color": "#3a3a3a" }
    ]
  },

  {
    "featureType": "transit",
    "stylers": [
      { "visibility": "off" }
    ]
  },

  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      { "color": "#0a1f33" }
    ]
  },

  {
    "featureType": "landscape",
    "elementType": "geometry",
    "stylers": [
      { "color": "#161616" }
    ]
  },

  {
    "featureType": "administrative",
    "stylers": [
      { "visibility": "off" }
    ]
  }
]
''';
}

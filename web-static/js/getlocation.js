let Options = {
  enableHighAccuracy: true,
  maximumAge: 0,
};

navigator.geolocation.getCurrentPosition(function(position) {
  const crd = position.coords;
  
  // Initialize the map with user's current location
  var map = L.map('map').setView([crd.latitude, crd.longitude], 13);

  // Add OpenStreetMap tile layer
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);

  // Add a marker at user's current location
  L.marker([crd.latitude, crd.longitude]).addTo(map)
    .bindPopup('Your Location').openPopup();
}, function(error) {
  console.warn(`ERROR(${error.code}): ${error.message}`);
}, Options);


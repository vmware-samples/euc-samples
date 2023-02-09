# Description: Use this sensor to determine the Country or Region or City of the device based upon the NAT'd Public IP. Uses Locationiq.com service to reverse geocode the Lat & Long of the NAT'd address.
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

#Ensure Internet Explorer first launch is disabled
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Value 2

#Reverse GeoLocation
$APIToken = 'pk.d51f727495d5f526486e7a97c94af96a'

Add-Type -AssemblyName System.Device #Required to access System.Device.Location namespace
$GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher #Create the required object
$GeoWatcher.Start() #Begin resolving current locaton
 
while (($GeoWatcher.Status -ne 'Ready') -and ($GeoWatcher.Permission -ne 'Denied')) {
    Start-Sleep -Milliseconds 100 #Wait for discovery.
} 
 
if ($GeoWatcher.Permission -eq 'Denied'){
    Write-Error 'Access Denied for Location Information'
} else {
    $lat = $GeoWatcher.Position.Location | Select Latitude #Select the relevent results.
    $lon = $GeoWatcher.Position.Location | Select Longitude
}

$endpoint = "https://us1.locationiq.com/v1/reverse.php?key=$APIToken&lat=$lat&lon=$lon&format=json"
$devicegeodata = Invoke-RestMethod -Uri $endpoint
$devicegeofull = $devicegeodata.display_name
$devicegeoCountry = $devicegeodata.address.country
$devicegeoRegion = $devicegeodata.address.state
$devicegeoCounty = $devicegeodata.address.county
$devicegeoCity = $devicegeodata.address.city
$devicegeoRoad = $devicegeodata.address.road

#example to return Country
return $devicegeoCountry

#EXAMPLE RETURNED JSON
<# {
  "place_id": "236942763",
  "licence": "https://locationiq.com/attribution",
  "osm_type": "relation",
  "osm_id": "7515426",
  "lat": "48.8611473",
  "lon": "2.33802768704666",
  "display_name": "Louvre Museum, Rue Saint-Honoré, Quartier du Palais Royal, 1st Arrondissement, Paris, Ile-de-France, Metropolitan France, 75001, France",
  "address": {
    "museum": "Louvre Museum",
    "road": "Rue Saint-Honoré",
    "suburb": "Quartier du Palais Royal",
    "city_district": "1st Arrondissement",
    "city": "Paris",
    "county": "Paris",
    "state": "Ile-de-France",
    "country": "France",
    "postcode": "75001",
    "country_code": "fr"
  },
  "boundingbox": [
    "48.8593816",
    "48.8629132",
    "2.3317162",
    "2.3400113"
]} #>


<%

':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
':::                                                                         :::
':::  this routine calculates the distance between two points (given the     :::
':::  latitude/longitude of those points). it is being used to calculate     :::
':::  the distance between two zip codes or postal codes using our           :::
':::  zipcodeworld(tm) and postalcodeworld(tm) products.                     :::
':::                                                                         :::
':::  definitions:                                                           :::
':::    south latitudes are negative, east longitudes are positive           :::
':::                                                                         :::
':::  passed to function:                                                    :::
':::    lat1, lon1 = latitude and longitude of point 1 (in decimal degrees)  :::
':::    lat2, lon2 = latitude and longitude of point 2 (in decimal degrees)  :::
':::    unit = the unit you desire for results                               :::
':::           where: 'm' is statute miles                                   :::
':::                  'k' is kilometers (default)                            :::
':::                  'n' is nautical miles                                  :::
':::                                                                         :::
':::  united states zip code/ canadian postal code databases with latitude   :::
':::  & longitude are available at http://www.zipcodeworld.com               :::
':::                                                                         :::
':::  For enquiries, please contact sales@zipcodeworld.com                   :::
':::                                                                         :::
':::  official web site: http://www.zipcodeworld.com                         :::
':::                                                                         :::
':::  hexa software development center © all rights reserved 2004            :::
':::                                                                         :::
':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

const pi = 3.14159265358979323846

Function distance(lat1, lon1, lat2, lon2, unit)
  Dim theta, dist
  theta = lon1 - lon2
  dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta))
  dist = acos(dist)
  dist = rad2deg(dist)
  distance = dist * 60 * 1.1515
  Select Case unit
    Case "km"
      distance = distance * 1.609344
    Case "nm"
      distance = distance * 0.8684
  End Select
End Function 


'::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
':::  this function get the arccos function from arctan function    :::
'::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Function acos(rad)
  If abs(rad) <> 1 Then
    acos = pi/2 - atn(rad / sqr(1 - rad * rad))
  ElseIf rad = -1 Then
    acos = pi
  End If
End function


'::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
':::  this function converts decimal degrees to radians             :::
'::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Function deg2rad(deg)
	deg2rad = cdbl(deg * pi / 180)
End Function

'::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
':::  this function converts radians to decimal degrees             :::
'::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Function rad2deg(rad)
	rad2deg = cdbl(rad * 180 / pi)
End Function

'l1="40.4"
'o1="-3.6833333"
'l2="-7.0213889"
'o2="110.655"

'dista = distance(l1,o1,l2,o2,"km")
'response.write(dista & "<br>")

'l1=40.4
'o1=-3.6833333
'l2=-7.0213889
'o2=110.655

'dista = distance(l1,o1,l2,o2,"km")
'response.write(dista & "<br>" )

'l1="40,4"
'o1="-3,6833333"
'l2="-7,0213889"
'o2="110,655"


'dista = distance(l1,o1,l2,o2,"km")
'response.write(dista & "<br>")
%>


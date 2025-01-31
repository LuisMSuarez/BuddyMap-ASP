<!--#include file="checksession.asp"-->
<%
title="Calculate distance"
'onloadEvent= "onLoad=""document.search.place.focus()"""
activeLink="Distance"
%>
<!--#include file="header.asp"-->
<!--#include file="links.asp"-->

<%
location = Request.QueryString("loc")
loc1=Session("loc1")
loc2=Session("loc2")

if location<> "" then 'check if we have both locations
  if (loc1<>"") and (location<>loc1) then  'second check is necessary due to the loc appearing as a get parameter again    
    loc2=location
    Session("loc2")=location 'flag to mark a finished search so that another search works due to bothersome get variables
    Session.Contents.Remove("loc1") ' we can (and should) erase the session var as we have the loc1 in the loc1 variable, this will reset for a new search
  else
    loc1=location
    Session("loc1")=location      
  end if
end if

if loc1 = "" then
  Response.Write("<p>" & Application(lang & ".dist.first") & "</p>")
  Session.Contents.Remove("loc2")
else
  if loc2 = "" then
    Response.Write("<p>" & Application(lang & ".dist.second") & "</p>")
  end if
end if

'Response.write("loc1: " & loc1 & "<br> loc2:" & loc2 & "<br>")
if (loc1<>"") and (loc2<>"") then
%>

<!--#include file="connectLocations.asp"-->
<!--#include file="distance.asp"-->
<!--#include file="decimalConvert.asp"-->

<%
Set query= DataConnection.Execute("select * from Locations where (locId=" & loc1 & ") or (locId =" & loc2 & ");")

place=1
while (not query.eof) and (place<=2)
  if place = 1 then
    lat1  = query("lat")
    lon1  = query("lon")
    locId1 = query("locId")
    if query("locNameEX")<>"" then
      locName1=query("locNameEX")
    else
      locName1=query("locName")
    end if
  else
    if query("locId")=locId1 then 'careful with repeated towns with different names (same locID)
      place=1  'skip this location, it's a repeat
    else
      lat2 = query("lat")
      lon2 = query("lon") 
      if query("locNameEX")<>"" then
        locName2=query("locNameEX")
      else
        locName2=query("locName")
      end if
    end if
  end if
  place=place+1
  query.moveNext
wend
'Response.Write(lat1 & " " & lon1 & " " & lat2 & " " & lon2 & "<br>")
DataConnection.Close
distk = distance(lat1,lon1,lat2,lon2,"km")
distm = distance(lat1,lon1,lat2,lon2,"mi")
Response.Write("<p>" & Application(lang & ".dist.result.1") & " <i>" & locName1 & "</i> " & Application(lang & ".and") & " <i>" & locName2 & "</i> " & Application(lang & ".dist.result.2") & " " & Int(distk) & " km; " & Int(distm) & " mi </p>")
%>
<br>
<%
end if 'got towns
Response.Flush
%>

<!--#include file="search.asp"-->

<!--#include file="footer.asp"-->
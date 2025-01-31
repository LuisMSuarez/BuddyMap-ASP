<!--#include file="checksession.asp"-->
<%
title=Application(lang & ".matches.title")
activeLink="Buddies"
%>
<!--#include file="header.asp"-->
<!--#include file="links.asp"-->
<!--#include file="connectBuddy.asp"-->
<!--#include file="distance.asp"-->
<!--#include file="writedate.asp"-->

<br>
<div class="tabs">
<table><tr>
<td class="linkSpc">
<td class="linkInactive"><a href="newBuddy.asp"><%=Application(lang & ".newBuddy.title")%></a>
<td class="linkSpc">
<td class="linkInactive"><a href="buddies.asp"><%=Application(lang & ".buddies.title")%></a>
<td class="linkSpc">
<td class="linkInactive"><a href="buddytrack.asp"><%=Application(lang & ".buddytrack.title")%></a>
<td class="linkSpc">
<td class="linkActive"><%=Application(lang & ".matches.title")%>
<td class="linkSpc">
<td class="linkInactive"><a href="invitations.asp?inline=true"><%=Application(lang & ".invitations.title")%></a>
<td class="linkSpc">
</tr></table>
</div>
<br>

<%
maxDist=Request.Form("maxdist")
buddy=Request.QueryString("buddy")

if Session("unit")="" then
  Session("unit")="km"
end if

if maxDist="" then
  if Session("maxdist")="" then
    Session("maxdist")="200"
  end if
else
  if isnumeric(maxDist) then
    if maxDist >= 0 then 'has to be in a separate if
      Session("maxdist")=maxDist
    end if
  end if
end if

unit=Session("unit")
maxDist=Session("maxdist")

if buddy<>"" then 
'check that this is a buddy for the session user
  Set query = DataConnection.Execute("select * from buddy, Users where login1='" & sessionLogin & "' and " &_
                                   "login2='" & buddy & "' and login=login2;")
  if not query.eof then
    Response.Write("<p><small>Find out if you will come close to " & query("displayName") & "</small></p>")
  else
    Response.Redirect(Request.ServerVariables("SCRIPT_NAME"))
  end if
else
  Response.Write("<p><small>" & Application(lang & ".matches.1") & "</small></p>")
end if
'Response.Write("<p><small>Matches are trips from your buddies that overlap yours.<br>Use the distance filter to display only matches where both locations are close.</small></p>")
%>

<form method="post" action="<%=Request.ServerVariables("SCRIPT_NAME")%>">
<table class="formulario">
<tr>
<td><%=Application(lang & ".matches.filter")%> <input type="text" name="maxdist" size="5" value="<%Response.Write(maxDist)%>"> <%=Session("unit")%> <input type="submit" value="<%=Application(lang & ".save")%>">
</tr>
</table>
</form>
<%
if buddy="" then
  Set hits= DataConnection.Execute("select buddy.category as bcategory, buddyTrip.tripId as btripId, buddyTrip.login as blogin, buddyTrip.share as bshare, buddyTrip.startDate as bstart, buddyTrip.endDate as bend, buddyTrip.locId as blocId, buddyTrip.locName as blocName, buddyTrip.country as bcountry, buddyTrip.lat as blat, buddyTrip.lon as blon, " &_
            			    "myTrip.tripId as mtripId, myTrip.login as mlogin, myTrip.startDate as mstart, myTrip.endDate as mend, myTrip.locId as mlocId, myTrip.locName as mlocName, myTrip.country as mcountry, myTrip.lat as mlat, myTrip.lon as mlon, displayName " &_
                                    "from trips as buddyTrip, trips as myTrip, Users, Buddy " &_
				    "where (Buddy.login1=buddyTrip.login) and (Buddy.login2='" & sessionLogin & "') and (not buddyTrip.archived) and buddyTrip.login  in ( select login2 " &_
                            	    "from Buddy where login1='" & sessionLogin & "' and wantMatch) " &_
                                    "and buddyTrip.login= Users.login " &_
         			    "and exists ( select * from trips where login='" & sessionLogin &_
                                    "' and (not archived) and (endDate >= buddyTrip.startDate) and (buddyTrip.endDate>= startDate) and (tripId=myTrip.tripId)) order by buddyTrip.login, buddyTrip.startDate;")
  

  
else
  Set hits= DataConnection.Execute ("select buddy.category as bcategory, buddyTrip.tripId as btripId, buddyTrip.login as blogin, buddyTrip.share as bshare, buddyTrip.startDate as bstart, buddyTrip.endDate as bend, buddyTrip.locId as blocId, buddyTrip.locName as blocName, buddyTrip.country as bcountry, buddyTrip.lat as blat, buddyTrip.lon as blon, " &_
            			    "myTrip.tripId as mtripId, myTrip.login as mlogin, myTrip.startDate as mstart, myTrip.endDate as mend, myTrip.locId as mlocId, myTrip.locName as mlocName, myTrip.country as mcountry, myTrip.lat as mlat, myTrip.lon as mlon, displayName " &_
                                    "from trips as buddyTrip, trips as myTrip, Users, Buddy " &_
				    "where (Buddy.login1='" & buddy & "') and (Buddy.login2='" & sessionLogin & "') and (not buddyTrip.archived) and (buddyTrip.login='" & buddy & "') " &_
                                    "and buddyTrip.login= Users.login " &_
         			    "and exists ( select * from trips where login='" & sessionLogin &_
                                    "' and (not archived) and (endDate >= buddyTrip.startDate) and (buddyTrip.endDate>= startDate) and (tripId=myTrip.tripId)) order by buddyTrip.login, buddyTrip.startDate;")
end if

filtered=0
i=0

if hits.eof then
  Response.Write("<p>" & Application(lang & ".matches.none") &"</p>")
else
  Response.Write("<table class=""tabla"" align=""center""><tr class=""cabecera""><th>" & Application(lang & ".buddy") &_
                 "<th>" & Application(lang & ".trip") & "<th>" & Application(lang & ".start") & "<th>" & Application(lang & ".end") & "<th>" & Application(lang & ".mytrip") & "<th>" & Application(lang & ".distance") & "</tr>")
end if

while not (hits.eof)
  if (CInt(hits("bshare")) mod 2 = 0) or (CInt(hits("bshare")) mod CInt(hits("bcategory"))= 0) then 
    'response.write(hits("blat") & " " & hits("blon") & " " & hits("mlat") & " " & hits("mlon")& " " &"k<br>")
    dist = distance(hits("blat"),hits("blon"),hits("mlat"),hits("mlon"), unit) 
    if Int(dist) <=  Int(maxDist) then   
      if (i mod 2)=0 then 
        Response.Write("<tr class=""even"">")
      else
        Response.Write("<tr class=""odd"">")
      end if
        Response.Write("<td>" & hits("displayName") & " (" & hits("blogin") & ")"&_
                     "<td>" & hits("blocName") & " (" & Application("CNT." & hits("bcountry")) & ")<td>" & writeDate(hits("bstart")) & "<td>" & writeDate(hits("bend")) & "<td>" & hits("mlocName") & " (" & Application("CNT." & hits("mcountry")) & ") <td>" & Int(dist) & " " & unit & "</tr>")
      i=i+1
    else
      filtered=filtered+1
    end if
  end if  
  hits.moveNext
wend
hits.close
DataConnection.Close
Response.Write("</table>")

if filtered>0 then
  Response.Write("<p>" & Application(lang & ".matches.filtered") & "</p>")
else
  'Response.Write("<p>Displaying all matches</p>")
end if
%>

<!--#include file="footer.asp"-->
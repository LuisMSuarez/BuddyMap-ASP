<!--#include file="checksession.asp"-->
<%
title=Application(lang & ".mytrips.current.title")
activeLink="My Trips"
%>
<!--#include file="header.asp"-->
<!--#include file="links.asp"-->
<!--#include file="connectBuddy.asp"-->
<!--#include file="writedate.asp"-->
<%

function writeshare(isshare)
  if isshare then
    writeshare="Yes"
  else
    writeshare="No"
  end if
end function

'note, we are displaying dd-MONTH-yy to avoid date problems.  could use Session.LCID = 1033 etc instead
%>

<br>
<div class="tabs">
<table><tr>
<td class="linkSpc">
<td class="linkInactive"><a href="newtrip.asp"><%=Application(lang & ".newtrip.title")%></a>
<td class="linkSpc">
<td class="linkActive"><%=Application(lang & ".mytrips.current.title")%>
<td class="linkSpc">
<td class="linkInactive"><a href="archive.asp"><%=Application(lang & ".mytrips.archived.title")%></a>
<td class="linkSpc">
<td class="linkInactive"><a href="myLog.asp"><%=Application(lang & ".mylog.title")%></a>
<td class="linkSpc">
</tr></table>
</div>
<br>

<%
predel=Request.QueryString("predel")
deltrip=Request.QueryString("del")
archtrip=Request.QueryString("arch")

if predel<>"" then 'request confirmation
  Response.Write("<p>" & Application(lang & ".mytrips.delete.comfirm") & "<br><a href="&""""&Request.ServerVariables("SCRIPT_NAME")&"?del=" & predel &""">" & Application(lang & ".yes" ) & "</a>  <a href="&""""&Request.ServerVariables("SCRIPT_NAME") & """>" & Application(lang & ".cancel" ) & "</a></p>")
end if

if deltrip <> "" then
  Set query = DataConnection.Execute("select * from trips where login='" & sessionLogin & "' and tripId=" & deltrip & ";")
  if not query.eof then
    DataConnection.Execute("delete from trips where tripId=" & deltrip & ";")
  end if
end if

if archtrip <> "" then
  Set query = DataConnection.Execute("select * from trips where login='" & sessionLogin & "' and tripId=" & archtrip & ";")
  if not query.eof then
    DataConnection.Execute("update trips set archived=1 where tripId=" & archtrip & ";")
  end if
end if

Set countquery = DataConnection.Execute("select count(*) as tripCount from Trips where (login='" & sessionLogin & "') and (not archived);")
plotCount=CInt(countquery("tripCount"))
countquery.close

Dim lats(),lons(),names()
ReDim lats(plotCount)
ReDim lons(plotCount)
ReDim names(plotCount)

Set query = DataConnection.Execute("select * from trips where (login='" & sessionLogin & "') and (not archived) order by startDate asc;")
'Response.Write("<p><small>Remember to archive your old trips, to enhance trip matching and performance.</small></p>")
if query.eof then
  Response.Write("<p>" & Application(lang & ".trips.empty") & "</p>")
else  
  Response.Write("<table class=""tabla""><tr class=""cabecera""><th>" & Application(lang & ".location") & "<th>" & Application(lang & ".start") & "<th>" & Application(lang & ".end") & "<th>" & Application(lang & ".delete") & "<th>" & Application(lang & ".archive") &"</tr>")
end if

i=0
while not (query.eof)  
  if (i mod 2)=0 then 
    Response.Write("<tr class=""even"">")
  else
    Response.Write("<tr class=""odd"">")
  end if

  locationName=query("locName")
  locReg=Application("REG." & query("country") & "." & query("region"))
  if locReg<>"" then
    locationName=locationName & " (" & locReg & ")"
  end if

  Response.Write("<td><a href=""newtrip.asp?mod=" & query("tripId") & """>" & locationName & "</a>" &_
                 "<td>" & writeDate(query("startDate")) &_
                 "<td>" & writeDate(query("endDate")) &_
		 "<td><a href=""" & Request.ServerVariables("SCRIPT_NAME") & "?predel=" & query("tripId") & """>" & Application(lang & ".delete") &"</a>" &_
                 "<td><a href=""" & Request.ServerVariables("SCRIPT_NAME") & "?arch=" & query("tripId") & """>" & Application(lang & ".archive") & "</a>" &_                       
                 "</tr>")
  lats(i)= query("lat")
  lons(i)= query("lon")
  names(i)=query("locName")
  i=i+1
  query.moveNext
wend
DataConnection.Close
Response.Write("</table>")
%>
<!--#include file="plotList.asp"-->
<!--#include file="footer.asp"-->
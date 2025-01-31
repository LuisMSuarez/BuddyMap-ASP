<!--#include file="connectBuddy.asp"-->

<%
inline=Request.QueryString("inline")
if inline<>"" then%>
<!--#include file="checksession.asp"-->
<%
title=Application(lang & ".invitations.title")
activeLink="Buddies"
%>
<!--#include file="header.asp"-->
<!--#include file="links.asp"-->

<br>
<div class="tabs">
<table><tr>
<td class="linkSpc">
<td class="linkInactive"><a href="newBuddy.asp"><%=Application(lang & ".newbuddy.title")%></a>
<td class="linkSpc">
<td class="linkInactive"><a href="buddies.asp"><%=Application(lang & ".buddies.title")%></a>
<td class="linkSpc">
<td class="linkInactive"><a href="buddytrack.asp"><%=Application(lang & ".buddytrack.title")%></a>
<td class="linkSpc">
<td class="linkInactive"><a href="matches.asp"><%=Application(lang & ".matches.title")%></a>
<td class="linkSpc">
<td class="linkActive"><%=Application(lang & ".invitations.title")%>
<td class="linkSpc">
</tr></table>
</div>
<br>

<%end if%>

<%
delbuddy=Request.QueryString("del")
if delbuddy <> "" then
  DataConnection.Execute("delete from BuddyLink where login2='" & sessionLogin & "' and login1='" & delbuddy & "';")
end if

Set query = DataConnection.Execute("select * from BuddyLink, Users where login2='" & _
                                 sessionLogin & "' and login1=login;")
if query.eof then
  Response.Write("<p>" & Application(lang & ".invitations.nopending") & "</p>")
else
  Response.Write("<p><small>" & Application(lang & ".invitations.pending") & "</small></p>")
  Response.Write("<table class=""tabla""><tr class=""cabecera""><th>" & Application(lang & ".buddy") &"<th>" & Application(lang & ".accept") & "<th>" & Application(lang & ".reject") & "</tr>")

  i=0
  while not query.eof
    if (i mod 2)=0 then 
      Response.Write("<tr class=""even"">")
    else
      Response.Write("<tr class=""odd"">")
    end if
    Response.Write("<td>" & query("displayName") & " (" & query("login1") & ")" & _
                   "<td><a href=""newBuddy.asp?buddy=" & query("login1") & """>" & Application(lang & ".accept") & " </a>" &_
                   "<td><a href=""" & Request.ServerVariables("SCRIPT_NAME") & "?del=" & query("login1") & """>" & Application(lang & ".reject") & "</a></tr>")
    i=i+1
    query.moveNext
  wend
  Response.Write("</table>")
end if
DataConnection.Close
%>
<%if inline<>"" then%>
<!--#include file="footer.asp"-->
<%end if%>
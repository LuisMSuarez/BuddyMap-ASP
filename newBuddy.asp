<!--#include file="checksession.asp"-->
<%
title=Application(lang & ".newBuddy.title")
onloadEvent= "onLoad=""document.addbuddy.buddy.focus()"""
activeLink="Buddies"
%>
<!--#include file="header.asp"-->
<!--#include file="links.asp"-->
<br>
<div class="tabs">
<table><tr>
<td class="linkSpc">
<td class="linkActive"><%=Application(lang & ".newBuddy.title")%>
<td class="linkSpc">
<td class="linkInactive"><a href="buddies.asp"><%=Application(lang & ".buddies.title")%></a>
<td class="linkSpc">
<td class="linkInactive"><a href="buddytrack.asp"><%=Application(lang & ".buddytrack.title")%></a>
<td class="linkSpc">
<td class="linkInactive"><a href="matches.asp"><%=Application(lang & ".matches.title")%></a>
<td class="linkSpc">
<td class="linkInactive"><a href="invitations.asp?inline=true"><%=Application(lang & ".invitations.title")%></a>
<td class="linkSpc">
</tr></table>
</div>
<br>
<p><small><%=Application(lang & ".newBuddy.help")%></small></p>
<form name="addbuddy" method="post" action="<%=Request.ServerVariables("SCRIPT_NAME")%>">
<table class="formulario">
<tr><td><%=Application(lang & ".newBuddy.form")%>
<td><input type="text" name="buddy" size="15" value="">
<td colspan="2"><input type="submit" value="<%=Application(lang & ".search")%>"></tr>
</table>
</form>

<%
'check if we add a buddy: can be in get (invitations) or form
if Request.Form("buddy")<>"" then 
  theBuddy=Request.Form("buddy") 
else
  if Request.QueryString("buddy")<> "" then
    theBuddy=Request.QueryString("buddy")
  else
    theBuddy=""
  end if
end if
theBuddy=replace(theBuddy,"'","")

if (theBuddy <> "") and (theBuddy <> sessionLogin) then 'add it
%>
<!--#include file="connectBuddy.asp"-->
<%
  'first check if we already are buddies
  Set query = DataConnection.Execute("select * from Buddy where login1='" & sessionLogin & "' and login2='" & theBuddy & "';")
  if not query.eof then
    Response.Write("<p class=""error"">" & theBuddy & " and you already are buddies!</p>")
  else 
    on error resume next ' avoid SQL errors: don't want hackers to validate login names
    DataConnection.Execute("insert into BuddyLink values ('" & sessionLogin & _
                           "','" & theBuddy & "');")
    ' check if both links exist => create buddy relationship
    Set query = DataConnection.Execute("select * from BuddyLink where login1='" & _
                                   theBuddy & "' and login2='" & sessionLogin & "';")
    if not query.eof then
      ' there is a reciprocal relationship
      DataConnection.Execute("insert into Buddy(login1,login2,wantMatch,category) values ('" & sessionLogin & _
                             "','" & theBuddy & "',1,2);")
      DataConnection.Execute("insert into Buddy(login1,login2,wantMatch,category) values ('" & theBuddy & _
                             "','" & sessionLogin & "',1,2);")    
      DataConnection.Execute("delete from BuddyLink where (login1='" & sessionLogin & "'" & _
                             " and login2='" & theBuddy & _
                             "') or (login1='" & theBuddy & "' and login2='" & _
                             sessionLogin & "');") 
      Response.Write("<p><i>" & theBuddy & "</i> and you are now buddies</p>")  
    else
      Response.Write("<p><i>" & theBuddy & "</i> " & Application(lang & ".newbuddy.done") &"</p>") 
    end if
  end if
  DataConnection.Close
end if
%>
<!--#include file="footer.asp"-->
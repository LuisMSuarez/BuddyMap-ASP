<%
' Set the language priority: lowest: browser, session, link : highest
lang=Left(Request.ServerVariables("HTTP_ACCEPT_LANGUAGE"),2)

if Session("lang")<> "" then
  lang = Session("lang")
end if

qsLang = Request.QueryString("lang")
if qsLang <> "" then
  lang=qsLang
end if

if (lang<>"es") and (lang<>"en") and (lang<>"fr") then
  lang="en"
end if

if Application(lang & ".loc")<>"true" then
  Server.execute "loc_" & lang & ".asp"
end if

Session("lang")=lang

title=Application(lang & ".logon.title")
onloadEvent= "onLoad=""if(document.forms['logon']!=null) document.logon.login.focus();"""
headScript="<script type=""text/javascript"" src=""imgPreload.js""></script>"
%>
<!--#include file="header.asp"-->
<% 
login = Request.Form("login")
password = Request.Form("password")
if login <>"" then
  login=replace(login,"'","") 'SQL does not like apostrophes
  password=replace(password,"'","")
%>
<!--#include file="connectBuddy.asp"-->
<%
Set query = DataConnection.Execute("select * from Users where login='"& login & "'")
if(query.eof) then
  Response.write("<p class=""error"">" & Application(lang & ".form.baddata") &"</p>")
else 
%>
<!--#include file="sha256.asp"-->
<%  
  'Response.Write(sha256(query("salt") & password) & " " & query("passwd"))
  if Cstr(sha256(query("salt") & password)) <> Cstr(query("passwd")) then
    Response.write("<p class=""error"">Invalid logon credentials</p>")
    DataConnection.Close
  else ' validation OK: initialize the session state; first, find out where we are
    today=now()
    todayDate= "#" & Year(today) & "-" & Month(today) & "-" & Day(today) & "#"

    Set current= DataConnection.Execute("select * from trips where login='" & login & "' and (" & todayDate & " between startDate and endDate) and (not archived);" )
    if current.eof then
      currentLocation=query("hometownName") & " (" & Application("CNT." & query("hometownCountry")) & ")"
      currentLat=query("hometownLat")
      currentLon=query("hometownLon")
    else
      currentLocation=current("locName") & " (" & Application("CNT." & current("country")) & ")"
      currentLat=current("lat")
      currentLon=current("lon")
    end if
    current.close

    ' update last logon info
    DataConnection.Execute("update Users set lastLogon=" & todayDate & " where login='" & login & "';")   
    
    Session.Timeout = 15
    Session("login")=login
    Session("latitude")=currentLat
    Session("longitude")=currentLon
    Session("currentLocation")=currentLocation
    Session("unit")=query("unit")
    Session("authenticated")=true

    DataConnection.Close 
    
    ' check if the session cookie worked
    if Session("login")<>login then
      Response.Write("Could not start the session.  Please enable cookies in your browser")
    end if
    ' the user is correctly validated and initialized => he can go to the menu     
    Response.Redirect("menu.asp")
    end if  
  end if    
end if 'login <>""
%>
<small><a href="?lang=en">English</a> | <a href="?lang=es">Español</a> | <a href="?lang=fr">Français</a></small>
<p><small><%=Application(lang & ".logon.logon.title.1")%><a href="newuser.asp"> <%=Application(lang & ".logon.logon.title.2")%></a></small></p>
<form name="logon" method="post" action="logon.asp">
<table class="formulario">
<tr><td><%=Application(lang & ".user")%><td><input type="text" name="login" size="30" value="" class="login"></tr>
<tr><td><%=Application(lang & ".password")%><td><input type="password" name="password" size="30" value="" class="login"></tr>
</table><br>
<center><input type="submit" value="<%=Application(lang & ".enter")%>"></center>
</form>
<p class="txt">
BuddyMapy is a convenient way to know where your family and friends are at any given moment.<br>
You can also know how far away your "buddies" are from you, and share travel plans with them.<br>
BuddyMap is safe.  Only your authorised buddies will be able to review your travel plans.  You can also choose not to share each individial trip information, to keep it as private bookings, or grant access depending on group membership (family, friends, work)<br>
Adds a bonus search utility to find the distance between any two cities in the world, form our global database, with more than 2 million features.<br>
</p>
<p><small><%=Application( lang & ".logon.applets")%>.</small><p>
<a href="http://validator.w3.org/check/referer" target="_blank"><img border="0"src="http://www.w3.org/Icons/valid-html401" alt="Valid HTML 4.01!" height="31" width="88"></a>
&nbsp;
<a href="http://jigsaw.w3.org/css-validator/check/referer" target="_blank"><img border="0" width="88" height="31" src="http://jigsaw.w3.org/css-validator/images/vcss" alt="Valid CSS!"></a>
&nbsp;
<a href="http://www.java.com" target="_blank"><img border="0" src="get_java_green_button.gif" alt="Java Get it Now Logo"></a>&nbsp;
</p>
<p><small><a href="credits.asp">Credits | </a><a href="about.asp">About</a></small></p>

<!-- preload the flash animation!!! -->
<object type="application/x-shockwave-flash" data="radar.swf" width="0" height="0" id="radar">
<param name="movie" value="radar.swf">
<p class="error">You need the Flash plugin. <a href="http://www.macromedia.com/go/getflashplayer/">Download the Macromedia Flash Player</a></p>
</object>

<% 'check the locations cache!!!
if Application("cache")<>"true" then
  Server.Execute "cache.asp"
end if
%>
<!--#include file="footer.asp"-->
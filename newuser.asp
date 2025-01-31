<%
lang=session("lang")
title=Application(lang & ".newuser.title")
'onloadEvent= "onLoad=""if(document.forms['search']!=null) document.search.place.focus(); else if (document.forms['user']!=null) document.user.login.focus();"""
%>
<!--#include file="header.asp"-->
<% 

''''''state semantics
''''''empty => just got here, form to request user info
''''''1 => got user info => validate and request hometown
''''''2 => requesting hometown
''''''3 => got hometown => validate and save new user

function validateEmail(ByVal strEmail, ByVal blnRequired)
  dim objRegX
  dim blnGoodMail

  blnGoodMail = false
  set objRegX = new regexp
  objRegX.IgnoreCase = true
  objRegX.Pattern = "[\w|\.]+\@{1}\w+\.\w{2,3}"

  if objRegX.Test(strEmail) THEN
    blnGoodMail = true
  elseif blnRequired = false and len(strEmail) = 0 THEN
    blnGoodMail = true
  end if

  validateEmail = blnGoodMail
end function

state=Session(Request.ServerVariables("SCRIPT_NAME"))
location = Request.QueryString("loc")
cancel=Request.QueryString("cancel")
login=replace(replace(Request.Form("login"),"'","")," ","")
valid=true

if cancel="true" then
  Session.Contents.Remove(Request.ServerVariables("SCRIPT_NAME"))
  Response.Redirect(Request.ServerVariables("SCRIPT_NAME"))
end if

'state transition logic
if (state="") and (Request.Form.Count>0) then
  state="1"
elseif (state="2") and (location<>"") then
  state="3"
end if

'Response.Write("state:" & state & " " & location)

if state="1" then 'validate user info
  email = replace(Request.Form("email"),"'","")
  displayName = replace(Request.Form("displayName"),"'","''")
  password = replace(Request.Form("password"),"'","")
  unit = replace(Request.Form("unit"),"'","")  
  homepage= replace(Request.Form("homepage"),"'","")
  photograph= replace(Request.Form("photograph"),"'","")
  
  valid = validateEmail(email,true) and (displayName<>"") and (password<>"") and (unit<>"")
  if valid then 'check if user exists
%>
<!--#include file="connectBuddy.asp"-->
<%
    Set query = DataConnection.Execute("select * from Users where login='" & login & "'")
    exists = not (query.eof)
    DataConnection.Close
    if exists then
      valid=false
      Response.Write("<p class=""error"">" & Application(lang & ".newuser.error.dupe") & "</p>")
    else
      state="2"
      'save the stuff
      Session("login")=login
      Session("email")=email
      Session("displayName")=displayName
      Session("password")=password
      Session("unit")=unit
      Session("homepage")=homepage
      Session("photograph")=photograph
      Session(Request.ServerVariables("SCRIPT_NAME"))="2"    
    end if
  else
    Response.Write("<p class=""error"">" & Application(lang & ".form.baddata") & "</p>")
  end if
end if 'state=1

if state="2" then 'search hometown
  Response.Write("<p>" & Application(lang & ".profile.change.hometown.title") & "<br><a href=""" & Request.ServerVariables("SCRIPT_NAME") & "?cancel=true""" & ">" & Application(lang & ".cancel") & "</a></p>")
%>
<!--#include file="search.asp"-->
<%
end if 'state=2

if state="3" then 'time to save
  login = replace(Session("login"),"'","")
  email = replace(Session("email"),"'","")
  displayName = replace(Session("displayName"),"'","''")
  password = replace(Session("password"),"'","")
  unit = replace(Session("unit"),"'","")  
  homepage = replace(Session("homepage"),"'","")
  photograph = replace(Session("photograph"),"'","")
  'cache the hometown information first from locations database
%>
<!--#include file="connectLocations.asp"-->
<!--#include file="decimalConvert.asp"-->
<%
  Set query= DataConnection.Execute("select * from Locations, Countries where (locId=" & location & ") and (country=countryCode);")
  if not query.eof then
    hometownName=query("locNameEX")    

    if query("region") <> "" then 'get regional info
      newquery= "select * from locations where (country='" & query("country") & "') and (region='" & query("region") & "') and (DSG='ADM1');"
      Set regquery = DataConnection.Execute(newquery)
      if not regquery.eof then
        hometownName=hometownName & " (" & regquery("locNameEx") & ")"
      end if  
      regquery.close
    end if 

    hometownCountry=query("countryName")  
    hometownLat=decimalConvert(query("lat"))
    hometownLon=decimalConvert(query("lon"))
  else
    hometownName=""
    hometownCountry=""  
  end if
  DataConnection.Close
%>
<!--#include file="connectBuddy.asp"-->
<%
  Set exists = DataConnection.Execute("select * from Users where login='" & login &"'")
  if not exists.eof then
    Response.Write("cannot create user: the user already exists")
    DataConnection.Close 
  else
  ' create random salt
    Randomize
    salt=""
    For i = 1 to 10
      mix = Int(3 * Rnd + 1)
      Select Case mix
        Case 1 newchar = Int(10 * Rnd + 48)
        Case 2 newchar = Int(26 * Rnd + 97)
        Case 3 newchar = Int(26 * Rnd + 65)
      End Select
      salt = salt & chr(newchar)      
    Next
%>
<!--#include file="sha256.asp"-->
<%
    'now hash and store hashed password
    hashed = sha256(salt & password)
    'Response.Write(salt & " " & hashed)
    query= "insert into Users(login,email,displayName,passwd,salt,hometown,hometownName,hometownCountry,hometownLat,hometownLon,unit,homepage,photograph) values('" & login & "','" & _
            email & "','" & _
            displayName & "','" & _
            hashed & "','" & salt & "'," & location & ",'" & hometownName & "','" & hometownCountry & "'," & hometownLat & "," & hometownLon & ",'" & unit & "','" & homepage & "','" & photograph & "');"
    'Response.Write(query)
    DataConnection.Execute(query)
    DataConnection.Close  
    Response.Write("<p>" & Application(lang & ".newuser.ok") & "</p><p>" & Application(lang & ".username") & ": <i>" & login & " </i><br>" & Application(lang & ".display") & ": <i>" & displayName & "</i><br>" & Application(lang & ".email") & ": <i>" & email & "</i><br>" & Application(lang & ".hometown") & ": " & hometownName & " (" & hometownCountry & ")<i> </i></p>")
    Response.Write("<p><a href=""logon.asp"">" & Application(lang & ".account.logon") & "</a></p>")
    'Response.Redirect("logon.asp")
  end if  
end if 'state 3

if (not Valid) or (state="") then 'user data form
  buttonCaption=Application(lang & ".next")
  Response.Write("<p><small>" & Application(lang & ".newuser.help") & "</small></p>")
  loginDisabled=false
  passwordDisabled=false
%>
<!--#include file="user.asp"-->
<% end if %>
<p><small><a href="javascript:window.history.back()"><%=Application(lang & ".back")%></a></small></p>

<!-- preload the applet!!! -->
<applet code="Plotter" name="Plotter" width="0" height="0">
<param name="cache_option" VALUE="plugin">
<param name="cache_archive" VALUE="Plotter.jar,PlotterData.jar, PlotterMaps.jar">
<param name="cache_version" VALUE="1.0.1.0, 1.0.0.0, 1.0.0.0">
<param name=points value="0">
<p class="error">You need the Java applet plugin</p>
<p><a href="http://www.java.com">Download Java</a></p>
</applet>

<!--#include file="footer.asp"-->
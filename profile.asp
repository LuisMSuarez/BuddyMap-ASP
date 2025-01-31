<!--#include file="checksession.asp"-->
<%
title="My profile"
activeLink="Profile"
%>
<!--#include file="header.asp"-->
<!--#include file="links.asp"-->

<%
''''''state semantics
''''''empty => just got here, display form with user info
''''''1 => got user info => validate and save
''''''2 => changing hometown
''''''3 => got hometown => validate and save hometown
''''''4 => changing password
''''''5 => got password => validate and save password

function validateEmail(ByVal strEmail, ByVal blnRequired)
dim objRegX
dim blnGoodMail

blnGoodMail = false
SET objRegX = new regexp
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
modHT = Request.QueryString("modht")
modPW = Request.QueryString("modpw")
cancel=Request.QueryString("cancel")
oldpw = Request.Form("oldpw")
newpw = Request.Form("newpw")
newpwConfirmed = Request.Form("newpwConfirmed")

if cancel="true" then
  Session.Contents.Remove(Request.ServerVariables("SCRIPT_NAME"))
  Response.Redirect(Request.ServerVariables("SCRIPT_NAME"))
end if

'state transition
if (state="") and (Request.Form.Count>0) then
  state="1"
end if

if modHT<>"" then
  state="2"
  Session(Request.ServerVariables("SCRIPT_NAME"))="2"
end if

if (state="2") and (location <> "") then
  state="3"
end if

if modPW="true" then
  state="4"
  Session(Request.ServerVariables("SCRIPT_NAME"))="4"
end if

if (state="4") and (oldpw <> "") then
  state="5"
end if

'Response.Write("state:" & state & email)

if state="" then
%>
<!--#include file="connectBuddy.asp"-->
<%
  Set query = DataConnection.Execute("select * from Users where login='" & sessionLogin & "'")
  if not (query.eof) then
    login=sessionLogin
    email=query("email")
    displayName=query("displayName")
    password= "boguspassword"
    hometown=query("hometown")
    hometownName= query("hometownName")
    unit=query("unit")
    homepage=query("homepage")
    photograph=query("photograph")
    Session("hometownName")=hometownName  'cache hometown in a session variable for future rounds
    loginDisabled=true
    passwordDisabled=true
    buttonCaption=Application(lang & ".save")
    if photograph="" then
      photograph="peon.png"
    end if
%>
<br>
<!--#include file="user.asp"-->
<%
    'Response.Write("<a href=" & photograph & " target=""_blank""><img border=""0"" src=" & photograph & " height=""100"" width=""100""></a>")
    Response.Write("<p>" & Application(lang & ".profile.change") & "<a href=""" & Request.ServerVariables("SCRIPT_NAME") & "?modpw=true""> " & Application(lang & ".profile.change.pwd") & " </a></p>")
    Response.Write("<p>" & Application(lang & ".profile.change") & " <a href=""" & Request.ServerVariables("SCRIPT_NAME") & "?modht=true"">"  & hometownName & "</a> " & Application(lang & ".profile.change.hometown") & "</p>")
    DataConnection.Close
  end  if
end if

if state="1" then 'validate user info
  email = replace(Request.Form("email"),"'","")
  displayName = replace(Request.Form("displayName"),"'","''")
  homepage = replace(Request.Form("homepage"),"'","''")
  photograph = replace(Request.Form("photograph"),"'","''")
  hometownName=Session("hometownName")
  unit = replace(Request.Form("unit"),"'","")
  valid = validateEmail(email,true) and (displayName<>"") and (unit<>"")
 
  if valid then 'update user
%>
<!--#include file="connectBuddy.asp"-->
<%
    DataConnection.Execute("update Users set email='" & email & "', displayName='" & displayName &_
                           "', unit='" & unit & "', homepage='" & homepage & "', photograph='" & photograph &_
                           "' where login='" & sessionLogin & "';")
    DataConnection.Close
    Session("unit")=unit
    Response.Write("<p>" & Application(lang & ".profile.change.ok") & "</p>")
  else
    Response.Write("<p class=""error"">" & Application(lang & ".form.baddata") & "</p>")
  end if
  login=sessionLogin
  loginDisabled=true
  passwordDisabled=true
  buttonCaption=" save "
  unit=session("unit")
  password= "boguspassword"
%>
<!--#include file="user.asp"-->
<%
   Response.Write("<p>" & Application(lang & ".profile.change") & "<a href=""" & Request.ServerVariables("SCRIPT_NAME") & "?modpw=true""> " & Application(lang & ".profile.change.pwd") & " </a></p>")
   Response.Write("<p>" & Application(lang & ".profile.change") & " <a href=""" & Request.ServerVariables("SCRIPT_NAME") & "?modht=true"">"  & hometownName & "</a> " & Application(lang & ".profile.change.hometown") & "</p>")
 end if 'state=1

if (state="2") then
  Response.Write("<p>" & Application(lang & ".profile.change.hometown.title") & "<br><a href=""" & Request.ServerVariables("SCRIPT_NAME") & "?cancel=true""" & ">" & Application(lang & ".cancel") & "</a></p>")
%>
<!--#include file="search.asp"-->
<%
end if

if state="3" then 'got new hometown
 'cache the hometown information first from locations database
%>
<!--#include file="connectLocations.asp"-->
<!--#include file="decimalConvert.asp"-->
<%
  Set query= DataConnection.Execute("select * from Locations where (locId=" & location & ");")
  if not query.eof then
    hometownName=query("locNameEX")
    cou = query("country")
    reg = query("region")       

    hometownLat=decimalConvert(query("lat"))
    hometownLon=decimalConvert(query("lon"))
    'reset our current location, not valid if we are in a trip right now, could tell the user to re-log in
    session("latitude")=query("lat")
    session("longitude")=query("lon")
  else
    hometownName=""
    hometownCountry=""  
  end if
  DataConnection.Close
%>
<!--#include file="connectBuddy.asp"-->
<%
  on error resume next
  DataConnection.Execute("update Users set hometown=" & location & ", hometownName='" & hometownName & "', hometownCountry='" & cou & "', hometownRegion='" & reg & "' where login='" & sessionLogin & "';")
  DataConnection.Close
  Response.Write("<p>" & Application(lang & ".profile.change.ok") & "</p>")
  Session.Contents.Remove(Request.ServerVariables("SCRIPT_NAME"))
end if

if state="5" then 'password stuff
  oldpw = replace(oldpw,"'","")
  newpw = replace(newpw,"'","")
  newpwConfirmed = replace(newpwConfirmed,"'","")

  if (oldpw<>"") and (newpw<>"") and (newpwConfirmed<>"") then
    if newpw=newpwConfirmed then
%>
<!--#include file="connectBuddy.asp"-->
<%
      Set query = DataConnection.Execute("select * from Users where login='"& sessionLogin & "';")
      if(query.eof) then
        Response.write("<p class=""error"">Could not change password</p>")
        state="4"
      else 
%>
<!--#include file="sha256.asp"-->
<%  
        salt=query("salt")
        newhash = sha256(salt & newpw)
        oldhash = sha256(salt & oldpw)
        'response.write(newhash & ":" & query("passwd"))
        if Cstr(oldhash) <> Cstr(query("passwd")) then
          Response.write("<p class=""error"">" & Application(lang & ".profile.change.nok.old") & "</p>")
          state="4"
        else
          DataConnection.Execute("update Users set passwd='" & newhash & "' where login='" & sessionLogin & "';") 
          Response.Write("<p>" & Application(lang & ".profile.change.ok") & "</p>")
          Session.Contents.Remove(Request.ServerVariables("SCRIPT_NAME"))
        end if
        DataConnection.Close
      end if
    else
      Response.Write("<p class=""error"">" & Application(lang & ".profile.change.nok.match") & "</p>")
      state="4"
    end if
  else
    Response.Write("<p class=""error"">" & Application(lang & ".form.baddata") & "</p>")
    state="4"
  end if
end if

if state="4" then  'leave state 4 under state 5, so the form is displayed on error of state 5
 Response.Write("<p>" & Application(lang & ".profile.change.pwd.title") & "<br><a href=""" & Request.ServerVariables("SCRIPT_NAME") & "?cancel=true""" & ">" & Application(lang & ".cancel") & "</a></p>")
%>

<form name="password" method="post" action="<%=Request.ServerVariables("SCRIPT_NAME")%>">
<table class="formulario">
<tr><td><%=Application(lang & ".profile.change.pwd.old")%><td><input type="password" name="oldpw" class="profile" value=""></tr>
<tr><td><%=Application(lang & ".profile.change.pwd.new")%><td><input type="password" name="newpw" class="profile" value=""></tr>
<tr><td><%=Application(lang & ".profile.change.pwd.confirm")%><td><input type="password" name="newpwConfirmed" class="profile" value=""></tr>
<tr><td colspan="2"><input type="submit" value="<%=Application(lang & ".save")%>"></tr>
</table>
</form>

<%
end if
%>

<!--#include file="footer.asp"-->
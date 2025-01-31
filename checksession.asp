<%
lang=Session("lang")
if Session("authenticated")<>true then
  logonerror=true
  Response.redirect("logon.asp")
end if
sessionLogin = Session("login")
%>


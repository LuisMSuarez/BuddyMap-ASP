<%
title="Admin tools - Users"
%>
<!--#include file="header.asp"-->
<!--#include file="connectBuddy.asp"-->
<table class="tabla">
<tr class="cabecera"><th>Login<th>Email<th>Display Name<th>Hometown<th>Hometown Name<th>Salt<th>Password</tr>
<%
 Set query = DataConnection.Execute("select * from Users")
 i=0
 while (not query.eof)
   if (i mod 2)=0 then 
      Response.Write("<tr class=""even"">")
   else
     Response.Write("<tr class=""odd"">")
   end if
   Response.Write("<td>" & query("login") & "<td>" & query("email")  &_
                  "<td>" & query("displayName") & "<td>" & query("hometown") &_
                  "<td>" & query("hometownName") &_
                  "<td>" & query("salt") &_
                  "<td>" & query("passwd") & "</tr>") 
   i=i+1
   query.moveNext
 wend
%>
</table>
<!--#include file="footer.asp"-->
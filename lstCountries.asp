<!--#include file="connectLocations.asp"-->
<%
Set query= DataConnection.Execute("Select * from Countries order by countryName;")
Response.Write("<select name=""country"" class=""search"">")
Response.Write("<option value=""XX"" selected>-- All Countries --</option>")
'Response.Write("<option value=""US"">United States</option>")
while not query.eof
  Response.Write("<option value=""" & query("countryCode") & """>" & query("countryName") & "</option>")
  query.moveNext
wend
Response.Write("</select>")
DataConnection.Close
%>
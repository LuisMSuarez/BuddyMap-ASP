<%
<!--#include file="adovbs.inc"-->
on error resume next
Set DataConnection=Server.CreateObject("ADODB.Connection")
'DataConnection.ConnectionTimeout=15
DataConnection.Open("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" &_ 
Server.Mappath("locations.mdb") & ";")

if err.number <> 0  then
  Response.Write("<p class=""error"">Could not connect to the database, please try again later</p>")
end if
on error goto 0
%>
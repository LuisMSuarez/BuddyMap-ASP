<!--#include file="connectBuddy.asp"-->
<%
on error resume next
query="update trips set description='';"

Set current= DataConnection.Execute(query)

if err.number <> 0  then
  Response.Write("<p class=""error"">Could not connect to the database, please try again later</p>")
else
  Response.Write("<p>OK</p>")
end If

DataConnection.Close

%>
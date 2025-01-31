<!--#include file="connectLocations.asp"-->
<%
theQuery="select * from Countries;"
Set query=DataConnection.Execute(theQuery)
while not query.eof
  cou=query("countryCode")
  Application("CNT." & cou)=query("countryName")
  query.moveNext
wend
query.close

theQuery="select * from Locations where ((DSG='ADM1') or (DSG='PCLS'));"
Set query=DataConnection.Execute(theQuery)
i=0
while not query.eof
  reg = query("region")
  cou = query("country")
  Application("REG." & cou & "." & reg)=query("locNameEx")
  query.moveNext
  i=i+1
wend
query.close

DataConnection.Close
Application("cache")="true"
%>
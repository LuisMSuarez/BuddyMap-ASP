<%
lang=Session("lang")
title=Application(lang & ".plot.title")
%>
<!--#include file="header.asp"-->
<!--#include file="decimalconvert.asp"-->
<%
location=Request.QueryString("loc")
if location<>"" then
%>
<!--#include file="connectLocations.asp"-->
<%
  plotCount=1
  Dim lats(1),lons(1),names(1)

  Set query= DataConnection.Execute("select * from locations where locId=" & location & ";")
  if not query.eof then
    lats(0)= decimalConvert(query("lat"))
    lons(0)= decimalConvert(query("lon"))
    names(0) = query("locNameEx")
  end if
  DataConnection.Close
end if
%>
<!--#include file="plotList.asp"-->
<!--#include file="footer.asp"-->
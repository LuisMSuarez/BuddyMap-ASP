<%
cou = Request.QueryString("cou")
title=Application("CNT." & cou)
%>
<!--#include file="header.asp"-->
<img src="maps/<%=cou%>-map.gif" border="1">
<br><br>
<img src="flags/<%=cou%>-lgflag.gif">
<br><br>

<!--#include file="footer.asp"-->
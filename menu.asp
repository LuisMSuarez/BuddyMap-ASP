<!--#include file="checksession.asp"-->
<%
title=Application(lang & ".menu.title")
%>
<!--#include file="header.asp"-->
<!--#include file="links.asp"-->
<p><%=Application(lang & ".menu.welcome")%>!</p>
<p><%=Application(lang & ".menu.1")%><%=Session("currentLocation")%><br>
<%=Application(lang & ".menu.2")%></p>
<object type="application/x-shockwave-flash" data="radar.swf" width="150" height="150" id="radar">
<param name="movie" value="radar.swf">
<p class="error">You need the Flash plugin.</p>
<p><a href="http://www.macromedia.com/go/getflashplayer/">Download Macromedia Flash Player</a></p>
</object>
<!--#include file="invitations.asp"-->
<!--#include file="footer.asp"-->
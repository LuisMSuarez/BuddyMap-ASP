<HTML>
<BODY>
<%
	For Each v in Request.ServerVariables
		Response.Write("<p><b>" & v & "</b> = ")
		Response.Write(Request.ServerVariables(v))
	Next
%>
</BODY>
</HTML>
<%
Session.Contents.RemoveAll()
Session.Abandon
Response.Redirect("logon.asp")
%>
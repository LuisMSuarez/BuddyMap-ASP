<%
  Application.Contents.RemoveAll()
  Application("cache")="false"
if not silent then
  Response.Write("cache cleared<br>")
end if
%>
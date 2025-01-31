<%
  For Each Key in Application.Contents
    Response.Write Key + " = " + Application(Key) + "<BR>"
  Next
%>
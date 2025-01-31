<%Session.CodePage = 65001 'Response.Codepage only for Windows 2003 can also use this line at top of pages: @ CODEPAGE = 65001 
Response.CharSet = "utf-8"
Response.buffer=true%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head><%=headscript%>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link rel="stylesheet" href="style.css" type="text/css">
<title><%=title%></title>
</head>
<body <%=onloadEvent%>>
<h1><%=title%></h1>
<div id="bdy">
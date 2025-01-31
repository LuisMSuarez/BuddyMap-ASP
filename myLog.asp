<!--#include file="checksession.asp"-->
<%
title=Application(lang & ".mylog.title")
onloadEvent= "onLoad=""document.logForm.log.focus();"""
activeLink="My Trips"
%>
<!--#include file="header.asp"-->
<!--#include file="links.asp"-->
<!--#include file="writeDate.asp"-->
<!--#include file="connectLog.asp"-->

<br>
<div class="tabs">
<table><tr>
<td class="linkSpc">
<td class="linkInactive"><a href="newtrip.asp"><%=Application(lang & ".newtrip.title")%></a>
<td class="linkSpc">
<td class="linkInactive"><a href="mytrips.asp"><%=Application(lang & ".mytrips.current.title")%></a>
<td class="linkSpc">
<td class="linkInactive"><a href="archive.asp"><%=Application(lang & ".mytrips.archived.title")%></a>
<td class="linkSpc">
<td class="linkActive"><%=Application(lang & ".mylog.title")%>
<td class="linkSpc">
</tr></table>
</div>
<br>

<%
theLog=Request.Form("log")
theLog=Replace(theLog,"'","''")
del=Request.QueryString("del")
modif=Request.QueryString("mod")
update=Request.Form("update")

if theLog<>"" then
  shareAll= Request.Form("shareAll")
  shareFriend= Request.Form("shareFriend")
  shareFamily= Request.Form("shareFamily")
  shareWork= Request.Form("shareWork")

  isShare=1  'we use prime numbers for the magic
  if shareAll = "on" then
    isShare=2
  end if
  if shareFriend = "on" then
    isShare=isShare*3
  end if
  if shareFamily = "on" then
    isShare=isShare*5
  end if
  if shareWork = "on" then
    isShare=isShare*7
  end if
else
  shareAll="on"
  shareFriend="on"
  shareFamily="on"
  shareWork="on"
end if

if modif<>"" then
 Set query = DataConnection.Execute("select * from Logs where (login='" & sessionLogin & "') and (entryId=" & modif & ");")
 if not query.eof then
   dbLog=query("log")
   dbShare=CInt(query("share"))
   if dbshare mod 2 <> 0 then
     shareAll="off"
   end if
   if dbshare mod 3 <> 0 then
     shareFriend="off"
   end if
   if dbshare mod 5 <> 0 then
     shareFamily="off"
   end if
   if dbshare mod 7 <> 0 then
     shareWork="off"
   end if
 else  'not found!!!???
   modif=""
 end if
end if

if update<>"" then 'first check that the id is ours
  Set query = DataConnection.Execute("select entryId from Logs where (login='" & sessionLogin & "') and (entryId=" & update & ");")
  if not query.eof then
    query.Close
    DataConnection.Execute("update Logs set log='" & theLog & "', share=" & isShare & " where (entryId=" & update & ");")
  end if
  shareAll="on"
  shareFriend="on"
  shareFamily="on"
  shareWork="on"
end if
%>

<form name="logForm" method="post" action="<%=Request.ServerVariables("SCRIPT_NAME")%>">
<table class="formulario">
<tr><td><p>
<%if modif<>"" then
    Response.Write(Application(lang & ".log.update"))
  else
    Response.Write(Application(lang & ".log.new"))
  end if
%>
</p>
<tr><td>
<textarea name="log" class="trip" wrap="soft"><%=dbLog%></textarea>
</tr>
<tr><td><%=Application(lang & ".log.sharewith")%> <input type="checkbox" name="shareAll" id="shareAll" <%if shareAll="on" then
      Response.Write("checked")    
    end if
%>><label for="shareAll"><%=Application(lang & ".share.all")%></label>
</tr>
<tr><td colspan="4">
<input type="checkbox" name="shareFriend" id="shareFriend" <%if shareFriend="on" then
      Response.Write("checked")    
    end if
%>><label for="shareFriend"><%=Application(lang & ".share.friends")%></label>
<input type="checkbox" name="shareFamily" id="shareFamily" <%if shareFamily="on" then
      Response.Write("checked")    
    end if
%>><label for="shareFamily"><%=Application(lang & ".share.family")%></label>
<input type="checkbox" name="shareWork" id="shareWork" <%if shareWork="on" then
      Response.Write("checked")    
    end if
%>><label for="shareWork"><%=Application(lang & ".share.work")%></label>
</tr>
<tr><td>
<input type="submit" value="<%=Application(lang & ".save")%>">
<input name="update" type="hidden" value="<%=modif%>">
</tr>
</table>
</form>
<%
if (theLog<>"") and (update="") then
  today=now()
  todayDate= "#" & Year(today) & "-" & Month(today) & "-" & Day(today) & "#"
  DataConnection.Execute("insert into Logs(login,logDate,tripId,locName,log,share) values ('" & sessionLogin & "'," & todayDate & ",-1,'','" & theLog & "'," & isShare & ");")
end if

if del<>"" then
  Set query = DataConnection.Execute("select * from Logs where (login='" & sessionLogin & "') and (entryId=" & del & ");")
  if not query.eof then
    DataConnection.Execute("delete from Logs where entryId=" & del & ";")
  end if
end if

Set query = DataConnection.Execute("select * from Logs where (login='" & sessionLogin & "') order by entryId asc;")

if query.eof then
  Response.Write("<p>" & Application(lang & ".log.empty") & "</p>")
else
  Response.Write("<table class=""tabla""><tr class=""cabecera""><th>" & Application(lang & ".date") & "<th>" & Application(lang & ".date") & "<th>" & Application(lang & ".delete") &"<th>" & Application(lang & ".modify") & "</tr>")  
end if

i=0
while not (query.eof)  
  if (i mod 2)=0 then 
    Response.Write("<tr class=""even"">")
  else
    Response.Write("<tr class=""odd"">")
  end if

  if query("share") then
    sharelog=true
    shparam="unshare"
  else
    sharelog=false
    shparam="share"
  end if

  Response.Write("<td>" & writeDate(query("logDate")) & "<td>" & query("log") & "<td><a href=""" & Request.ServerVariables("SCRIPT_NAME") & "?del=" & query("entryId") & """>" & Application(lang & ".delete") & "</a>" &_
                 "<td><a href=""" & Request.ServerVariables("SCRIPT_NAME") & "?mod=" & query("entryId") & """>" & Application(lang & ".modify") &"</a></tr>")
  i=i+1
  query.moveNext
wend
DataConnection.Close
Response.Write("</table>")
%>
<!--#include file="footer.asp"-->
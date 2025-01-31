<!--#include file="checksession.asp"-->
<%
title=Application(lang & ".buddytrips.title")
activeLink="Buddies"

predel=Request.QueryString("predel")
buddy=Request.QueryString("buddy")
delbuddy=Request.QueryString("del")
category=Request.Form("category")
buddyCategory=Request.Form("buddyCategory") 'hidden input field : the buddy whose category we will change
if buddy="" then 'can lose buddy (get parameter) when changing the category, we recover it this way
  buddy=buddyCategory
end if
%>
<!--#include file="header.asp"-->
<!--#include file="links.asp"-->
<!--#include file="connectBuddy.asp"-->
<!--#include file="writedate.asp"-->

<br>
<div class="tabs">
<table><tr>
<td class="linkSpc">
<td class="linkInactive"><a href="buddies.asp"><%=Application(lang & ".buddies.title")%></a>
<td class="linkSpc">
<td class=<%if predel<>"" then Response.Write("""linkInactive""><a href=""" & Request.ServerVariables("SCRIPT_NAME") & "?buddy=" & buddy & predel & """>" & Application(lang & ".buddytrips.title") & "</a>") else Response.Write("""linkActive"">" & Application(lang & ".buddytrips.title")) end if%>
<td class="linkSpc">
<td class=<%if predel="" then Response.Write("""linkInactive""><a href=""" & Request.ServerVariables("SCRIPT_NAME") & "?predel=" & buddy & """>" & Application(lang & ".delete") & "</a>") else Response.Write("""linkActive"">" & Application(lang & ".delete")) end if%>
<td class="linkSpc">
<td class="linkInactive"><a href="buddyLog.asp?buddy=<%=buddy&predel%>"><%=Application(lang & ".mylog.title")%></a>
<td class="linkSpc">
</tr></table>
</div>
<br>

<%
if predel<>"" then 'request confirmation
  Response.Write(predel & " " & Application(lang & ".buddy.delete.confirm.1") & ".<br>" & Application(lang & ".buddy.delete.confirm.2") &"<br> <a href="&""""&Request.ServerVariables("SCRIPT_NAME")&"?del=" & predel &""">" & Application(lang & ".yes") & "</a>  <a href="&""""&Request.ServerVariables("SCRIPT_NAME") & "?buddy=" & predel & """>" & Application(lang & ".cancel") & "</a>")
end if

if delbuddy <> "" then
  Set query = DataConnection.Execute("select * from Buddy where login1='" & sessionLogin & "' and login2='" & delbuddy & "';")
  if not query.eof then
    DataConnection.Execute("delete from buddy where (login1='" & sessionLogin & "' and login2='" & delbuddy & "')" &_
                           "or (login2='" & sessionLogin & "' and login1='" & delbuddy & "');")
  end if
  Response.Redirect("buddies.asp")
end if

if (category <> "") and (buddyCategory<>"") then
  Set query = DataConnection.Execute("select * from Buddy where login1='" & sessionLogin & "' and login2='" & buddyCategory & "';")
  if not query.eof then
    select case category
      case "other"  categ=2
      case "friend" categ=3
      case "family" categ=5
      case "work"   categ=7
    end select
    DataConnection.Execute("update buddy set category=" & categ & " where (login1='" & sessionLogin & "' and login2='" & buddyCategory & "');")
  end if
  buddy=buddyCategory
end if
  

if buddy<> "" then
  Set countquery = DataConnection.Execute("select count(*) as tripCount from Trips where login='" & buddy & "' and (not archived);")
  plotCount=CInt(countquery("tripCount")) 'upper bound (some trips might not be shared to me)
  countquery.close

  Dim lats(),lons(),names()
  ReDim lats(plotCount)
  ReDim lons(plotCount)
  ReDim names(plotCount)

  'check that this is a buddy for the session user and get the category
  Set query = DataConnection.Execute("select * from buddy, Users where login1='" & sessionLogin & "' and " &_
                                     "login2='" & buddy & "' and login=login2;")

  if not query.eof then
    buddyDisplayName=query("displayName")
    categ=CInt(query("category"))
    buddyHomepage=query("homepage")
    buddyPhotograph=query("photograph")
    if IsNull(buddyPhotograph) or (buddyPhotograph="") then
      buddyPhotograph="peon.png"
    end if
    query.Close    
%>
 <form name="category" method="post" action="<%=Request.ServerVariables("SCRIPT_NAME")%>">
  <table class="formulario">
        <tr><td rowspan="4"><a href="<%=buddyPhotograph%>" target="_blank"><img border="0" src="<%=buddyPhotograph%>" height="100" width="100"></a></tr>
        <tr><td><small><%=buddyDisplayName%></small></tr>
        <tr><td><small><%=Application(lang & ".category")%></small>
            <select name="category" onChange="javascript:submit();">
            <option value="other"  <%if categ="" or categ=2 then Response.Write("selected") end if%>><%=Application(lang & ".share.other")%></option>
            <option value="friend" <%if categ=3 then Response.Write("selected") end if%>><%=Application(lang & ".share.friends")%></option>
            <option value="family" <%if categ=5 then Response.Write("selected") end if%>><%=Application(lang & ".share.family")%></option>
            <option value="work"   <%if categ=7 then Response.Write("selected") end if%>><%=Application(lang & ".share.work")%></option>
            </select></tr>
        <tr><td><small><a href="<%=buddyHomepage%>" target="_blank"><%=Application(lang & ".buddy.visithomepage")%></a></small></tr>
        <tr><input name="buddyCategory" type="hidden" value="<%=buddy%>"></tr>
  </table>
  </form>
<%
   'find out the trust of my buddy to me, the trust is: (1)buddy--> (2)me in the buddy table
    Set query = DataConnection.Execute("select * from buddy where login2='" & sessionLogin & "' and " &_
                                       "login1='" & buddy & "';")
    permissions = CInt(query("category"))
    query.Close

    'now get trips and filter according to permissions
    Set query = DataConnection.Execute("select * from trips where (login='" & buddy & "') and (not archived) order by startDate asc;")
 
    i=0
    if query.eof then
      Response.Write("<p>Your buddy has no trips</p>")
    else
      Response.Write("<table class=""tabla""><tr class=""cabecera""><th>" & Application(lang & ".location") & "<th>" & Application(lang & ".start") & "<th>" & Application(lang & ".end") & "<th>" & Application(lang & ".comments") & "</tr>")
    end if
    while not query.eof
      if (CInt(query("share")) mod 2 = 0) or (CInt(query("share")) mod permissions = 0) then
        if (i mod 2)=0 then 
          Response.Write("<tr class=""even"">")
        else
          Response.Write("<tr class=""odd"">")
        end if
        locName=query("locName")
        locCountry=query("country")
        reg=Application("REG." & locCountry & "." & query("region"))
        if reg<>"" then
          locName=locName & " (" & reg & ")"
        end if
 
        Response.Write("<td>" & locName &_
                       "<td>" & writeDate(query("startDate")) &_
                       "<td>" & writeDate(query("endDate")) &_
                       "<td>" & query("description") &_                       
                       "</tr>")
        lats(i)= query("lat")
        lons(i)= query("lon")
        names(i)= query("locName")
        i=i+1
      end if
      query.moveNext
    wend
    query.Close

    DataConnection.Close
    Response.Write("</table>")
    plotCount=i
%>
<!--#include file="plotList.asp"-->
<%
  end if
end if
%>
<!--#include file="footer.asp"-->
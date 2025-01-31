<!--#include file="checksession.asp"-->
<%
title=Application(lang & ".newtrip.title")
activeLink="My Trips"
'onloadEvent= "onLoad=""if(document.forms['search']!=null) document.search.place.focus(); else if(document.forms['trip']!=null) document.trip.sd.focus();"""
%>
<!--#include file="header.asp"-->
<!--#include file="links.asp"-->
<!--#include file="date.asp"-->

<br>
<div class="tabs">
<table><tr>
<td class="linkSpc">
<td class="linkActive"><%=Application(lang & ".newtrip.title")%>
<td class="linkSpc">
<td class="linkInactive"><a href="mytrips.asp"><%=Application(lang & ".mytrips.current.title")%></a>
<td class="linkSpc">
<td class="linkInactive"><a href="archive.asp"><%=Application(lang & ".mytrips.archived.title")%></a>
<td class="linkSpc">
<td class="linkInactive"><a href="myLog.asp"><%=Application(lang & ".mylog.title")%></a>
<td class="linkSpc">
</tr></table>
</div>
<br>

<%
location = Request.QueryString("loc")
modif=Request.QueryString("mod")
commit=Request.QueryString("commit")
locName=Session("locName")
shareAll="on"
shareFriend="on"
shareFamily="on"
shareWork="on"

if (modif <> "") and (commit <> "true") then 'get trip info from db else from form
%>
<!--#include file="connectBuddy.asp"-->
<%
  Set query = DataConnection.Execute("select * from Trips where tripID=" & modif & " and login='" & sessionLogin & "';" )   
  if not query.eof then    
    dbshare=CInt(query("share"))
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
    theStart=query("startDate")
    theEnd=query("endDate")
    locName = query("locName")
    description = query("description")
    sd = DatePart("d",theStart)
    sm = DatePart("m",theStart)
    sy= DatePart("yyyy",theStart)
    ed = DatePart("d",theEnd)
    em = DatePart("m",theEnd)
    ey= DatePart("yyyy",theEnd)    
    Session("locName") = locName  'used in case the dates are invalid
    Session("lat")=decimalConvert(query("lat"))
    Session("lon")=decimalConvert(query("lon"))
  else
    DataConnection.Close
    Response.redirect("mytrips.asp")    
  end if
  DataConnection.Close
else    'get trip info from form
  if location = "" then 'the default value of isshare is "on", we don't want to lose it unless we have to
    shareAll= Request.Form("shareAll")
    shareFriend= Request.Form("shareFriend")
    shareFamily= Request.Form("shareFamily")
    shareWork= Request.Form("shareWork")
  end if

  sd= Request.Form("sd")
  sm= Request.Form("sm")
  sy= Request.Form("sy")
  ed= Request.Form("ed")
  em= Request.Form("em")
  ey= Request.Form("ey")
  description= Request.Form("description")
end if

if commit = "true" then
  if validDate(sd,sm,sy) and validDate(ed,em,ey) and greater(sd,sm,sy,ed,em,ey) then
%>
<!--#include file="connectBuddy.asp"-->
<%
    isShare=1  'we use prime numbers for the magic
    if Request.Form("shareAll") = "on" then
      isShare=2
    end if
    if Request.Form("shareFriend") = "on" then
      isShare=isShare*3
    end if
    if Request.Form("shareFamily") = "on" then
      isShare=isShare*5
    end if
    if Request.Form("shareWork") = "on" then
      isShare=isShare*7
    end if
    description=replace(description,"'","''")

    DataConnection.Execute("update Trips set startDate=#" & sy & "-" & sm & "-" & sd & "#," &_
                           "endDate=#" & ey & "-" & em & "-" & ed & "#," &_
                           "share=" & isShare & ", description='" & description & "' where tripId=" & modif & ";")     
    DataConnection.Close    
    Session.Contents.Remove("locName")
    Response.redirect("mytrips.asp")
  else 
    Response.Write("<p class=""error"">" & Application(lang & ".form.baddata") & "</p>")
  end if
end if

searchDlg=true
if (location <> "") or (modif <> "") or (sd <>"") then ' date picker form, but first get info of the town from DB using the location variable
  searchDlg=false  ' dont want the location search dialog
  if (modif="") and (location <> "") then 'not modifying, this is a new trip or a correction to an invalid date
%>
<!--#include file="connectLocations.asp"-->
<!--#include file="decimalConvert.asp"-->
<%
    Session("location")= location
    Set query = DataConnection.Execute("select * from Locations where locID=" & location & ";" )   
    if (not query.eof) then
      locName=query("locNameEx")
      cou = query("country")
      reg = query("region")       

      Session("locName") = locName
      Session("country") = cou
      Session("region") = reg
      Session("lat")= decimalConvert(query("lat"))
      Session("lon")= decimalConvert(query("lon"))
      DataConnection.Close
    else
      DataConnection.Close
      Response.Redirect("mytrips.asp")
    end if  
  end if
  Response.Write("<p><small>" & Application(lang & ".newtrip.1") & "<i>" & locName & "</i>" & Application(lang & ".newtrip.2") & "<br>") 
  if modif<>"" then
    Response.Write("<a href=""mytrips.asp"">" & Application(lang & ".cancel") & "</a></small></p>")
  else
    Response.Write("<a href=""" & Request.ServerVariables("SCRIPT_NAME") & """>Cancel</a></small></p>")
  end if  
%>


<form name="trip" method="post" action="<%=Request.ServerVariables("SCRIPT_NAME")%><%if modif <> "" then
  Response.Write("?mod=" & modif & "&commit=true")
 end if %>">
<table class="formulario">
<tr><th valign="bottom"><%=Application(lang & ".start")%><td><%=Application(lang & ".day")%> <input type="text" name="sd" size="2" maxlength="2" value="<%=sd%>" class="date">
<td><%=Application(lang & ".month")%> <input type="text" name="sm" size="2" maxlength="2" value="<%=sm%>" class="date">
<td><%=Application(lang & ".year")%> <input type="text" name="sy" size="4" maxlength="4" value="<%=sy%>" class="date"></tr>

<tr><th valign="bottom"><%=Application(lang & ".end")%><td><%=Application(lang & ".day")%> <input type="text" name="ed" size="2" maxlength="2" value="<%=ed%>" class="date">
<td><%=Application(lang & ".month")%> <input type="text" name="em" size="2" maxlength="2" value="<%=em%>" class="date">
<td><%=Application(lang & ".year")%> <input type="text" name="ey" size="4" maxlength="4" value="<%=ey%>" class="date"></tr>
<tr><td colspan="4"><%=Application(lang & ".newtrip.sharewith")%> <input type="checkbox" name="shareAll" id="shareAll" <%if shareAll="on" then
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
<tr><td colspan="4"><textarea name="description" class="trip" wrap="soft">
<%
if len(description)>0 then
  Response.Write(description)
else
  Response.Write(Application(lang & ".newtrip.description"))
end if%></textarea></tr>
<tr><td colspan="4"><input type="submit" value="<%=Application(lang & ".save")%>"></tr>
</table><br>
</form>
<% 
end if 
if (sd<>"") and (modif="") then
    if validDate(sd,sm,sy) and validDate(ed,em,ey) and greater(sd,sm,sy,ed,em,ey) then
%>
<!--#include file="connectBuddy.asp"-->
<%
      startdate = sy & "-" & sm & "-" & sd
      enddate = ey & "-" & em & "-" & ed
      ' now check overlapping
      overlaps=false
      'if allowoverlap<>"true" then
      '  que = "select * from Trips where login='" & sessionLogin & "' " & "and (#" & enddate & "#> start) and (end>#" & startdate & "#);"
      '  'Response.Write(que)
      '  Set query = DataConnection.Execute(que)
      '  if not (query.eof) then 
      '    overlaps=true   
      '    'Response.Write("kk")    
      '    Response.Write("<p>This trip overlaps with another trip of yours to <i>" & query("locName") & "</i> <a href=""" & Request.ServerVariables("SCRIPT_NAME") & "?allowoverlap=true&loc=" & Session("location") & """>That's OK</a></p>")
      '    DataConnection.Close
      '  end if
      'end if
      description=replace(description,"'","''")
      if not overlaps then      
        que = "insert into Trips (login, share, locId, locName, startDate,endDate, country, region, lat, lon, archived, description) values ('" & sessionLogin & "',"

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
       que = que & isShare & "," & Session("location") & ",'" & Session("locName") & "','" & startdate & "','" & _
                   enddate & "','" & Session("country") & "','" & Session("region") & "'," & Session("lat") & "," & Session("lon") & ",False,'" & description & "');"
    
        'Response.Write("hola" & que)
        Set query = DataConnection.Execute(que)
        DataConnection.Close
        Session.Contents.Remove("locName")
        Session.Contents.Remove("location")
        Session.Contents.Remove("country")
        Session.Contents.Remove("lat")
        Session.Contents.Remove("lon")
        Response.redirect("mytrips.asp")
      end if
    else
      Response.Write("<p class=""error"">" & Application(lang & ".form.baddata") & "</p>")
    end if
  end if
'end if  

if searchDlg=true then  'dont show search box if modifying
%>
<!--#include file="search.asp"-->
<% end if %>
<!--#include file="footer.asp"-->
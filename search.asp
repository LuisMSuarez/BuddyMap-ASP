<%
place = replace(Request.Form("place"),"'","''")
searchType= Request.Form("search")
country = replace(Request.Form("country"),"'","''")

''' check to see if the location has extended characters, to search in locName OR locNameEx
dim objRegX
set objRegX = new RegExp
objRegX.IgnoreCase=true
objRegX.Pattern = "[A-Z|\s|0-9]{" & len(place) & "}"

if objRegX.Test(place) then
  searchFld = "locName"
else
  searchFld = "locNameEx"
end if

objRegX=Null

if place <>"" then 

theQuery="select top 50 * from Locations where "
' this query is too expensive, and doesn't work as I expect it to
'theQuery="select distinct ufi, * from Locations, Countries where " 

if country <> "XX" then
  theQuery= theQuery & "(country='" & country & "') and "
end if

if searchType="equals" then
  theQuery= theQuery & "(" & searchFld & "='" & place & "');"
else
  if searchType="starts" then
    theQuery= theQuery & "(" & searchFld & " like '" & place & "%');"
  else 'contains
    theQuery= theQuery & "(" & searchFld & " like '%" & place & "%');"
  end if
end if

'response.write(thequery)
%>
<!--#include file="connectLocations.asp"-->
<%
'DataConnection.CommandTimeout = 10
'Server.ScriptTimeout=10
t1=timer()
Set query = DataConnection.Execute(theQuery)

'back from search
if not Response.IsClientConnected then
  Response.End
  Session.Contents.RemoveAll()
  Session.Abandon
end if


i=0
ufi=0 'store the last feature identifier to avoid immediate duplicates
maxSearchSize=50

Dim lats(),lons(),names(),countries
ReDim lats(maxSearchSize)
ReDim lons(maxSearchSize)
ReDim names(maxSearchSize)

if query.eof then
  Response.Write("<p>" & Application(lang & ".search.empty") & "</p>")
else
  Response.Write("<table class=""tabla""><tr class=""cabecera""><th><th>" & Application(lang & ".country") & "<th>" & Application(lang & ".region") & "<th>" & Application(lang & ".location") & "<th>" & Application(lang & ".select") &"</tr>")
end if

while (not query.eof) and (i<maxSearchSize)
  newufi = query("ufi")
  dsg = query("DSG")
  if (newufi<>ufi) then 'and (dsg<>"ADM1") and (dsg<>"ADM2") and (dsg<>"ADM3") and (dsg<>"ADM4") then 'keep ADMD !
    ufi=newufi
    locName=query("locNameEx")  
    if (dsg="ADM1") or (dsg="ADM2") or (dsg="ADM3") or (dsg="ADM4") or (dsg="PCLI") then
      locName=locName & " (center)"
    end if
    reg= query("region")
    cou= query("country")
    region="" ' zero-out to not use last looped value
    'get regional and country info. getting the country here boosts performance, as it is not in the main search query (not joining tables) we also cache old values using a dictionary, great idea!
    
    if (Application("cache")<>"true") and (Application("CNT." & cou)="") then
      newquery="select * from Countries where countryCode='" & cou & "';"
      Set coquery = DataConnection.Execute(newquery)      
      country = coquery("countryName")     
      coquery.close
      Application("CNT." & cou)=country
    else
      country=Application("CNT." & cou)
    end if
    if dsg="PPLC" then
      country = country & "*" 
    end if   
 
    if (Application("cache")<>"true") and (Application("REG." & cou & "." & reg)="") then
      newquery= "select * from Locations where (country='" & query("country") & "') and (region='" & reg & "') and ((DSG='ADM1') or (DSG='PCLS'));"
      Set regquery = DataConnection.Execute(newquery)
      if not regquery.eof then
        region=regquery("locNameEx")
      else
        region=" " 'if left totally blank it is not assigned to the Application variable!!!
      end if
      regquery.close
      Application("REG." & cou & "." & reg)=region
    else
      region= Application("REG." & cou & "." & reg)
    end if

    names(i)=locName 
    if region<>"" then
      names(i)= names(i) & " (" & region & ") " 
    end if
    names(i)= names(i)  & " (" & country & ")"
    lats(i)=query("lat")
    lons(i)=query("lon")

    if (i mod 2)=0 then 
      Response.Write("<tr class=""even"">")
    else
      Response.Write("<tr class=""odd"">")
    end if 
    Response.Write("<td><img src=""flags/" & cou & "-flag.gif"" height=""17"" width=""25""><td><a href=""country.asp?cou=" & cou & """ target=""_blank"">" & country & "</a>" &_
                   "<td>" & region &_  
                   "<td><a href=""plot.asp?loc=" & query("locId") & """ target=""_blank"">" & locName & "</a>" &_
                   "<td><a href=""" & Request.ServerVariables("SCRIPT_NAME") & "?loc=" & query("locId") & _
                   """>" & Application(lang & ".select") & "</a></tr>")
    i=i+1
  end if 'newufi<>ufi
  query.moveNext  
wend
query.close
DataConnection.Close
Response.Write("</table><br>")
t2=timer()
Response.Write ("<p><small>" & Application(lang & ".search.took") & " " & FormatNumber(CSng(t2-t1),2) & " " & Application(lang & ".seconds") & "</small></p>")

if(i>=maxSearchSize) then
  Response.Write("<p class=""error"">" & Application(lang & ".search.filtered") & "</p>")
end if

'Response.Write("<p><small>Not found your location? <a href=""srchhlp.asp"" target=""_blank"">Click here for help</a></small></p>")
plotCount=i
%>
<!--#include file="plotList.asp"-->
<%
end if 'place <>""
Response.Flush 'flush the search results and now write the search form
%>
<br><br>
<form name="search" method="post" action="<%=Request.ServerVariables("SCRIPT_NAME")%>">
<table class="formulario"><tr><td colspan="2"><i><%=Application(lang & ".search.title")%></i></tr>
<tr><td colspan="2">
<input name="search" type="radio" value="equals" id="equals" checked><label for="equals"><%=Application(lang & ".search.equals")%></label>
<input name="search" type="radio" value="starts" id="starts"><label for="starts"><%=Application(lang & ".search.startswith")%></label>
<input name="search" type="radio" value="contains" id="contains"><label for="contains"><%=Application(lang & ".search.contains")%></label>
</tr>
<tr><td><input type="text" name="place" size="30" value="<%=place%>" class="search"></tr>
<tr><td>
<!--#include file="countries.asp"-->
</tr>
<tr><td><input type="submit" value="<%=Application(lang & ".search")%>" name="bsrch"></tr>
</table>
</form>
<%
function writeDate(date)
  if (year(date)>1000) and (year(date)<9999) then
    writeDate=day(date) & "-" & Application(lang & ".month." & month(date)) & "-" & year(date)
  else
    writeDate="--"
  end if
end function
%>
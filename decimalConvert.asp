<%
function decimalConvert(dec)
  res=""
  l = len(dec)
  for i=1 to l
    if mid(dec,i,1)="," then
      res=res & "."
    else
      res=res & mid(dec,i,1)
    end if
  next
  decimalConvert=res
end function
%>
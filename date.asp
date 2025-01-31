<%
function leapYear(year)
  year = CInt(year)
  leapYear = ((year mod 4 = 0) and (year mod 100 <> 0) or (year mod 400 = 0))
end function

function validDate(day,month,year)
  if(not IsNumeric(day)) or (not IsNumeric(month) ) or (not IsNumeric(year)) then
    validDate=false
    exit function
  end if

  day = CInt(day)
  month = CInt(month)
  year = CInt(year)
  if (not isnumeric(day)) or (not isnumeric(month)) or (not isnumeric(year)) then
    validDate=false
  else
    dd= Int(day)
    mm= Int(month)
    yy= Int(year)  
    valid = (dd>0) and (dd < 32) and (mm > 0) and (mm < 13) and (yy > 1000) and (yy < 4000)
    if not valid then
      validDate=false
    else
      select case mm
        case 1,3,5,7,8,10,12 valid = (dd<=31)
        case 4,6,9,11 valid = (dd<=30)
        case 2 if leapYear(year) then
                 valid = (dd<30)
               else
                 valid = (dd<29)
               end if
      end select
      validDate=valid
    end if
  end if
end function

function greater(sd,sm,sy,ed,em,ey)
  if(not IsNumeric(sd)) or (not IsNumeric(sm) ) or (not IsNumeric(sy)) or (not IsNumeric(ed)) or (not IsNumeric(em) ) or (not IsNumeric(ey))then
    greater=false
    exit function
  end if

  sd = CInt(sd)
  sm = CInt(sm)
  sy = Cint(sy)
  ed = CInt(ed)
  em = CInt(em)
  ey = Cint(ey)
  if sy > ey then
    greater=false
  else
    if sy < ey then
      greater=true
    else ' same year
      if sm > em then 
        greater=false
      else
        if sm < em then
          greater=true
        else 'same month and year
          greater= (sd<=ed)
        end if
      end if
    end if
  end if
end function
%>
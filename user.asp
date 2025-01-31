<form name="user" method="post" action="<%=Request.ServerVariables("SCRIPT_NAME")%>">
<table class="formulario">
<tr><td><%=Application(lang & ".username")%><td><input type="text" name="login" size="30" value="<%=login%>" class="profile" <%if loginDisabled then
 Response.Write("disabled")
end if%>></tr>
<tr><td><%=Application(lang & ".email")%><td><input type="text" name="email" size="30" value="<%=email%>" class="profile"></tr>
<tr><td><%=Application(lang & ".display")%><td><input type="text" name="displayName" size="30" value="<%=displayName%>" class="profile"></tr>
<tr><td><%=Application(lang & ".password")%><td><input type="password" name="password" size="30" value="<%=password%>" class="profile" <%if passwordDisabled then
 Response.Write("disabled")
end if%>></tr>
<tr><td><%=Application(lang & ".homepg")%><td><input type="text" name="homepage" size="30" value="<%=homepage%>" class="profile"></tr>
<tr><td><%=Application(lang & ".photo")%><td><input type="text" name="photograph" size="30" value="<%=photograph%>" class="profile"></tr>
<tr><td><%=Application(lang & ".distances")%><td>
<input name="unit" type="radio" value="km" id="km" <%if unit="km" then Response.Write("checked") end if%>><label for="km"><%=Application(lang & ".km")%></label>
<input name="unit" type="radio" value="mi" id="mi" <%if unit="mi" then Response.Write("checked") end if%>><label for="mi"><%=Application(lang & ".mi")%></label>
<tr><td colspan="2"><input type="submit" value="<%=buttonCaption%>"></tr>
</table>
</form>
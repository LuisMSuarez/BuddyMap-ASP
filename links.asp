<div class="tabs">
<table>
<tr>
<td class="linkSpc">
<td class=<%if activeLink="My Trips" then Response.Write("""linkActive"">" & Application(lang & ".links.trips")) else Response.Write("""linkInactive""><a href=""mytrips.asp"">" & Application(lang & ".links.trips") & "</a>") end if%>
<td class="linkSpc">
<td class=<%if activeLink="Buddies" then Response.Write("""linkActive"">" & Application(lang & ".links.buddies")) else Response.Write("""linkInactive""><a href=""buddies.asp"">" & Application(lang & ".links.buddies") & "</a>") end if%>
<td class="linkSpc">
<td class=<%if activeLink="Distance" then Response.Write("""linkActive"">" & Application(lang & ".links.distance")) else Response.Write("""linkInactive""><a href=""dist.asp"">" & Application(lang & ".links.distance") & "</a>") end if%>
<td class="linkSpc">
<td class=<%if activeLink="Profile" then Response.Write("""linkActive"">" & Application(lang & ".links.profile")) else Response.Write("""linkInactive""><a href=""profile.asp"">" & Application(lang & ".links.profile") & "</a>") end if%>
<td class="linkSpc">
<td class=<%if activeLink="Disconnect" then Response.Write("""linkActive"">" & Application(lang & ".links.disconnect")) else Response.Write("""linkInactive""><a href=""disc.asp"">" & Application(lang & ".links.disconnect") & "</a>") end if%>
<td class="linkSpc">
</tr>
</table>
</div>
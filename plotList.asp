<!--#include file="decimalConvert.asp"-->
<br>
<applet code="Plotter" name="Plotter" width="800" height="420">
<param name="cache_option" VALUE="plugin">
<param name="cache_archive" VALUE="Plotter.jar,PlotterData.jar, PlotterMaps.jar, PlotterFlags.jar">
<param name="cache_version" VALUE="1.0.1.0, 1.0.0.0, 1.0.0.0, 1.0.0.0">
<param name=capLabels value="<%=Application(lang & ".plotter.capLabels")%>">
<param name=capConnect value="<%=Application(lang & ".plotter.capConnect")%>">
<param name=capBoundaries value="<%=Application(lang & ".plotter.capBoundaries")%>">
<param name=capCountries value="<%=Application(lang & ".plotter.capCountries")%>">
<param name=capFlags value="<%=Application(lang & ".plotter.capFlags")%>">
<param name=points value="<%=plotCount%>">
<%
for ii=0 to plotCount-1
  Response.Write("<param name=name" & ii+1 & " value=""" & names(ii) & """>")
  Response.Write("<param name=lat" & ii+1 & " value=""" & decimalConvert(lats(ii)) & """>")
  Response.Write("<param name=lon" & ii+1 & " value=""" & decimalConvert(lons(ii)) & """>")
next
%>
<p class="error">You need the Java applet plugin</p>
<p><a href="http://www.java.com">Download Java</a></p>
<img src="plotterunavail.jpg" onclick="alert('To activate, download Java at www.java.com')">
</applet>
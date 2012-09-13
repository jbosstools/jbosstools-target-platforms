<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	version="2.0">

	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	<xsl:param name="destinationUrl"/>

	<xsl:template match="target">
		<target includeMode="feature" name="e42-wtp34-jbds6">
			<locations>
				<location includeAllPlatforms="false" includeMode="planner" type="InstallableUnit" includeSource="true">
					<repository location="{$destinationUrl}"/>
					<xsl:apply-templates select="//unit" />
				</location>
			</locations>
			<targetJRE path="org.eclipse.jdt.launching.JRE_CONTAINER/org.eclipse.jdt.internal.debug.ui.launcher.StandardVMType/JavaSE-1.6"/>
		</target>
	</xsl:template>
	
	<xsl:template match="//unit">
		<xsl:copy-of select="."/>
	</xsl:template>
</xsl:stylesheet>

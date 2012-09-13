<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<!-- 
	This XSLT is used by targetUpdateFromRepo.xml to update the versions on IUs in a .target file
	CAUTION: do not auto-format this file or line breaks will appear where they should not be!
-->
<xsl:output method="text" indent="no" encoding="UTF-8" version="1.0" />
<xsl:template match="repository">
<xsl:apply-templates select="//unit" />
</xsl:template>
<xsl:template match="/"><xsl:for-each select="//unit">
<xsl:sort select="@id" order="ascending" case-order="lower-first"/><xsl:sort select="@version" order="descending" case-order="lower-first" data-type="qname"/><xsl:value-of select="@id" />.version=<xsl:value-of select="@version" />
<xsl:variable name="thisID" select="@id"/>
<xsl:if test="count(//unit[@id = $thisID]) &gt; 1">
# Warning: <xsl:value-of select="count(//unit[@id = $thisID])"/> versions found for <xsl:value-of select="@id" />:<xsl:for-each select="//unit[@id = $thisID]"><xsl:sort select="@id" order="ascending" case-order="lower-first"/><xsl:sort select="@version" order="descending" case-order="lower-first" data-type="qname"/>
# <xsl:value-of select="@id" />.version=<xsl:value-of select="@version" /></xsl:for-each></xsl:if>
#
</xsl:for-each></xsl:template>
</xsl:stylesheet>

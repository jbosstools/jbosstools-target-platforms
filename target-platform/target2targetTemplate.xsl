<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<!-- 
	This XSLT is used by targetUpdateFromRepo.xml to update the versions on IUs in a .target file
	CAUTION: do not auto-format this file or line breaks will appear where they should not be!
-->

<xsl:param name="replacement.URL"/>
<xsl:param name="replace.versions"/>

<!-- Copy unit nodes and optionally (if we ran contentXml2artifactVersions.xsl transform and have artifactVersions.properties file) templatize their version attributes -->
<xsl:template match="unit">
<xsl:choose>
<xsl:when test="$replace.versions">

<xsl:variable name="prevID"><xsl:value-of select="preceding-sibling::* [1]/@id" /></xsl:variable> <!-- <prevID><xsl:value-of select="$prevID"/></prevID> -->
<xsl:variable name="thisID"><xsl:value-of select="@id" /></xsl:variable> <!-- <thisID><xsl:value-of select="$thisID"/></thisID> -->
<xsl:variable name="nextID"><xsl:value-of select="following-sibling::* [1]/@id" /></xsl:variable> <!-- <nextID><xsl:value-of select="$nextID"/></nextID> -->

<!-- if there is more than one node matching <unit id="some.id"/> then DO NOT REPLACE the version -->
<xsl:choose>
	<xsl:when test="contains ($thisID, $nextID) or contains ($thisID, $prevID)">
		<!-- <xsl:comment> Note multiple versions of this IU; cannot update automatically. </xsl:comment> -->
		<unit id="{@id}" version="{@version}"><xsl:apply-templates/></unit>
	</xsl:when>
	<xsl:otherwise>
		<unit id="{@id}" version="${{{@id}.version}}"><xsl:apply-templates/></unit>
	</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates/>
</xsl:when>
<xsl:otherwise>
<unit id="{@id}" version="{@version}"><xsl:apply-templates/></unit>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- Copy repository nodes and optionally replace their location attributes (if replacement.URL is set) -->
<xsl:template match="repository">
<xsl:choose>
<xsl:when test="$replacement.URL">
<repository location="{$replacement.URL}">
<xsl:apply-templates/>
</repository>
</xsl:when>
<xsl:otherwise>
<repository location="{@location}">
<xsl:apply-templates/>
</repository>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- Copy everything else unchanged -->
<xsl:template match="@*|node()">
<xsl:copy>
<xsl:apply-templates select="@*|node()"/>
</xsl:copy>
</xsl:template>

</xsl:stylesheet>


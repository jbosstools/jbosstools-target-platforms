<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<!-- 
	This XSLT is used by targetUpdateFromRepo.xml to update the versions on IUs in a .target file
	CAUTION: do not auto-format this file or line breaks will appear where they should not be!
-->

<!-- Copy unit nodes and templatize their version attributes -->
<xsl:template match="unit">
<unit id="{@id}" version="${{{@id}.version}}">
<xsl:apply-templates/>
</unit>
</xsl:template>

<!-- Copy everything else unchanged -->
<xsl:template match="@*|node()">
<xsl:copy>
<xsl:apply-templates select="@*|node()"/>
</xsl:copy>
</xsl:template>

</xsl:stylesheet>
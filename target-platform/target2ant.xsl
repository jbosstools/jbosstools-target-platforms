<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">
	<xsl:output method="xml" indent="yes" encoding="UTF-8"
		version="1.0" />
	<xsl:decimal-format decimal-separator="."
		grouping-separator="," />

	<xsl:param name="verbose" select="'${verbose}'" />
	<xsl:param name="followStrict" select="'${followStrict}'" />
	<xsl:param name="destination" select="'file:${repo.dir}'" />

	<xsl:variable name="platformFilter"
		select="concat(/target/environment/os/text(), ',', /target/environment/ws/text(), ',', /target/environment/arch/text())" />

	<xsl:template match="target">
		<project name="Download target platform" default="download.target.platform">
			<target name="help">
				<echo>
					Use followStrict="true" to prevent downloading all
					requirements not included in the target platform
					or
					followStrict="false" to fetch everything

					To run this script:

					./eclipse -vm /opt/jdk1.6.0/bin/java -nosplash
					-data \
					/tmp/workspace -consolelog -application \
					org.eclipse.ant.core.antRunner -f out.xml \
					-Ddebug=true \
					-DfollowStrict=false \
					-Drepo.dir=/tmp/REPO/
</echo>
			</target>
			<target name="init" unless="repo.dir">
				<fail>Must set -Drepo.dir=/path/to/download/artifacts/</fail>
			</target>
			<target name="download.target.platform" depends="init"
				description="Download from target platform definition" if="repo.dir">
				<property name="verbose" value="false" />
				<property name="followStrict" value="false" />
				<echo level="info">Download features/plugins into ${repo.dir}</echo>
				<p2.mirror destination="{$destination}" verbose="{$verbose}">
					<slicingOptions includeFeatures="true" followStrict="{$followStrict}" />
					<source>
						<xsl:apply-templates select="//repository" />
					</source>
					<xsl:apply-templates select="//unit" />
					<xsl:apply-templates select="//feature" />
					<xsl:apply-templates select="//plugin" />
				</p2.mirror>
			</target>
		</project>
	</xsl:template>

	<xsl:template match="//repository">
		<xsl:variable name="locationUrl" select="./@location" />
		<repository location="{$locationUrl}" />
	</xsl:template>

	<xsl:template match="//unit">
		<iu id="{@id}" version="{@version}" />
	</xsl:template>

	<xsl:template match="//plugin">
		<iu id="{@id}" version="" />
	</xsl:template>

	<xsl:template match="//feature">
		<iu id="{@id}.feature.group" version="" />
	</xsl:template>

	<!-- ignore anything else -->
	<xsl:template match="environment|targetJRE|launcherArgs|includeBundles" />

</xsl:stylesheet>
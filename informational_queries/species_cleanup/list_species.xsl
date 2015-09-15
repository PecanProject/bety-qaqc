<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text"/>

  <xsl:template match="/">
    <xsl:text>/* Run this script after doing the deletions and consolidations to ensure at least one row from each species group remains. */&#xA;</xsl:text>
    <xsl:variable name="species_list">
      <xsl:for-each select="table/row">
        <xsl:if test="not(scientificname = preceding-sibling::*/scientificname)">
          <xsl:if test="position() != 1">, </xsl:if><xsl:text>'</xsl:text><xsl:value-of select="scientificname"/><xsl:text>'</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:text>SELECT ARRAY_LENGTH(ARRAY[</xsl:text><xsl:value-of select="$species_list"/><xsl:text>], 1) AS "number of groups we started with", COUNT(DISTINCT scientificname) AS "number of groups still represented", (COUNT(scientificname) - COUNT(DISTINCT scientificname)) AS "number of extraneous rows" FROM species WHERE scientificname IN (</xsl:text><xsl:value-of select="$species_list"/><xsl:text>);&#xA;</xsl:text>
  </xsl:template>
  
</xsl:stylesheet>

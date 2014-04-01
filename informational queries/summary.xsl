<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html" doctype-public="-//W3C//DTD HTML 4.01//EN"/>

  <xsl:param name="lastrow" select="1000"/>
  
  <xsl:variable name="columns" select="document('species_columns.xml')//column-names/*"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="RECORDS">
    <html>
      <head>
        <title></title>
        <style>.green { background-color: lightgreen }
        .pink { background-color: pink }
        .blue { background-color: lightblue }</style>
      </head>
      <body>
        <h1>Duplicate Species</h1>
        <h2>Key</h2>
        <table>
          <tr><td class="green" style="width: 20px">&#160;</td><td>Column value matches all other rows in the same group</td></tr>
          <tr><td class="blue" style="width: 20px">&#160;</td><td>Column value matches at least one other row in the same group</td></tr>
          <tr><td class="pink">&#160;</td><td>Column value differs from that of all other rows in the same group</td></tr>
        </table>
        <table>
          <thead>
            <xsl:for-each select="$columns">
              <th><xsl:value-of select="local-name(.)"/></th>
            </xsl:for-each>
          </thead>
          <tbody>
            <xsl:apply-templates select="RECORD[position() &lt;= $lastrow]"/>
          </tbody>
        </table>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="RECORD">
    <xsl:variable name="record" select="."/>
    <xsl:variable name="matches" select="../RECORD[scientificname = current()/scientificname and generate-id(.) != generate-id(current())]"/>
    <tr>
      <td><xsl:value-of select="id"/></td>
      <xsl:for-each select="$columns[position() > 1]">
        <td>
          <xsl:attribute name="class">
            <xsl:if test="current()[@compare &gt; 0] and $record/*[local-name(.) = local-name(current())]">
              <xsl:choose>
                <xsl:when test="not($record/*[local-name(.) = local-name(current())] != $matches/*[local-name(.) = local-name(current())])">
                  green
                </xsl:when>
                <xsl:when test="$record/*[local-name(.) = local-name(current())] = $matches/*[local-name(.) = local-name(current())]">
                  blue
                </xsl:when>
                <xsl:otherwise>
                  pink
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
          </xsl:attribute>
          <xsl:value-of select="$record/*[local-name(.) = local-name(current())]"/>
        </td>
      </xsl:for-each>
    </tr>
    <xsl:if test="not(./following-sibling::RECORD = $matches)">
      <tr><td style="background-color: blue" colspan="{count($columns)}">   </td></tr>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>

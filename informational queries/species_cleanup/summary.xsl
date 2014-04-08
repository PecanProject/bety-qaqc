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
        <style>
          .red { background-color: red }
          .gray { background-color: gray }
          .orange { background-color: orange }
          .green { background-color: lightgreen }
          .pink { background-color: pink }
          .blue { background-color: lightblue }
        </style>
      </head>
      <body>
        <h1>Duplicate Species</h1>
        <h2>Key</h2>
        <table>
          <tr><td class="red" style="width: 20px">&#160;</td><td>Row can be removed: no references</td></tr>
          <tr><td class="gray" style="width: 20px">&#160;</td><td>Column value is NULL</td></tr>
          <tr><td class="orange" style="width: 20px">&#160;</td><td>Column value need whitespace normalization</td></tr>
          <tr><td class="green" style="width: 20px">&#160;</td><td>Column value matches all other rows in the same group</td></tr>
          <tr><td class="blue" style="width: 20px">&#160;</td><td>Column value matches at least one other row in the same group</td></tr>
          <tr><td class="pink">&#160;</td><td>Column value differs from that of all other rows in the same group</td></tr>
        </table>
        <table>
          <xsl:call-template name="table_heading"/>
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
      <td>
        <xsl:attribute name="class">
          <xsl:if test="./linked_yields = '' and ./linked_traits = '' and ./linked_cultivars = '' and not(./linked_pfts)">
            red
          </xsl:if>
        </xsl:attribute>
        <xsl:value-of select="id"/>
      </td>
      <xsl:for-each select="$columns[position() > 1]">
        <xsl:variable name="column_value" select="$record/*[local-name(.) = local-name(current())]"/>
        <xsl:variable name="column_values_of_matching_rows" select="$matches/*[local-name(.) = local-name(current())]"/>
        <td>
          <xsl:attribute name="class">
            <xsl:if test="current()[@compare &gt; 0]">
              <xsl:choose>
                <xsl:when test="count($column_value) = 0"><!-- value is NULL (no column in XML) -->
                  gray
                </xsl:when>
                <xsl:when test="$column_value != normalize-space($column_value)"><!-- space in value is not normalized -->
                  orange
                </xsl:when>
                <xsl:when test="not($column_value != $column_values_of_matching_rows) and count($matches) = count($column_values_of_matching_rows)"><!-- every other row in the group has the same (non NULL) column value -->
                  green
                </xsl:when>
                <xsl:when test="$column_value = $column_values_of_matching_rows"><!-- some other row in the same group has the same column value -->
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
      <xsl:if test="count(./preceding-sibling::RECORD[scientificname != preceding-sibling::RECORD/scientificname] ) mod 5 = 0"><!-- This test isn't quite right but it's good enough for now. -->
        <xsl:call-template name="table_heading"/>
        <tr><td style="background-color: blue" colspan="{count($columns)}">   </td></tr>
      </xsl:if>
    </xsl:if>
  </xsl:template>


  <xsl:template name="table_heading">
    <thead>
      <xsl:for-each select="$columns">
        <th><xsl:value-of select="local-name(.)"/></th>
      </xsl:for-each>
    </thead>
  </xsl:template>
  
</xsl:stylesheet>
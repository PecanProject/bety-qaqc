<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html" doctype-public="-//W3C//DTD HTML 4.01//EN"/>

  <xsl:param name="lastrow" select="1000"/>

  <xsl:param name="mode" select="delete"/>
  
  <xsl:variable name="columns" select="document('species_columns.xml')//column-names/*"/>

  <xsl:template match="/">
    <xsl:if test="$mode != 'delete' and $mode != 'consolidate'">
      <xsl:message terminate='yes'>Unrecognized mode.  Mode must be 'delete' or 'consolidate'.</xsl:message>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="table">
    <html>
      <head>
        <title></title>
        <style>
          .red { background-color: red }
          .orange { background-color: orange }
          .green { background-color: darkgreen }
          .gray { background-color: gray }
          .violet { background-color: violet }
          .green { background-color: lightgreen }
          .pink { background-color: pink }
          .blue { background-color: lightblue }
        </style>
      </head>
      <body>
        <h1>Duplicate Species</h1>
        <h2>Key</h2>
        <table>
          <tr><td class="red" style="width: 20px">&#160;</td><td>Row can be removed: no unique references</td></tr>
          <tr><td class="orange" style="width: 20px">&#160;</td><td>Row can be removed after copying some information</td></tr>
          <tr><td class="green" style="width: 20px">&#160;</td><td>Row can act as group representitive; other rows can be consolidated into this one</td></tr>
          <tr><td class="gray" style="width: 20px">&#160;</td><td>Column value is NULL</td></tr>
          <tr><td class="violet" style="width: 20px">&#160;</td><td>Column value need whitespace normalization</td></tr>
          <tr><td class="green" style="width: 20px">&#160;</td><td>Column value matches all other rows in the same group</td></tr>
          <tr><td class="blue" style="width: 20px">&#160;</td><td>Column value matches at least one other row in the same group</td></tr>
          <tr><td class="pink">&#160;</td><td>Column value differs from that of all other rows in the same group</td></tr>
        </table>
        <table>
          <xsl:call-template name="table_heading"/>
          <tbody>
            <xsl:apply-templates select="row[position() &lt;= $lastrow]"/>
          </tbody>
        </table>
      </body>
    </html>
  </xsl:template>


  <xsl:template match="row">
    <xsl:variable name="record" select="."/><!-- The current "row" element. -->
    <xsl:variable name="matches" select="../row[scientificname = current()/scientificname and generate-id(.) != generate-id(current())]"/><!-- The set of other "row" elements whose "scientificname" child element has the same value as this one. -->
    <tr>
      <td>
        <xsl:attribute name="class">
          <xsl:choose>
            <xsl:when test="$mode = 'consolidate' and ./group_representitive = 'true' and not(preceding-sibling::*[scientificname = current()/scientificname]/group_representitive = 'true')">
              <xsl:message>SELECT update_references(<xsl:value-of select="./id"/>);</xsl:message>
              green
            </xsl:when>
            <xsl:when test="./can_delete = 'true'">
              <xsl:choose>
                <xsl:when test="$mode = 'delete'">
                  <xsl:message>DELETE FROM pfts_species WHERE specie_id = <xsl:value-of select="./id"/>;</xsl:message>
                  <xsl:message>DELETE FROM species WHERE id = <xsl:value-of select="./id"/>;</xsl:message>
                </xsl:when>
                <xsl:when test="$mode = 'consolidate'">
                  <xsl:message terminate='yes'>Don't run in consolidate mode until you have run in deletion mode and run the deletion script.</xsl:message>
                </xsl:when>
              </xsl:choose>
              red
            </xsl:when>
            <xsl:when test="./deletion_candidate = 'true'">
              orange
            </xsl:when>
          </xsl:choose>
        </xsl:attribute>
        <xsl:value-of select="id"/>
      </td>
      <xsl:for-each select="$columns[position() > 1]"><!-- Iterate through all the columns of the query result from "duplicate_species_query.sql", starting with the column after "id". -->
        <xsl:variable name="column_value" select="$record/*[local-name(.) = local-name(current())]"/><!-- The value in the current column as a string. -->
        <xsl:variable name="column_values_of_matching_rows" select="$matches/*[local-name(.) = local-name(current())]"/>
        <td>
          <xsl:attribute name="class">
            <xsl:if test="current()[@compare &gt; 0]">
              <xsl:choose>
                <xsl:when test="count($column_value) = 0"><!-- value is NULL (no column in XML) -->
                  gray
                </xsl:when>
                <xsl:when test="$column_value != normalize-space($column_value)"><!-- space in value is not normalized -->
                  violet
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
    <xsl:if test="not(./following-sibling::row = $matches)">
      <tr><td style="background-color: blue" colspan="{count($columns)}">   </td></tr>
      <xsl:if test="count(./preceding-sibling::row[scientificname != preceding-sibling::row/scientificname] ) mod 5 = 0"><!-- This test isn't quite right but it's good enough for now. -->
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

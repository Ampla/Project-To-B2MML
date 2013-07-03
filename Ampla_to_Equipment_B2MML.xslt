<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns="http://www.wbf.org/xml/b2mml-v0400"
  >
  <xsl:output method="xml" indent="yes" />
  <xsl:variable name="modelDateTime">2011-01-01T12:00:00Z</xsl:variable>

  <xsl:variable name="invalidChars">./?:&amp;\*&gt;&lt;[]|#%="</xsl:variable>

  <xsl:template match="/">
    <ShowEquipmentInformation releaseID="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.wbf.org/xml/b2mml-v0400">
      <ApplicationArea>
        <CreationDateTime>
          <xsl:value-of select="$modelDateTime" />
        </CreationDateTime>
      </ApplicationArea>
      <DataArea>
        <Show />
        <EquipmentInformation>
          <PublishedDate>
            <xsl:value-of select="$modelDateTime" />
          </PublishedDate>
          <xsl:apply-templates select="/Ampla/Item"/> 
          <!-- Add Equipment classes here -->
          
        </EquipmentInformation>
      </DataArea>
    </ShowEquipmentInformation>
  </xsl:template>

  <xsl:template match="Item">
    <xsl:comment>Ignore item <xsl:value-of select="@type"/></xsl:comment>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Isa95.EnterpriseFolder']">
    <xsl:call-template name="add-equipment">
      <xsl:with-param name="equipmentLevel">Enterprise</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Isa95.SiteFolder']">
    <xsl:call-template name="add-equipment">
      <xsl:with-param name="equipmentLevel">Site</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Isa95.AreaFolder']">
    <xsl:call-template name="add-equipment">
      <xsl:with-param name="equipmentLevel">Area</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.General.Server.ApplicationsFolder']">
    <xsl:call-template name="add-equipment">
      <xsl:with-param name="equipmentLevel">Other</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="add-equipment">
    <xsl:param name="full-name">
      <xsl:call-template name="get-full-name"/>
    </xsl:param>
    <xsl:param name="name" select="@name"/>
    <xsl:param name="equipmentLevel">Other</xsl:param>
    <Equipment>
      <ID schemeName="Fullname">
        <xsl:value-of select="$full-name"/>
      </ID>
      <xsl:call-template name="add-equipment-property">
        <xsl:with-param name="name">Ampla.Name</xsl:with-param>
        <xsl:with-param name="value" select="$name"/>
      </xsl:call-template>
      <xsl:apply-templates select="Item"/>
      <Location>
        <EquipmentID>
          <xsl:value-of select="@id"/>
        </EquipmentID>
        <EquipmentElementLevel>
          <xsl:value-of select="$equipmentLevel"/>
        </EquipmentElementLevel>
      </Location>
    </Equipment>
  </xsl:template>

  <xsl:template name="add-equipment-property">
    <xsl:param name="name" select="@name"/>
    <xsl:param name="value"></xsl:param>
    <xsl:param name="datatype">string</xsl:param>
    <EquipmentProperty>
      <ID>
        <xsl:value-of select="$name"/>
      </ID>
      <Value>
        <ValueString>
          <xsl:value-of select="$value"/>
        </ValueString>
        <DataType>
          <xsl:value-of select="$datatype"/>
        </DataType>
        <UnitOfMeasure />
      </Value>
    </EquipmentProperty>
  </xsl:template>

  <xsl:template name="get-full-name">
    <xsl:param name="node" select="."/>
    <xsl:for-each select="$node/ancestor-or-self::*[@name]">
      <xsl:if test="position() > 1">.</xsl:if>
      <xsl:value-of select="@name"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="add-class">
    <xsl:param name="full-name">
      <xsl:call-template name="get-full-name"/>
    </xsl:param>
    <xsl:param name="name" select="@name"/>
    <EquipmentClass>
      <ID>
        <xsl:value-of select="$full-name"/>
      </ID>
      <!--
      <xsl:if test="string-length(@parent) > 0">             
        <EquipmentClassProperty>
          <ID>Ampla.Parent</ID>
          <Description>Ampla Reserved property</Description>
          <Value>
            <ValueString>
              <xsl:value-of select="@parent"/>
            </ValueString>
            <DataType>string</DataType>
            <UnitOfMeasure />
          </Value>
        </EquipmentClassProperty>
      </xsl:if>
      -->
      <EquipmentClassProperty>
        <ID>Ampla.Name</ID>
        <Description>Ampla Reserved property</Description>
        <Value>
          <ValueString>
            <xsl:value-of select="$name"/>
          </ValueString>
          <DataType>string</DataType>
          <UnitOfMeasure />
        </Value>
      </EquipmentClassProperty>
     </EquipmentClass>
  </xsl:template>

  <xsl:template name="add-class-property">
    <xsl:param name="name">CustomProperty</xsl:param>
    <xsl:param name="datatype">string</xsl:param>
    <xsl:param name="description"></xsl:param> 
    <EquipmentClassProperty>
      <ID>
        <xsl:value-of select="$name"/>
      </ID>
      <Description>
        <xsl:value-of select="$description"/>
      </Description>
      <Value>
        <ValueString></ValueString>
        <DataType>
          <xsl:value-of select="$datatype"/>
        </DataType>
        <UnitOfMeasure />
      </Value>
    </EquipmentClassProperty>            
  </xsl:template>
  
  <xsl:template match="@* | node()"/>

  <xsl:template name="get-class-full-name">
    <xsl:param name="node" select="."/>
    <xsl:if test="string-length($node/@parent) > 0">
      <xsl:value-of select="$node/@parent"/>
      <xsl:text>.</xsl:text>
    </xsl:if>
    <xsl:value-of select="@name"/>
  </xsl:template>

</xsl:stylesheet>
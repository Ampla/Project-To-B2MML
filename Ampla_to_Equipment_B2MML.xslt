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

  <xsl:key name='classes-by-id' match='ClassDefinition' use='@id'/>
  
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
		  <!-- First level Class Definitions is the Equipment Classes -->
		  <xsl:apply-templates select="/Ampla/ClassDefinitions/ClassDefinition/ClassDefinition"/>
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

  <xsl:template match="ClassDefinition[@type='Citect.Ampla.Isa95.EquipmentClassDefinition']">
	<xsl:call-template name='add-class'/>
	<xsl:apply-templates select='ClassDefinition'/>
  </xsl:template>

  <xsl:template match="PropertyDefinition">
	<xsl:call-template name='add-class-property'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='description' select='@description'/>
		<xsl:with-param name='datatype'>
			<xsl:call-template name='translate-data-type'/>
		</xsl:with-param>
		<xsl:with-param name='value' select='.'/>
	</xsl:call-template>
  </xsl:template>
  
  <xsl:template match='ItemClassAssociation'>
	<xsl:variable name='class-id' select='@classDefinitionId'/>
	<xsl:variable name='class-definition' select="key('classes-by-id', $class-id)" />
	<xsl:if test="$class-definition">
		<xsl:element name='EquipmentClassID'>
			<xsl:call-template name='get-class-name'>
				<xsl:with-param name='class' select='$class-definition'/>
			</xsl:call-template>
		</xsl:element>
	</xsl:if>
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
	  <xsl:call-template name='add-equipment-class-properties'>
		<xsl:with-param name='class-id' select='ItemClassAssociation/@classDefinitionId'/>
	  </xsl:call-template>
      <xsl:apply-templates select="Item"/>
	  <xsl:apply-templates select='ItemClassAssociation'/>
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
  
  <xsl:template name='add-equipment-class-properties'>
	<xsl:param name='class-id'/>
	<xsl:variable name='class' select="key('classes-by-id', $class-id)"/>
	<xsl:variable name='item' select='.'/>
	<xsl:variable name='prop-defs' select='$class/ancestor-or-self::ClassDefinition/PropertyDefinition'/>
	
	<xsl:for-each select='$prop-defs'>
		<xsl:variable name='prop-name' select='@name'/>
		<xsl:variable name='class-prop-name' select="concat('Class.', @name)"/>
		<xsl:variable name='prop-value'>
			<xsl:choose>
				<xsl:when test="$item/Property[@name=$class-prop-name]">
					<xsl:value-of select="$item/Property[@name=$class-prop-name]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select='.'/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name='prop-type'>
			<xsl:call-template name='translate-data-type'/>
		</xsl:variable>
		<xsl:call-template name='add-equipment-property'>
			<xsl:with-param name='name' select='$prop-name'/>
			<xsl:with-param name='value' select='$prop-value'/>
			<xsl:with-param name='datatype' select='$prop-type'/>
		</xsl:call-template>
	</xsl:for-each>	
  </xsl:template>

  <xsl:template name="get-full-name">
    <xsl:param name="node" select="."/>
    <xsl:for-each select="$node/ancestor-or-self::*[@name]">
      <xsl:if test="position() > 1">.</xsl:if>
      <xsl:value-of select="@name"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="add-class">
    <xsl:param name="name" select="@name"/>
	<xsl:param name="parent">
		<xsl:call-template name='get-class-name'>
			<xsl:with-param name='class' select='..'/>
		</xsl:call-template>
	</xsl:param>
    <EquipmentClass>
      <ID>
		<xsl:if test='string-length($parent) > 0'>
			<xsl:value-of select='$parent'/>
			<xsl:text>.</xsl:text>
		</xsl:if>
		<xsl:value-of select='$name'/>
      </ID>
      <xsl:if test="string-length($parent) > 0">             
        <EquipmentClassProperty>
          <ID>Ampla.Parent</ID>
          <Description>Ampla Reserved property</Description>
          <Value>
            <ValueString>
              <xsl:value-of select="$parent"/>
            </ValueString>
            <DataType>string</DataType>
            <UnitOfMeasure />
          </Value>
        </EquipmentClassProperty>
      </xsl:if>
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
	  <xsl:apply-templates select='PropertyDefinition'>
		<xsl:sort select='@name'/>
	  </xsl:apply-templates>
     </EquipmentClass>
  </xsl:template>

  <xsl:template name="add-class-property">
    <xsl:param name="name">CustomProperty</xsl:param>
    <xsl:param name="datatype">string</xsl:param>
    <xsl:param name="description"></xsl:param> 
	<xsl:param name="value"></xsl:param>
    <EquipmentClassProperty>
      <ID>
        <xsl:value-of select="$name"/>
      </ID>
      <Description>
        <xsl:value-of select="$description"/>
      </Description>
      <Value>
        <ValueString><xsl:value-of select='$value'/></ValueString>
        <DataType>
          <xsl:value-of select="$datatype"/>
        </DataType>
        <UnitOfMeasure />
      </Value>
    </EquipmentClassProperty>            
  </xsl:template>
  
  <xsl:template match="@* | node()"/>

  <xsl:template name='translate-data-type'>
	<xsl:param name='data-type' select='@type'/>
	<xsl:choose>
		<xsl:when test="$data-type='System.String'">string</xsl:when>
		<xsl:when test="$data-type='System.Int32'">int</xsl:when>
		<xsl:otherwise>string</xsl:otherwise>
	</xsl:choose>
  </xsl:template>
    
  <xsl:template name="get-class-name">
    <xsl:param name="class" select="."/>
	<xsl:variable name='classes' select='$class/ancestor-or-self::ClassDefinition'/>
	<xsl:choose>
		<xsl:when test='count($classes) = 1'><!-- level 1 class --></xsl:when>
		<xsl:otherwise>
			<xsl:for-each select='$classes[position() > 1]'>
				<xsl:if test='position() > 1'>
					<xsl:text>.</xsl:text>
				</xsl:if>
				<xsl:value-of select="@name"/>
			</xsl:for-each>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
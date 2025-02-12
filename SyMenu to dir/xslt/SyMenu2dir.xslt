<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" omit-xml-declaration='yes' indent="no" encoding="UTF-8"/>
	<xsl:param name="BASEPATH" select="'.'"/>
	<xsl:param name="ONLYTREE" select="'NO'"/>
	<xsl:param name="DUMMY" select="'YES'"/>
	<xsl:param name="POSID" select="'YES'"/>
	<xsl:param name="timestamp">2021-01-01</xsl:param>
	<!--
/** @file
 *  @brief SyMenu2dir creates a BAT file to make a folder structure that is isomorphic to the SyMenu's tree.
 *  @details This simple XSLT transforms branches and Items data to MKDIR commands.
 *  In input is the SyMenuItem.xml SyMenu configuration file.
 *  The output is a valid BAT file.@n
 *  Menu names are filtered to eliminate all invalid characters in directories, i.e. '< > : & / \ | ? *'.
 */ -->
	<!--
 /** 
 * @var Param BASEPATH 
 * @details
 *  Controls the paths used by MKDIR to create new folders.
 *  - BASEPATH = '.' the path is relative 
 *  - BASEPATH="D:\USER\SyMenu\documents"  (example) the path is absolute.
 *         
 * @var Param ONLYTREE
 * @details 
 * Will create only dir from branches (YES) or also from Items:programs, lnks, etc. (NO)
 *    Accepts two walues: 'YES'|'NO'.
 * @var Param POSID
 * @details 
 * If YES, any dir has a position index, like: '05_xxxx' to keep the menu order. 
 *    WARNING: if a container changes position in the menu, this option creates a new dir. 
 *    Accepts two walues: 'YES'|'NO'.
* @var Param DUMMY
 * @details 
 * Adds commands to create a 'dummy' file in any new dir.
 *    Accepts two walues: 'YES'|'NO'.
 *
 */ -->
	<!-- 
/** @file
 * @version 16/01/2022
 * @author Copyright 2022 Marco Sillano.
 */ -->
	<!--
 /**
 *  main template. 
 *  Starts the process and creates first/last lines.
 */ -->
	<xsl:template match="/">
		<xsl:value-of disable-output-escaping="yes" select="concat(':: =======  from SyMenu, ',$timestamp,'.&#xD;&#xA;')"/>
		<xsl:if test="$ONLYTREE='YES'">
			<xsl:text disable-output-escaping="yes">:: This BAT file builds a directory tree isomorphic to SyMenu's Tree.&#xD;&#xA;</xsl:text>
		</xsl:if>
		<xsl:if test="$ONLYTREE='NO'">
			<xsl:text disable-output-escaping="yes">:: This BAT file builds a directory tree isomorphic to SyMenu's Tree and Items.&#xD;&#xA;</xsl:text>
		</xsl:if>
		<xsl:if test="$BASEPATH='.'">
			<xsl:text disable-output-escaping="yes">:: Copy it in the your base path and run it.&#xD;&#xA;&#xD;&#xA;</xsl:text>
		</xsl:if>
		<xsl:if test="not($BASEPATH='.')">
			<xsl:value-of disable-output-escaping="yes" select="concat(':: Run this BAT file to create the folders in &quot;',$BASEPATH,'&quot;.&#xD;&#xA;&#xD;&#xA;')"/>
		</xsl:if>
		<xsl:apply-templates select="*">
			<xsl:with-param name="actualdir" select="$BASEPATH"/>
		</xsl:apply-templates>
		<xsl:text disable-output-escaping="yes">&#xD;&#xA;::  by SyMenu2dir v. 2.1 (beta)      ©2022 Marco Sillano &#xD;&#xA;</xsl:text>
		<!--  next line adds a 'pause' to see runtime messages: optional, you can delete it  -->
		<!--
         <xsl:text disable-output-escaping="yes">pause&#xD;&#xA;</xsl:text>
         -->
	</xsl:template>
	<!--
/**
* processes the root node SyRoot  
*/ -->
	<xsl:template match="SyRoot">
		<xsl:param name="actualdir"/>
		<xsl:value-of disable-output-escaping="yes" select="concat('MKDIR &quot;',$actualdir,'\SyRoot&quot; &#xD;&#xA;')"/>
		<xsl:if test="$DUMMY='YES'">
			<xsl:value-of disable-output-escaping="yes" select="concat('ECHO 0 &gt; &quot;',$actualdir,'\SyRoot\dummy&quot;&#xD;&#xA;')"/>
		</xsl:if>
		<xsl:apply-templates select="*">
			<xsl:with-param name="deep">1</xsl:with-param>
			<xsl:with-param name="actualdir">
				<xsl:value-of select="concat($actualdir,'\SyRoot')"/>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	<!--
/**
* processes all tree branches   
* Uses '@name' filtered as dir-step.  
*/ -->
	<xsl:template match="SyContainer">
		<xsl:param name="actualdir"/>
		<xsl:param name="deep"/>
		<xsl:variable name="step">
			<xsl:if test="$POSID='YES'">
				<xsl:value-of select="concat(format-number( count(preceding-sibling::*[@defaultIcon || guid]) + 1,'00'),'_',translate(@name, '►&lt;>:&quot;/\|?* ','»-«»__________'))"/>
			</xsl:if>
			<xsl:if test="$POSID='NO'">
				<xsl:value-of select="translate(@name, '►&lt;>:&quot;/\|?* ','»-«»__________')"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="newdir">
			<xsl:value-of select="concat($actualdir,'\',$step)"/>
		</xsl:variable>
		<xsl:value-of disable-output-escaping="yes" select="concat(':: ==== START BRANCH [',$step,'] &#xD;&#xA;')"/>
		<xsl:value-of disable-output-escaping="yes" select="concat(substring('                    ', 20 - ($deep * 4)),'MKDIR &quot;',$newdir,'&quot; &#xD;&#xA;')"/>
		<xsl:if test="$DUMMY='YES'">
			<xsl:value-of disable-output-escaping="yes" select="concat(substring('                    ', 20 - ($deep * 4)),'ECHO 0 &gt; &quot;',$newdir,'\dummy&quot;&#xD;&#xA;')"/>
		</xsl:if>
		<xsl:apply-templates select="*">
			<xsl:with-param name="actualdir">
				<xsl:value-of select="$newdir"/>
			</xsl:with-param>
			<xsl:with-param name="deep">
				<xsl:value-of select="$deep+1"/>
			</xsl:with-param>
		</xsl:apply-templates>
		<xsl:value-of disable-output-escaping="yes" select="concat(':: ==== END BRANCH [',$step,'] &#xD;&#xA;')"/>
	</xsl:template>
	<!--
/**
* process all items, only if ONLYTREE = NO 
* Uses 'name' filtered as dir-step.  
*/ -->
	<xsl:template match="*[guid]">
		<xsl:param name=" actualdir"/>
		<xsl:param name="deep"/>
		<xsl:if test="$ONLYTREE='NO'">
			<xsl:variable name="newdir">
				<xsl:if test="$POSID='YES'">
					<xsl:value-of select="concat($actualdir,'\', format-number( count(preceding-sibling::*[@defaultIcon || guid]) +1,'00'),'_',translate(name, '►&lt;>:&quot;/\|?* ','»-«»__________'))"/>
				</xsl:if>
				<xsl:if test="$POSID='NO'">
					<xsl:value-of select="concat($actualdir,'\',translate(name, '►&lt;>:&quot;/\|?* ','»-«»__________'))"/>
				</xsl:if>
			</xsl:variable>
			<xsl:value-of disable-output-escaping="yes" select="concat(substring('                    ', 20 - ($deep * 4)),'MKDIR &quot;',$newdir,'&quot; &#xD;&#xA;')"/>
			<xsl:if test="$DUMMY='YES'">
				<xsl:value-of disable-output-escaping="yes" select="concat(substring('                    ', 20 - ($deep * 4)),'ECHO 0 &gt; &quot;',$newdir,'\dummy&quot;&#xD;&#xA;')"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<!--
/**
* default: destroy  
*/ -->
	<xsl:template match="@*|node()"/>
</xsl:stylesheet>


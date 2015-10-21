<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:rl="http://enterprise.businessobjects.com/replicationLog"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <xsl:output method="html" encoding="UTF-8"
                media-type="text/xhtml"
                indent="no"
                doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"  />
    <!-- Label variables -->
    <xsl:variable name="title_label" select="rl:ReplicationLog/rl:Strings/rl:Title/text()" />
    <xsl:variable name="summary_label" select="rl:ReplicationLog/rl:Strings/rl:Summary/text()" />
    <xsl:variable name="origin_site_label" select="rl:ReplicationLog/rl:Strings/rl:OriginSite/text()" />
    <xsl:variable name="destination_site_label" select="rl:ReplicationLog/rl:Strings/rl:DestinationSite/text()" />
    <xsl:variable name="commit_count_label" select="rl:ReplicationLog/rl:Strings/rl:CommitCount/text()" />
    <xsl:variable name="error_count_label"  select="rl:ReplicationLog/rl:Strings/rl:ErrorCount/text()" />
    <xsl:variable name="back_to_top_label" select="rl:ReplicationLog/rl:Strings/rl:BackToTop/text()" />
    <xsl:variable name="entries_label" select="rl:ReplicationLog/rl:Strings/rl:Entries/text()" />
    <xsl:variable name="object_name_label" select="rl:ReplicationLog/rl:Strings/rl:ObjectName/text()" />
    <xsl:variable name="object_type_label" select="rl:ReplicationLog/rl:Strings/rl:ObjectType/text()" />
    <xsl:variable name="object_cuid_label" select="rl:ReplicationLog/rl:Strings/rl:ObjectCUID/text()" />
    <xsl:variable name="level_label" select="rl:ReplicationLog/rl:Strings/rl:Level/text()" />
    <xsl:variable name="time_label" select="rl:ReplicationLog/rl:Strings/rl:Time/text()" />
    <xsl:variable name="message_label" select="rl:ReplicationLog/rl:Strings/rl:Message/text()" />
    <xsl:variable name="debug_label" select="rl:ReplicationLog/rl:Strings/rl:Debug/text()" />
    <xsl:variable name="info_label" select="rl:ReplicationLog/rl:Strings/rl:Info/text()" />
    <xsl:variable name="warn_label" select="rl:ReplicationLog/rl:Strings/rl:Warn/text()" />
    <xsl:variable name="error_label" select="rl:ReplicationLog/rl:Strings/rl:Error/text()" />
    
    <!-- Start transformation from root -->
    <xsl:template match="rl:ReplicationLog">
        <html xmlns="http://www.w3.org/1999/xhtml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rl="http://enterprise.businessobjects.com/replicationLog">
            <head>
                <title>Business Objects: <xsl:copy-of select="$title_label" /></title>
                <link rel="StyleSheet" href="../jsp/Replication_ViewInstance/css/replication_log.css" />
            </head>
            <body>
                <a name="top" />
                <!-- Title -->
                <div id="title_nav">
                    <div id="title"><xsl:copy-of select="$title_label" /></div>
                </div>
                <!-- Summary -->
                <div id="header">
                    <a name="summary" />
                    <div class="section_header_td"><xsl:copy-of select="$summary_label" /></div>
                    <table id="header_tb">
                        <tr class="alt1">
                            <td class="header_td"><xsl:copy-of select="$origin_site_label" />:</td><td><xsl:value-of select="rl:OriginSite" /></td>
                        </tr>
                        <tr class="alt2">
                            <td class="header_td"><xsl:copy-of select="$destination_site_label" />:</td><td><xsl:value-of select="rl:DestinationSite" /></td>
                        </tr>
                        <tr>
                            <td colspan="2" align="center">
                                <div id="objectcount_div">
                                    <table id="objectcount_tb">
                                        <summary><p id="objectcount_summary"><xsl:copy-of select="$summary_label" />:</p></summary>
                                        <colgroup align="center">
                                            <col />
                                            <col class="summary_origin_col" />
                                            <col class="summary_destination_col" />
                                        </colgroup>
                                        <thead>
                                            <tr>
                                                <th></th>
                                                <th class="summary_category_col"><xsl:copy-of select="$origin_site_label" /></th>
                                                <th class="summary_category_col"><xsl:copy-of select="$destination_site_label" /></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td class="summary_category_col"><xsl:copy-of select="$commit_count_label" /></td>
                                                <td><xsl:value-of select="rl:OriginCommitCount" /></td>
                                                <td><xsl:value-of select="rl:DestinationCommitCount" /></td>
                                            </tr>
                                            <tr>
                                                <td class="summary_category_col"><xsl:copy-of select="$error_count_label" /></td>
                                                <td><xsl:value-of select="rl:OriginErrorCount" /></td>
                                                <td><xsl:value-of select="rl:DestinationErrorCount" /></td>
                                            </tr>
                                        </tbody>
                                    </table>
                                    <br />
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
                <!-- Content -->
                <div id="content">
                    <xsl:apply-templates select="rl:Entries"></xsl:apply-templates>
                </div>
            </body>
        </html>
    </xsl:template>
    
    <!-- Render Entries -->
    <xsl:template match="rl:Entries">
        <div class="section_header_td"><xsl:copy-of select="$entries_label" /></div><br/>
        <xsl:apply-templates select="rl:Entry"></xsl:apply-templates>
    </xsl:template>
    
    <!-- Render ProcessEntry -->
    <xsl:template match="rl:Entry[@xsi:type='rl:ProcessEntry']">
        <table class="entries_tb" cellpadding="3">
            <tr class="process_action_tr"><td colspan="2"><xsl:value-of select="rl:Message" /></td></tr>
            <tr class="alt1"><td class="item_attribute_type"><h3><xsl:copy-of select="$time_label" />:</h3></td><td><xsl:value-of select="rl:Time" /></td></tr>
            <tr><td class="item_attribute_type"><h3><xsl:copy-of select="$level_label" />:</h3></td><td><xsl:apply-templates select="rl:Level" /></td></tr>
            <tr><td colspan="2"><a href="#top"><xsl:copy-of select="$back_to_top_label" /></a> | <a href="#summary"><xsl:copy-of select="$summary_label" /></a></td></tr>
        </table><br/>
    </xsl:template>
    
    <!-- Render Object Entry -->
    <xsl:template match="rl:Entry[@xsi:type='rl:ObjectEntry']">
        <table class="object_tb" cellpadding="3">
            <tr class="object_name_tr"><td class="item_attribute_type"><h3><xsl:copy-of select="$object_name_label" />:</h3></td><td><xsl:value-of select="rl:ObjectName" /></td></tr>
            <tr><td class="item_attribute_type"><h3><xsl:copy-of select="$object_type_label" />:</h3></td><td><xsl:value-of select="rl:ObjectType" /></td></tr>
            <tr class="alt1"><td class="item_attribute_type"><h3><xsl:copy-of select="$object_cuid_label" />:</h3></td><td><xsl:value-of select="rl:ObjectCUID" /></td></tr>
            <tr><td class="item_attribute_type"><h3><xsl:copy-of select="$message_label" />:</h3></td><td><xsl:value-of select="rl:Message" /></td></tr>
            <tr class="alt1"><td class="item_attribute_type"><h3><xsl:copy-of select="$time_label" />:</h3></td><td><xsl:value-of select="rl:Time" /></td></tr>
            <tr><td class="item_attribute_type"><h3><xsl:copy-of select="$level_label" />:</h3></td><td><xsl:apply-templates select="rl:Level" /></td></tr>
            <tr><td colspan="2"><a href="#top"><xsl:copy-of select="$back_to_top_label" /></a> | <a href="#summary"><xsl:copy-of select="$summary_label" /></a></td></tr>
        </table><br/>
    </xsl:template>
    
    <!-- Display different color of entry status and apply localization -->
    <xsl:template match="rl:Level">
        <xsl:choose>
            <xsl:when test="text()='DEBUG'"><div class="level_debug"><xsl:copy-of select="$debug_label" /></div></xsl:when>
            <xsl:when test="text()='INFO'"><div class="level_info"><xsl:copy-of select="$info_label" /></div></xsl:when>
            <xsl:when test="text()='WARN'"><div class="level_warn"><xsl:copy-of select="$warn_label" /></div></xsl:when>
            <xsl:when test="text()='ERROR'"><div class="level_error"><xsl:copy-of select="$error_label" /></div></xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
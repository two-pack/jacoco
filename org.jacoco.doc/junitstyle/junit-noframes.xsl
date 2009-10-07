<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
        xmlns:lxslt="http://xml.apache.org/xslt"
        xmlns:stringutils="xalan://org.apache.tools.ant.util.StringUtils">
<xsl:output method="html" indent="yes" encoding="US-ASCII"
  doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" />
<xsl:decimal-format decimal-separator="." grouping-separator="," />
<!--
   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 -->

<xsl:param name="VERSION"/>
<xsl:param name="HOMEURL"/>

<!--

 JaCoCo test report stylesheet.

-->
<xsl:template match="testsuites">
    <html>
        <head>
            <link rel="stylesheet" href="../doc/.resources/doc.css" charset="ISO-8859-1" type="text/css" />
            <title>JaCoCo - JUnit Test Results</title>
            
    <style type="text/css">
      .Error {
        font-weight:bold; color:red;
      }
      .Failure {
        font-weight:bold; color:purple;
      }
      </style>
        </head>
        <body>
            <a name="top"></a>
            <xsl:call-template name="pageHeader"/>

            <!-- Summary part -->
            <xsl:call-template name="summary"/>
            <hr size="1"/>

            <!-- Package List part -->
            <xsl:call-template name="packagelist"/>
            <hr size="1"/>

            <!-- For each package create its part -->
            <xsl:call-template name="packages"/>
            <hr size="1"/>

            <!-- For each class create the  part -->
            <xsl:call-template name="classes"/>
            
			<div class="footer">
				<div class="versioninfo"><a href="{$HOMEURL}">JaCoCo</a>&#160;<xsl:value-of select="$VERSION"/></div>
				<a href="../doc/license.html">Copyright</a> &#169; 2009 Mountainminds GmbH &amp; Co. KG and Contributors
			</div>
        </body>
    </html>
</xsl:template>



<!-- ================================================================== -->
<!-- Write a list of all packages with an hyperlink to the anchor of    -->
<!-- of the package name.                                               -->
<!-- ================================================================== -->
<xsl:template name="packagelist">
	<h2>Packages</h2>
	<table class="coverage">
		<xsl:call-template name="testsuite.test.header"/>
		<tbody>			
			<!-- list all packages recursively -->
            <xsl:for-each select="./testsuite[not(./@package = preceding-sibling::testsuite/@package)]">
                <xsl:sort select="@package"/>
                <xsl:variable name="testsuites-in-package" select="/testsuites/testsuite[./@package = current()/@package]"/>
                <xsl:variable name="testCount" select="sum($testsuites-in-package/@tests)"/>
                <xsl:variable name="errorCount" select="sum($testsuites-in-package/@errors)"/>
                <xsl:variable name="failureCount" select="sum($testsuites-in-package/@failures)"/>
                <xsl:variable name="timeCount" select="sum($testsuites-in-package/@time)"/>

                <!-- write a summary for the package -->
                <tr valign="top">
                    <!-- set a nice color depending if there is an error/failure -->
                    <xsl:attribute name="class">
                        <xsl:choose>
                            <xsl:when test="$failureCount &gt; 0">Failure</xsl:when>
                            <xsl:when test="$errorCount &gt; 0">Error</xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <td><a href="#{@package}"><xsl:value-of select="@package"/></a></td>
                    <td><xsl:value-of select="$testCount"/></td>
                    <td><xsl:value-of select="$errorCount"/></td>
                    <td><xsl:value-of select="$failureCount"/></td>
                    <td>
                    <xsl:call-template name="display-time">
                        <xsl:with-param name="value" select="$timeCount"/>
                    </xsl:call-template>
                    </td>
                    <td><xsl:value-of select="$testsuites-in-package/@timestamp"/></td>
                </tr>
            </xsl:for-each>
		</tbody>
	</table>
	<p class="hint">
        Note: package statistics are not computed recursively, they only sum up all of its testsuites numbers.
    </p>
</xsl:template>


    <!-- ================================================================== -->
    <!-- Write a package level report                                       -->
    <!-- It creates a table with values from the document:                  -->
    <!-- Name | Tests | Errors | Failures | Time                            -->
    <!-- ================================================================== -->
    <xsl:template name="packages">
        <!-- create an anchor to this package name -->
        <xsl:for-each select="/testsuites/testsuite[not(./@package = preceding-sibling::testsuite/@package)]">
            <xsl:sort select="@package"/>
                <a name="{@package}"></a>
                <h3>Package <xsl:value-of select="@package"/></h3>

                <table class="coverage" style="width:36em">
                    <xsl:call-template name="testsuite.test.header"/>

                    <!-- match the testsuites of this package -->
                    <xsl:apply-templates select="/testsuites/testsuite[./@package = current()/@package]" mode="print.test"/>
                </table>
                <p/>
                <a href="#top">Back to top</a>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="classes">
        <xsl:for-each select="testsuite">
            <xsl:sort select="@name"/>
            <!-- create an anchor to this class name -->
            <a name="{@name}"></a>
            <h3>TestCase <xsl:value-of select="@name"/></h3>

            <table class="coverage" style="width:28em">
              <xsl:call-template name="testcase.test.header"/>
              <!--
              test can even not be started at all (failure to load the class)
              so report the error directly
              -->
                <xsl:if test="./error">
                    <tr class="Error">
                        <td colspan="4"><xsl:apply-templates select="./error"/></td>
                    </tr>
                </xsl:if>
                <xsl:apply-templates select="./testcase" mode="print.test"/>
            </table>
            <p/>
            <a href="#top">Back to top</a>
        </xsl:for-each>
    </xsl:template>

<xsl:template name="summary">
	<h2>Summary</h2>
	<xsl:variable name="testCount" select="sum(testsuite/@tests)"/>
	<xsl:variable name="errorCount" select="sum(testsuite/@errors)"/>
	<xsl:variable name="failureCount" select="sum(testsuite/@failures)"/>
	<xsl:variable name="timeCount" select="sum(testsuite/@time)"/>
	<xsl:variable name="successRate" select="($testCount - $failureCount - $errorCount) div $testCount"/>
	<table class="coverage">
        <thead>
	        <tr valign="top">
    	        <td>Tests</td>
        	    <td>Failures</td>
            	<td>Errors</td>
            	<td>Success rate</td>
            	<td>Time</td>
        	</tr>
        </thead>
        <tbody>
			<tr valign="top">
				<xsl:attribute name="class">
					<xsl:choose>
						<xsl:when test="$failureCount &gt; 0">Failure</xsl:when>
						<xsl:when test="$errorCount &gt; 0">Error</xsl:when>
					</xsl:choose>
				</xsl:attribute>
				<td><xsl:value-of select="$testCount"/></td>
				<td><xsl:value-of select="$failureCount"/></td>
				<td><xsl:value-of select="$errorCount"/></td>
				<td>
					<xsl:call-template name="display-percent">
						<xsl:with-param name="value" select="$successRate"/>
					</xsl:call-template>
				</td>
				<td>
					<xsl:call-template name="display-time">
						<xsl:with-param name="value" select="$timeCount"/>
					</xsl:call-template>
				</td>
			</tr>
		</tbody>
	</table>
	<p class="hint">
        Note: <i>failures</i> are anticipated and checked for with assertions while <i>errors</i> are unanticipated.
    </p>
</xsl:template>

<!-- Page HEADER -->
<xsl:template name="pageHeader">
	<div class="breadcrumb">
		<a href="../index.html" class="el_session">JaCoCo</a> &gt;
		<span class="el_group">JUnit Test Results</span>
	</div>
    <h1>JUnit Test Results</h1>
    <table width="100%">
    <tr>
        <td align="left"></td>
        <td align="right">Designed for use with <a href='http://www.junit.org'>JUnit</a> and <a href='http://ant.apache.org/ant'>Ant</a>.</td>
    </tr>
    </table>
    <hr size="1"/>
</xsl:template>

<xsl:template match="testsuite" mode="header">
	<thead>
    	<tr valign="top">
        	<td width="80%">Name</td>
        	<td>Tests</td>
        	<td>Errors</td>
        	<td>Failures</td>
        	<td nowrap="nowrap">Time(s)</td>
    	</tr>
    </thead>
</xsl:template>

<!-- class header -->
<xsl:template name="testsuite.test.header">
	<thead>
    	<tr>
        	<td>Name</td>
        	<td>Tests</td>
        	<td>Errors</td>
        	<td>Failures</td>
        	<td>Time(s)</td>
        	<td>Time Stamp</td>
    	</tr>
    </thead>
</xsl:template>

<!-- method header -->
<xsl:template name="testcase.test.header">
	<thead>
    	<tr>
        	<td>Name</td>
        	<td>Status</td>
        	<td>Type</td>
        	<td>Time(s)</td>
	    </tr>
    </thead>
</xsl:template>


<!-- class information -->
<xsl:template match="testsuite" mode="print.test">
    <tr valign="top">
        <!-- set a nice color depending if there is an error/failure -->
        <xsl:attribute name="class">
            <xsl:choose>
                <xsl:when test="@failures[.&gt; 0]">Failure</xsl:when>
                <xsl:when test="@errors[.&gt; 0]">Error</xsl:when>
            </xsl:choose>
        </xsl:attribute>

        <!-- print testsuite information -->
        <td><a href="#{@name}"><xsl:value-of select="@name"/></a></td>
        <td><xsl:value-of select="@tests"/></td>
        <td><xsl:value-of select="@errors"/></td>
        <td><xsl:value-of select="@failures"/></td>
        <td>
            <xsl:call-template name="display-time">
                <xsl:with-param name="value" select="@time"/>
            </xsl:call-template>
        </td>
        <td><xsl:apply-templates select="@timestamp"/></td>
    </tr>
</xsl:template>

<xsl:template match="testcase" mode="print.test">
    <tr valign="top">
        <xsl:attribute name="class">
            <xsl:choose>
                <xsl:when test="failure | error">Error</xsl:when>
            </xsl:choose>
        </xsl:attribute>
        <td><xsl:value-of select="@name"/></td>
        <xsl:choose>
            <xsl:when test="failure">
                <td>Failure</td>
                <td><xsl:apply-templates select="failure"/></td>
            </xsl:when>
            <xsl:when test="error">
                <td>Error</td>
                <td><xsl:apply-templates select="error"/></td>
            </xsl:when>
            <xsl:otherwise>
                <td>Success</td>
                <td></td>
            </xsl:otherwise>
        </xsl:choose>
        <td>
            <xsl:call-template name="display-time">
                <xsl:with-param name="value" select="@time"/>
            </xsl:call-template>
        </td>
    </tr>
</xsl:template>


<xsl:template match="failure">
    <xsl:call-template name="display-failures"/>
</xsl:template>

<xsl:template match="error">
    <xsl:call-template name="display-failures"/>
</xsl:template>

<!-- Style for the error and failure in the tescase template -->
<xsl:template name="display-failures">
    <xsl:choose>
        <xsl:when test="not(@message)">N/A</xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="@message"/>
        </xsl:otherwise>
    </xsl:choose>
    <!-- display the stacktrace -->
    <code>
        <br/><br/>
        <xsl:call-template name="br-replace">
            <xsl:with-param name="word" select="."/>
        </xsl:call-template>
    </code>
    <!-- the later is better but might be problematic for non-21" monitors... -->
    <!--pre><xsl:value-of select="."/></pre-->
</xsl:template>

<xsl:template name="JS-escape">
    <xsl:param name="string"/>
    <xsl:param name="tmp1" select="stringutils:replace(string($string),'\','\\')"/>
    <xsl:param name="tmp2" select="stringutils:replace(string($tmp1),&quot;'&quot;,&quot;\&apos;&quot;)"/>
    <xsl:value-of select="$tmp2"/>
</xsl:template>


<!--
    template that will convert a carriage return into a br tag
    @param word the text from which to convert CR to BR tag
-->
<xsl:template name="br-replace">
    <xsl:param name="word"/>
    <xsl:value-of disable-output-escaping="yes" select='stringutils:replace(string($word),"&#xA;","&lt;br/>")'/>
</xsl:template>

<xsl:template name="display-time">
    <xsl:param name="value"/>
    <xsl:value-of select="format-number($value,'0.000')"/>
</xsl:template>

<xsl:template name="display-percent">
    <xsl:param name="value"/>
    <xsl:value-of select="format-number($value,'0.00%')"/>
</xsl:template>

</xsl:stylesheet>
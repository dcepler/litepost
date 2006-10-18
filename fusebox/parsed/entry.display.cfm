<cfsetting enablecfoutputonly="true" />
<cfprocessingdirective pageencoding="utf-8" />
<!--- circuit: entry --->
<!--- fuseaction: display --->
<cftry>
<cfset myFusebox.thisPhase = "appinit">
<cfset myFusebox.thisCircuit = "entry">
<cfset myFusebox.thisFuseaction = "display">
<cfif myFusebox.applicationStart>
	<cfif not myFusebox.getApplication().applicationStarted>
		<cflock name="#application.ApplicationName#_fusebox_#FUSEBOX_APPLICATION_KEY#_appinit" type="exclusive" timeout="30">
			<cfif not myFusebox.getApplication().applicationStarted>
				<cfset myFusebox.getApplication().applicationStarted = true />
			</cfif>
		</cflock>
	</cfif>
</cfif>
<!--- do action="home.globalXFA" --->
<cftry>
<cfset myFusebox.thisPhase = "preprocessFuseactions">
<cfset myFusebox.thisCircuit = "home">
<cfset myFusebox.thisFuseaction = "globalXFA">
<cfset xfa.home = "entry.recent" />
<cfset xfa.view = "entry.display" />
<cfset xfa.addPost = "entry.addForm" />
<cfset xfa.login = "login.form" />
<cfset xfa.logout = "login.logout" />
<!--------------------------------------------------------------------
	FB50 plugin: CustomExceptionHandler
	
	Copyright:	(c) 2006, by Adam Wayne Lehman (adrocknaphobia.com). You are free to use this FB50 plugin and to modify it as long as you keep on rocking!
	Usage:		Include the following entry under the 'fuseactionException' phase for plugins in the fusebox.xml.cfm file.
				<plugin name="CustomExceptionHandler" template="CustomExceptionHandler.cfm">
					<parameter name="filePrefix" value="custom" />
					<parameter name="genericErrorTemplate" value="genericErrorMessage" />
				</plugin>
	Overview:	If an exception occurs this plugin will attempt to locate an error template based on the
				type of exception throw.
					1) Exception based on both tokens of cfcatch exception type
						Example: "validation.empty_string"
					2) Exception based on primary token of cfcatch exception type
						Example: "validation"
					3) General exception template
---------------------------------------------------------------------->
<cfparam name="filePrefix" default="custom" type="string" />
<cfparam name="genericErrorTemplate" default="genericErrorMessage" />

<cfcatch type="any">
	
	<cfset plugin = structNew() />
	<cfset plugin.application = myFuseBox.getApplication() />
	<cfset plugin.applicationRoot = plugin.application.getApplicationRoot() />
	<cfset plugin.relativeErrorTemplatePath = plugin.application.relativePath(plugin.applicationRoot & plugin.application.pluginsPath, plugin.applicationRoot & plugin.application.errorTemplatesPath) />	
	<cfset plugin.absoluteErrorTemplatePath = plugin.applicationRoot & plugin.application.errorTemplatesPath />
	<cfif len(trim(filePrefix))>
		<cfset plugin.relativeErrorTemplatePath = plugin.relativeErrorTemplatePath & filePrefix & '.' />
		<cfset plugin.absoluteErrorTemplatePath = plugin.absoluteErrorTemplatePath & filePrefix & '.' />
	</cfif>
	
	<!---- look for exact exception type match ---->
	<cfif fileExists(plugin.absoluteErrorTemplatePath & CFCATCH.type & '.cfm')>
		<cfinclude template="#plugin.relativeErrorTemplatePath##CFCATCH.type#.cfm" />
		<cftrace type="information" text="Custom type-based exception handler called (#plugin.absoluteErrorTemplatePath##CFCATCH.type#).">
	<cfelse>
		<!---- look for top-level handler ---->
		<cfif fileExists(plugin.absoluteErrorTemplatePath & getToken(CFCATCH.type, 1, '.') & '.cfm')>
			<cfinclude template="#plugin.relativeErrorTemplatePath##getToken(CFCATCH.type, 1, '.')#.cfm" />
			<cftrace type="information" text="Custom type-based exception handler called (#plugin.absoluteErrorTemplatePath##getToken(CFCATCH.type,1,'.')#).">
		<cfelse>
			<!---- look for generic handler ---->
			<cfif fileExists(plugin.absoluteErrorTemplatePath & genericErrorTemplate & '.cfm')>
				<cfinclude template="#plugin.relativeErrorTemplatePath##genericErrorTemplate#.cfm" />
				<cftrace type="information" text="Custom generic exception handler called (#plugin.absoluteErrorTemplatePath##genericErrorTemplate#).">
			<cfelse>
				<!---- no custom template found to handle error ---->
				<cftrace type="information" text="Custom exception handler not found.">
				<cfrethrow />
			</cfif>
		</cfif>
	</cfif>
</cfcatch>
</cftry>
<cftry>
<cfset myFusebox.thisPhase = "requestedFuseaction">
<cfset myFusebox.thisCircuit = "entry">
<cfset myFusebox.thisFuseaction = "display">
<cfif NOT structKeyExists(ATTRIBUTES, 'entryID')>
<cfthrow type="validation.INVALID_ID" message="Invalid Entry" detail="You must specify a valid entry.">
</cfif>
<!--- do action="entry.get" --->
<cftry>
<cfset myFusebox.enterStackFrame() >
<cfif isDefined("ATTRIBUTES.id")><cfset myFusebox.stack["ATTRIBUTES.id"] = ATTRIBUTES.id ></cfif>
<cfset ATTRIBUTES.id = "#ATTRIBUTES.entryID#" >
<cfset myFusebox.thisFuseaction = "get">
<cftry>
<cfoutput><cfinclude template="../home/entry/qry_getEntry.cfm"></cfoutput>
<cfcatch type="missingInclude"><cfif len(cfcatch.MissingFileName) gte 16 and right(cfcatch.MissingFileName,16) is "qry_getEntry.cfm">
<cfthrow type="fusebox.missingFuse" message="missing Fuse" detail="You tried to include a fuse qry_getEntry.cfm in circuit entry which does not exist (from fuseaction entry.get).">
<cfelse><cfrethrow></cfif></cfcatch></cftry>
<cfif structKeyExists(myFusebox.stack,"ATTRIBUTES.id")><cfset ATTRIBUTES.id = myFusebox.stack["ATTRIBUTES.id"] ></cfif>
<cfif structKeyExists(myFusebox.stack,"ATTRIBUTES.id")><cfset ATTRIBUTES.id = myFusebox.stack["ATTRIBUTES.id"] ><cfelse><cfset structDelete(ATTRIBUTES,"id")></cfif>
<cfset myFusebox.leaveStackFrame() >
<!--------------------------------------------------------------------
	FB50 plugin: CustomExceptionHandler
	
	Copyright:	(c) 2006, by Adam Wayne Lehman (adrocknaphobia.com). You are free to use this FB50 plugin and to modify it as long as you keep on rocking!
	Usage:		Include the following entry under the 'fuseactionException' phase for plugins in the fusebox.xml.cfm file.
				<plugin name="CustomExceptionHandler" template="CustomExceptionHandler.cfm">
					<parameter name="filePrefix" value="custom" />
					<parameter name="genericErrorTemplate" value="genericErrorMessage" />
				</plugin>
	Overview:	If an exception occurs this plugin will attempt to locate an error template based on the
				type of exception throw.
					1) Exception based on both tokens of cfcatch exception type
						Example: "validation.empty_string"
					2) Exception based on primary token of cfcatch exception type
						Example: "validation"
					3) General exception template
---------------------------------------------------------------------->
<cfparam name="filePrefix" default="custom" type="string" />
<cfparam name="genericErrorTemplate" default="genericErrorMessage" />

<cfcatch type="any">
	
	<cfset plugin = structNew() />
	<cfset plugin.application = myFuseBox.getApplication() />
	<cfset plugin.applicationRoot = plugin.application.getApplicationRoot() />
	<cfset plugin.relativeErrorTemplatePath = plugin.application.relativePath(plugin.applicationRoot & plugin.application.pluginsPath, plugin.applicationRoot & plugin.application.errorTemplatesPath) />	
	<cfset plugin.absoluteErrorTemplatePath = plugin.applicationRoot & plugin.application.errorTemplatesPath />
	<cfif len(trim(filePrefix))>
		<cfset plugin.relativeErrorTemplatePath = plugin.relativeErrorTemplatePath & filePrefix & '.' />
		<cfset plugin.absoluteErrorTemplatePath = plugin.absoluteErrorTemplatePath & filePrefix & '.' />
	</cfif>
	
	<!---- look for exact exception type match ---->
	<cfif fileExists(plugin.absoluteErrorTemplatePath & CFCATCH.type & '.cfm')>
		<cfinclude template="#plugin.relativeErrorTemplatePath##CFCATCH.type#.cfm" />
		<cftrace type="information" text="Custom type-based exception handler called (#plugin.absoluteErrorTemplatePath##CFCATCH.type#).">
	<cfelse>
		<!---- look for top-level handler ---->
		<cfif fileExists(plugin.absoluteErrorTemplatePath & getToken(CFCATCH.type, 1, '.') & '.cfm')>
			<cfinclude template="#plugin.relativeErrorTemplatePath##getToken(CFCATCH.type, 1, '.')#.cfm" />
			<cftrace type="information" text="Custom type-based exception handler called (#plugin.absoluteErrorTemplatePath##getToken(CFCATCH.type,1,'.')#).">
		<cfelse>
			<!---- look for generic handler ---->
			<cfif fileExists(plugin.absoluteErrorTemplatePath & genericErrorTemplate & '.cfm')>
				<cfinclude template="#plugin.relativeErrorTemplatePath##genericErrorTemplate#.cfm" />
				<cftrace type="information" text="Custom generic exception handler called (#plugin.absoluteErrorTemplatePath##genericErrorTemplate#).">
			<cfelse>
				<!---- no custom template found to handle error ---->
				<cftrace type="information" text="Custom exception handler not found.">
				<cfrethrow />
			</cfif>
		</cfif>
	</cfif>
</cfcatch>
</cftry>
<!--- do action="comment.get" --->
<cftry>
<cfset myFusebox.enterStackFrame() >
<cfif isDefined("ATTRIBUTES.id")><cfset myFusebox.stack["ATTRIBUTES.id"] = ATTRIBUTES.id ></cfif>
<cfset ATTRIBUTES.id = "#ATTRIBUTES.entryID#" >
<cfset myFusebox.thisCircuit = "comment">
<cfif not isDefined("ATTRIBUTES.id")><cfset ATTRIBUTES.id = "0" /></cfif>
<cftry>
<cfoutput><cfinclude template="../home/entry/comment/qry_getComments.cfm"></cfoutput>
<cfcatch type="missingInclude"><cfif len(cfcatch.MissingFileName) gte 19 and right(cfcatch.MissingFileName,19) is "qry_getComments.cfm">
<cfthrow type="fusebox.missingFuse" message="missing Fuse" detail="You tried to include a fuse qry_getComments.cfm in circuit comment which does not exist (from fuseaction comment.get).">
<cfelse><cfrethrow></cfif></cfcatch></cftry>
<cfif structKeyExists(myFusebox.stack,"ATTRIBUTES.id")><cfset ATTRIBUTES.id = myFusebox.stack["ATTRIBUTES.id"] ></cfif>
<cfif structKeyExists(myFusebox.stack,"ATTRIBUTES.id")><cfset ATTRIBUTES.id = myFusebox.stack["ATTRIBUTES.id"] ><cfelse><cfset structDelete(ATTRIBUTES,"id")></cfif>
<cfset myFusebox.leaveStackFrame() >
<!--------------------------------------------------------------------
	FB50 plugin: CustomExceptionHandler
	
	Copyright:	(c) 2006, by Adam Wayne Lehman (adrocknaphobia.com). You are free to use this FB50 plugin and to modify it as long as you keep on rocking!
	Usage:		Include the following entry under the 'fuseactionException' phase for plugins in the fusebox.xml.cfm file.
				<plugin name="CustomExceptionHandler" template="CustomExceptionHandler.cfm">
					<parameter name="filePrefix" value="custom" />
					<parameter name="genericErrorTemplate" value="genericErrorMessage" />
				</plugin>
	Overview:	If an exception occurs this plugin will attempt to locate an error template based on the
				type of exception throw.
					1) Exception based on both tokens of cfcatch exception type
						Example: "validation.empty_string"
					2) Exception based on primary token of cfcatch exception type
						Example: "validation"
					3) General exception template
---------------------------------------------------------------------->
<cfparam name="filePrefix" default="custom" type="string" />
<cfparam name="genericErrorTemplate" default="genericErrorMessage" />

<cfcatch type="any">
	
	<cfset plugin = structNew() />
	<cfset plugin.application = myFuseBox.getApplication() />
	<cfset plugin.applicationRoot = plugin.application.getApplicationRoot() />
	<cfset plugin.relativeErrorTemplatePath = plugin.application.relativePath(plugin.applicationRoot & plugin.application.pluginsPath, plugin.applicationRoot & plugin.application.errorTemplatesPath) />	
	<cfset plugin.absoluteErrorTemplatePath = plugin.applicationRoot & plugin.application.errorTemplatesPath />
	<cfif len(trim(filePrefix))>
		<cfset plugin.relativeErrorTemplatePath = plugin.relativeErrorTemplatePath & filePrefix & '.' />
		<cfset plugin.absoluteErrorTemplatePath = plugin.absoluteErrorTemplatePath & filePrefix & '.' />
	</cfif>
	
	<!---- look for exact exception type match ---->
	<cfif fileExists(plugin.absoluteErrorTemplatePath & CFCATCH.type & '.cfm')>
		<cfinclude template="#plugin.relativeErrorTemplatePath##CFCATCH.type#.cfm" />
		<cftrace type="information" text="Custom type-based exception handler called (#plugin.absoluteErrorTemplatePath##CFCATCH.type#).">
	<cfelse>
		<!---- look for top-level handler ---->
		<cfif fileExists(plugin.absoluteErrorTemplatePath & getToken(CFCATCH.type, 1, '.') & '.cfm')>
			<cfinclude template="#plugin.relativeErrorTemplatePath##getToken(CFCATCH.type, 1, '.')#.cfm" />
			<cftrace type="information" text="Custom type-based exception handler called (#plugin.absoluteErrorTemplatePath##getToken(CFCATCH.type,1,'.')#).">
		<cfelse>
			<!---- look for generic handler ---->
			<cfif fileExists(plugin.absoluteErrorTemplatePath & genericErrorTemplate & '.cfm')>
				<cfinclude template="#plugin.relativeErrorTemplatePath##genericErrorTemplate#.cfm" />
				<cftrace type="information" text="Custom generic exception handler called (#plugin.absoluteErrorTemplatePath##genericErrorTemplate#).">
			<cfelse>
				<!---- no custom template found to handle error ---->
				<cftrace type="information" text="Custom exception handler not found.">
				<cfrethrow />
			</cfif>
		</cfif>
	</cfif>
</cfcatch>
</cftry>
<cfset myFusebox.thisCircuit = "entry">
<cfset myFusebox.thisFuseaction = "display">
<cfset xfa.edit = "entry.editForm" />
<cfset xfa.submit = "comment.add" />
<cfset xfa.remove = "entry.remove" />
<cfset xfa.removeComment = "comment.remove" />
<cftry>
<cfsavecontent variable="REQUEST.content.body"><cfoutput><cfinclude template="../home/entry/dsp_entry.cfm"></cfoutput></cfsavecontent>
<cfcatch type="missingInclude"><cfif len(cfcatch.MissingFileName) gte 13 and right(cfcatch.MissingFileName,13) is "dsp_entry.cfm">
<cfthrow type="fusebox.missingFuse" message="missing Fuse" detail="You tried to include a fuse dsp_entry.cfm in circuit entry which does not exist (from fuseaction entry.display).">
<cfelse><cfrethrow></cfif></cfcatch></cftry>
<!--------------------------------------------------------------------
	FB50 plugin: CustomExceptionHandler
	
	Copyright:	(c) 2006, by Adam Wayne Lehman (adrocknaphobia.com). You are free to use this FB50 plugin and to modify it as long as you keep on rocking!
	Usage:		Include the following entry under the 'fuseactionException' phase for plugins in the fusebox.xml.cfm file.
				<plugin name="CustomExceptionHandler" template="CustomExceptionHandler.cfm">
					<parameter name="filePrefix" value="custom" />
					<parameter name="genericErrorTemplate" value="genericErrorMessage" />
				</plugin>
	Overview:	If an exception occurs this plugin will attempt to locate an error template based on the
				type of exception throw.
					1) Exception based on both tokens of cfcatch exception type
						Example: "validation.empty_string"
					2) Exception based on primary token of cfcatch exception type
						Example: "validation"
					3) General exception template
---------------------------------------------------------------------->
<cfparam name="filePrefix" default="custom" type="string" />
<cfparam name="genericErrorTemplate" default="genericErrorMessage" />

<cfcatch type="any">
	
	<cfset plugin = structNew() />
	<cfset plugin.application = myFuseBox.getApplication() />
	<cfset plugin.applicationRoot = plugin.application.getApplicationRoot() />
	<cfset plugin.relativeErrorTemplatePath = plugin.application.relativePath(plugin.applicationRoot & plugin.application.pluginsPath, plugin.applicationRoot & plugin.application.errorTemplatesPath) />	
	<cfset plugin.absoluteErrorTemplatePath = plugin.applicationRoot & plugin.application.errorTemplatesPath />
	<cfif len(trim(filePrefix))>
		<cfset plugin.relativeErrorTemplatePath = plugin.relativeErrorTemplatePath & filePrefix & '.' />
		<cfset plugin.absoluteErrorTemplatePath = plugin.absoluteErrorTemplatePath & filePrefix & '.' />
	</cfif>
	
	<!---- look for exact exception type match ---->
	<cfif fileExists(plugin.absoluteErrorTemplatePath & CFCATCH.type & '.cfm')>
		<cfinclude template="#plugin.relativeErrorTemplatePath##CFCATCH.type#.cfm" />
		<cftrace type="information" text="Custom type-based exception handler called (#plugin.absoluteErrorTemplatePath##CFCATCH.type#).">
	<cfelse>
		<!---- look for top-level handler ---->
		<cfif fileExists(plugin.absoluteErrorTemplatePath & getToken(CFCATCH.type, 1, '.') & '.cfm')>
			<cfinclude template="#plugin.relativeErrorTemplatePath##getToken(CFCATCH.type, 1, '.')#.cfm" />
			<cftrace type="information" text="Custom type-based exception handler called (#plugin.absoluteErrorTemplatePath##getToken(CFCATCH.type,1,'.')#).">
		<cfelse>
			<!---- look for generic handler ---->
			<cfif fileExists(plugin.absoluteErrorTemplatePath & genericErrorTemplate & '.cfm')>
				<cfinclude template="#plugin.relativeErrorTemplatePath##genericErrorTemplate#.cfm" />
				<cftrace type="information" text="Custom generic exception handler called (#plugin.absoluteErrorTemplatePath##genericErrorTemplate#).">
			<cfelse>
				<!---- no custom template found to handle error ---->
				<cftrace type="information" text="Custom exception handler not found.">
				<cfrethrow />
			</cfif>
		</cfif>
	</cfif>
</cfcatch>
</cftry>
<!--- do action="home.output" --->
<cftry>
<cfset myFusebox.thisPhase = "postprocessFuseactions">
<cfset myFusebox.thisCircuit = "home">
<cfset myFusebox.thisFuseaction = "output">
<cftry>
<cfoutput><cfinclude template="../home/../layout/lay_main.cfm"></cfoutput>
<cfcatch type="missingInclude"><cfif len(cfcatch.MissingFileName) gte 22 and right(cfcatch.MissingFileName,22) is "../layout/lay_main.cfm">
<cfthrow type="fusebox.missingFuse" message="missing Fuse" detail="You tried to include a fuse ../layout/lay_main.cfm in circuit home which does not exist (from fuseaction home.output).">
<cfelse><cfrethrow></cfif></cfcatch></cftry>
<!--------------------------------------------------------------------
	FB50 plugin: CustomExceptionHandler
	
	Copyright:	(c) 2006, by Adam Wayne Lehman (adrocknaphobia.com). You are free to use this FB50 plugin and to modify it as long as you keep on rocking!
	Usage:		Include the following entry under the 'fuseactionException' phase for plugins in the fusebox.xml.cfm file.
				<plugin name="CustomExceptionHandler" template="CustomExceptionHandler.cfm">
					<parameter name="filePrefix" value="custom" />
					<parameter name="genericErrorTemplate" value="genericErrorMessage" />
				</plugin>
	Overview:	If an exception occurs this plugin will attempt to locate an error template based on the
				type of exception throw.
					1) Exception based on both tokens of cfcatch exception type
						Example: "validation.empty_string"
					2) Exception based on primary token of cfcatch exception type
						Example: "validation"
					3) General exception template
---------------------------------------------------------------------->
<cfparam name="filePrefix" default="custom" type="string" />
<cfparam name="genericErrorTemplate" default="genericErrorMessage" />

<cfcatch type="any">
	
	<cfset plugin = structNew() />
	<cfset plugin.application = myFuseBox.getApplication() />
	<cfset plugin.applicationRoot = plugin.application.getApplicationRoot() />
	<cfset plugin.relativeErrorTemplatePath = plugin.application.relativePath(plugin.applicationRoot & plugin.application.pluginsPath, plugin.applicationRoot & plugin.application.errorTemplatesPath) />	
	<cfset plugin.absoluteErrorTemplatePath = plugin.applicationRoot & plugin.application.errorTemplatesPath />
	<cfif len(trim(filePrefix))>
		<cfset plugin.relativeErrorTemplatePath = plugin.relativeErrorTemplatePath & filePrefix & '.' />
		<cfset plugin.absoluteErrorTemplatePath = plugin.absoluteErrorTemplatePath & filePrefix & '.' />
	</cfif>
	
	<!---- look for exact exception type match ---->
	<cfif fileExists(plugin.absoluteErrorTemplatePath & CFCATCH.type & '.cfm')>
		<cfinclude template="#plugin.relativeErrorTemplatePath##CFCATCH.type#.cfm" />
		<cftrace type="information" text="Custom type-based exception handler called (#plugin.absoluteErrorTemplatePath##CFCATCH.type#).">
	<cfelse>
		<!---- look for top-level handler ---->
		<cfif fileExists(plugin.absoluteErrorTemplatePath & getToken(CFCATCH.type, 1, '.') & '.cfm')>
			<cfinclude template="#plugin.relativeErrorTemplatePath##getToken(CFCATCH.type, 1, '.')#.cfm" />
			<cftrace type="information" text="Custom type-based exception handler called (#plugin.absoluteErrorTemplatePath##getToken(CFCATCH.type,1,'.')#).">
		<cfelse>
			<!---- look for generic handler ---->
			<cfif fileExists(plugin.absoluteErrorTemplatePath & genericErrorTemplate & '.cfm')>
				<cfinclude template="#plugin.relativeErrorTemplatePath##genericErrorTemplate#.cfm" />
				<cftrace type="information" text="Custom generic exception handler called (#plugin.absoluteErrorTemplatePath##genericErrorTemplate#).">
			<cfelse>
				<!---- no custom template found to handle error ---->
				<cftrace type="information" text="Custom exception handler not found.">
				<cfrethrow />
			</cfif>
		</cfif>
	</cfif>
</cfcatch>
</cftry>
<cfcatch><cfrethrow></cfcatch>
</cftry>
<cfsetting enablecfoutputonly="false" />


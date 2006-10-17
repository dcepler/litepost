<!---
Fusebox Software License
Version 1.0

Copyright (c) 2003, 2004, 2005, 2006 The Fusebox Corporation. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted 
provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions 
   and the following disclaimer.

2. Redistributions in binary form or otherwise encrypted form must reproduce the above copyright 
   notice, this list of conditions and the following disclaimer in the documentation and/or other 
   materials provided with the distribution.

3. The end-user documentation included with the redistribution, if any, must include the following 
   acknowledgment:

   "This product includes software developed by the Fusebox Corporation (http://www.fusebox.org/)."

   Alternately, this acknowledgment may appear in the software itself, if and wherever such 
   third-party acknowledgments normally appear.

4. The names "Fusebox" and "Fusebox Corporation" must not be used to endorse or promote products 
   derived from this software without prior written (non-electronic) permission. For written 
   permission, please contact fusebox@fusebox.org.

5. Products derived from this software may not be called "Fusebox", nor may "Fusebox" appear in 
   their name, without prior written (non-electronic) permission of the Fusebox Corporation. For 
   written permission, please contact fusebox@fusebox.org.

If one or more of the above conditions are violated, then this license is immediately revoked and 
can be re-instated only upon prior written authorization of the Fusebox Corporation.

THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE FUSEBOX CORPORATION OR ITS CONTRIBUTORS BE LIABLE FOR ANY 
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-------------------------------------------------------------------------------

This software consists of voluntary contributions made by many individuals on behalf of the 
Fusebox Corporation. For more information on Fusebox, please see <http://www.fusebox.org/>.

--->
<cfcomponent output="false" hint="I represent a circuit.">
	
	<cffunction name="init" returntype="fuseboxCircuit" access="public" output="false" 
				hint="I am the constructor.">
		<cfargument name="fbApp" type="fuseboxApplication" required="true" 
					hint="I am the fusebox application object." />
		<cfargument name="alias" type="string" required="true" 
					hint="I am the circuit alias." />
		<cfargument name="path" type="string" required="true" 
					hint="I am the path from the application root to the circuit directory." />
		<cfargument name="parent" type="string" required="true" 
					hint="I am the alias of the parent circuit." />
		<cfargument name="myFusebox" type="myFusebox" required="true" 
					hint="I am the myFusebox data structure." />
		
		<cfset variables.fuseboxApplication = arguments.fbApp />
		<cfset variables.alias = arguments.alias />

		<cfset variables.fuseboxLexicon = variables.fuseboxApplication.getFuseactionFactory().getBuiltinLexicon() />
				
		<cfset variables.customAttributes = structNew() />
		
		<cfset variables.originalPath = arguments.path />
		<cfset this.parent = arguments.parent />
		<cfset variables.appPath = variables.fuseboxApplication.getApplicationRoot() />
		<cfset variables.lexicons = structNew() />
		
		<cfset variables.relativePath = replace(arguments.path,"\","/","all") />
		<cfif len(variables.relativePath) and right(variables.relativePath,1) is not "/">
			<cfset variables.relativePath = variables.relativePath & "/" />
		</cfif>
		<cfset this.path = variables.relativePath />
		<cfset variables.fullPath = variables.appPath & variables.relativePath />
		<!--- remove pairs of directory/../ to form canonical path: --->
		<cfloop condition="find('/../',variables.fullPath) gt 0">
			<cfset variables.fullPath = REreplace(variables.fullPath,"[^\.:/]*/\.\./","") />
		</cfloop>
		<cfset this.rootPath = variables.fuseboxApplication.relativePath(variables.fullPath,variables.appPath) />

		<cfset reload(arguments.myFusebox) />
				
		<cfreturn this />

	</cffunction>
	
	<cffunction name="reload" returntype="fuseboxCircuit" access="public" output="false" 
				hint="I reload the circuit file and build the in-memory structures from it.">
		<cfargument name="myFusebox" type="myFusebox" required="true" 
					hint="I am the myFusebox data structure." />

		<cfset var circuitFile = "circuit.xml.cfm" />
		<cfset var circuitXML = "" />
		<cfset var circuitCode = "" />
		<cfset var needToLoad = true />
		<cfset var circuitFiles = 0 />

		<cfif structKeyExists(this,"timestamp")>
			<cfdirectory action="list" directory="#variables.fullPath#" filter="circuit.xml*" name="circuitFiles" />
			<cfif circuitFiles.recordCount eq 1>
				<cfset needToLoad = parseDateTime(circuitFiles.dateLastModified) gt parseDateTime(this.timestamp) />
			<!--- else ignore the ambiguity --->
			</cfif>
		</cfif>

		<cfif needToLoad>
			<cfif variables.fuseboxApplication.debug>
				<cfset arguments.myFusebox.trace("Compiler","Loading #getAlias()# circuit.xml file") />
			</cfif>
			<!--- attempt to load circuit.xml(.cfm): --->
			<cfif not fileExists(variables.fullPath & circuitFile)>
				<cfset circuitFile = "circuit.xml" />
			</cfif>
			<cftry>
				
				<cffile action="read" file="#variables.fullPath##circuitFile#"
						variable="circuitXML"
						charset="#variables.fuseboxApplication.characterEncoding#" />
				<cfset variables.circuitPath = variables.fullPath & circuitFile />
				
				<cfcatch type="any">
					<cfif variables.fuseboxApplication.allowImplicitCircuits>
						<cfset circuitXML = "<circuit/>" />
					<cfelse>
						<cfthrow type="fusebox.missingCircuitXML" 
								message="missing circuit.xml" 
								detail="The circuit xml file, #circuitFile#, for circuit #getAlias()# could not be found."
								extendedinfo="#cfcatch.detail#" />
					</cfif>
				</cfcatch>
				
			</cftry>
			
			<cftry>
				
				<cfset circuitCode = xmlParse(circuitXML) />
				
				<cfcatch type="any">
					<cfthrow type="fusebox.circuitXMLError" 
							message="Error reading circuit.xml" 
							detail="A problem was encountered while reading the circuit file #circuitFile# for circuit #getAlias()#. This is usually caused by unmatched XML tag-pairs. Close all XML tags explicitly or use the / (slash) short-cut."
							extendedinfo="#cfcatch.detail#" />
				</cfcatch>
				
			</cftry>
	
			<cfif circuitCode.xmlRoot.xmlName is not "circuit">
				<cfthrow type="fusebox.badGrammar.badCircuitFile"
						detail="Circuit file does contain 'circuit' XML" 
						message="Circuit file #variables.circuitPath# does not contain 'circuit' as the root XML node." />
			</cfif>
			<cfif structKeyExists(circuitCode.xmlRoot.xmlAttributes,"access")>
				<cfif listFind("private,internal,public",circuitCode.xmlRoot.xmlAttributes.access) eq 0>
					<cfthrow type="fusebox.badGrammar.illegalAccess"
							message="Circuit access illegal"
							detail="The 'access' value '#circuitCode.xmlRoot.xmlAttributes.access#' is illegal in Circuit #getAlias()#. 'private', 'internal' or 'public' are the only legal values." />
				</cfif>
				<cfset this.access = circuitCode.xmlRoot.xmlAttributes.access />
			<cfelse>
				<cfset this.access = "internal" />
			</cfif>
			<cfif structKeyExists(circuitCode.xmlRoot.xmlAttributes,"permissions")>
				<cfset this.permissions = circuitCode.xmlRoot.xmlAttributes.permissions />
			<cfelse>
				<cfset this.permissions = "" />
			</cfif>
	
			<cfset loadLexicons(circuitCode) />		
			<cfset loadPreAndPostFuseactions(circuitCode) />
			<cfset loadFuseactions(circuitCode) />
			<cfset variables.circuitFile = circuitFile />
			<cfset this.timestamp = now() />
		</cfif>
		
		<cfreturn this />
		
	</cffunction>

	<cffunction name="compile" returntype="void" access="public" output="false" 
				hint="I compile a given fuseaction within this circuit.">
		<cfargument name="writer" type="any" required="false" 
					hint="I am the parsed file writer object. I am required but it's faster to specify that I am not required." />
		<cfargument name="fuseaction" type="any" required="false" 
					hint="I am the name of the fuseaction to compile. I am required but it's faster to specify that I am not required." />
	
		<cfset var f = arguments.writer.setFuseaction(arguments.fuseaction) />
		<cfset var i = 0 />
		<cfset var n = 0 />

		<cfset compilePreOrPostFuseaction(arguments.writer,"pre") />
		
		<cfif not structKeyExists(this.fuseactions,arguments.fuseaction)>
			<cfthrow type="fusebox.undefinedFuseaction" 
					message="undefined Fuseaction" 
					detail="You specified a Fuseaction of #arguments.fuseaction# which is not defined in Circuit #getAlias()#." />
		</cfif>
		<cfset this.fuseactions[arguments.fuseaction].compile(arguments.writer) />
		
		<cfset compilePreOrPostFuseaction(arguments.writer,"post") />

		<cfset arguments.writer.setFuseaction(f) />
		
	</cffunction>
	
	<cffunction name="compilePreOrPostFuseaction" returntype="void" access="public" output="false" 
				hint="I compile the pre/post-fuseaction for a circuit.">
		<cfargument name="writer" type="any" required="false" 
					hint="I am the parsed file writer object. I am required but it's faster to specify that I am not required." />
		<cfargument name="preOrPost" type="string" required="false" 
					hint="I am either 'pre' or 'post' to indicate whether this is a prefuseaction or a postfuseaction. I am required but it's faster to specify that I am not required." />
	
		<cfset var c = "" />

		<cfif variables.hasAction[arguments.preOrPost]>
			<cfif arguments.preOrPost is "pre" and variables.callsuper["pre"] and hasParent()>
				<cfset getParent().compilePreOrPostFuseaction(arguments.writer,arguments.preOrPost) />
			</cfif>
			<cfset c = arguments.writer.setCircuit(getAlias()) />
			<cfset variables.action[arguments.preOrPost].compile(arguments.writer) />
			<cfset arguments.writer.setCircuit(c) />
			<cfif arguments.preOrPost is "post" and variables.callsuper["post"] and hasParent()>
				<cfset getParent().compilePreOrPostFuseaction(arguments.writer,arguments.preOrPost) />
			</cfif>
		</cfif>
	
	</cffunction>
	
	<cffunction name="buildCircuitTrace" returntype="void" access="public" output="false" 
				hint="I build the 'circuit trace' structure - the array of parents. Required for Fusebox 4.1 compatibility.">
	
		<cfset var c = getParentName() />
		<cfset var seen = structNew() />
		
		<cfset seen[getAlias()] = true />
		<cfset this.circuitTrace = arrayNew(1) />
		<cfset arrayAppend(this.circuitTrace,getAlias()) />
		<cfloop condition="c is not ''">
			<cfif structKeyExists(seen,c)>
				<cfthrow type="fusebox.badGrammar.circularParent" 
						message="Circular parent for Circuit" 
						detail="You specified a parent Circuit of #c# (for Circuit #getAlias()#) which creates a circular dependency." />
			</cfif>
			<cfset seen[c] = true />
			<cfif not structKeyExists(variables.fuseboxApplication.circuits,c)>
				<cfthrow type="fusebox.undefinedCircuit" 
						message="undefined Circuit" 
						detail="You specified a parent Circuit of #c# (for Circuit #getAlias()#) which is not defined." />
			</cfif>
			<cfset arrayAppend(this.circuitTrace,c) />
			<cfset c = variables.fuseboxApplication.circuits[c].getParentName() />
		</cfloop>
		
	</cffunction>
	
	<cffunction name="getOriginalPath" returntype="string" access="public" output="false" 
				hint="I return the original relative path specified in the circuit declaration.">
	
		<cfreturn variables.originalPath />
	
	</cffunction>
	
	<cffunction name="getCircuitRoot" returntype="string" access="public" output="false" 
				hint="I return the full file system path to the circuit directory.">
	
		<cfreturn variables.fullPath />
	
	</cffunction>

	<cffunction name="getCircuitXMLFilename" returntype="string" access="public" output="false" 
				hint="I return the actual name of the circuit XML file: circuit.xml or circuit.xml.cfm.">
	
		<cfreturn variables.circuitFile />
	
	</cffunction>

	<cffunction name="getParentName" returntype="string" access="public" output="false" 
				hint="I return the name (alias) of this circuit's parent.">
	
		<cfreturn this.parent />
	
	</cffunction>

	<cffunction name="hasParent" returntype="boolean" access="public" output="false" 
				hint="I return true if this circuit has a parent, otherwise I return false.">
	
		<cfreturn getParentName() is not "" />
	
	</cffunction>

	<cffunction name="getParent" returntype="any" access="public" output="false" 
				hint="I return this circuit's parent circuit object. I throw an exception if hasParent() returns false.">
	
		<!---
			note that this will throw an exception if the circuit has no parent
			code should call hasParent() first
		--->
		<cfreturn variables.fuseboxApplication.circuits[getParentName()] />
	
	</cffunction>

	<cffunction name="getPermissions" returntype="string" access="public" output="false" 
				hint="I return the aggregated permissions for this circuit.">
		<cfargument name="useCircuitTrace" type="boolean" default="false" 
					hint="I indicate whether or not to inherit the parent circuit's permissions if this circuit has no permissions specified." />
	
		<cfif this.permissions is "" and arguments.useCircuitTrace and hasParent()>
			<cfreturn getParent().getPermissions(arguments.useCircuitTrace) />
		<cfelse>
			<cfreturn this.permissions />
		</cfif>
	
	</cffunction>
	
	<cffunction name="getRelativePath" returntype="string" access="public" output="false" 
				hint="I return the normalized relative path from the application root to this circuit's directory.">
	
		<cfreturn variables.relativePath />
	
	</cffunction>
	
	<cffunction name="getFuseactions" returntype="struct" access="public" output="false" 
				hint="I return the structure containing the definitions of the fuseactions within this circuit.">
		
		<cfreturn this.fuseactions /> 
		
	</cffunction>
	
	<cffunction name="getLexiconDefinition" returntype="any" access="public" output="false" 
				hint="I return the definition of the specified lexicon.">
		<cfargument name="namespace" type="any" required="false" 
					hint="I am the namespace whose lexicon is to be retrieved. I am required but it's faster to specify that I am not required." />
		
		<cfif arguments.namespace is variables.fuseboxLexicon.namespace>
			<cfreturn variables.fuseboxLexicon />
		<cfelse>
			<cfreturn variables.lexicons[arguments.namespace] />
		</cfif>

	</cffunction>
	
	<cffunction name="getAccess" returntype="any" access="public" output="false" 
				hint="I return the access specified for this circuit.">
	
		<cfreturn this.access />
	
	</cffunction>
	
	<cffunction name="getAlias" returntype="any" access="public" output="false" 
				hint="I return the circuit alias.">
	
		<cfreturn variables.alias />
	
	</cffunction>
	
	<cffunction name="getApplication" returntype="any" access="public" output="false" 
				hint="I return the fusebox application object.">
	
		<cfreturn variables.fuseboxApplication />
	
	</cffunction>
	
	<cffunction name="getCustomAttributes" returntype="struct" access="public" output="false" 
				hint="I return any custom attributes for the specified namespace prefix.">
		<cfargument name="ns" type="string" required="true" 
					hint="I am the namespace for which to return custom attributes." />
		
		<cfif structKeyExists(variables.customAttributes,arguments.ns)>
			<!--- we structCopy() this so folks can't poke values back into the metadata! --->
			<cfreturn structCopy(variables.customAttributes[arguments.ns]) />
		<cfelse>
			<cfreturn structNew() />
		</cfif>
		
	</cffunction>
	
	<cffunction name="loadLexicons" returntype="void" access="private" output="false" 
				hint="I load the lexicon definitions and custom attributes out of the namespace declarations in the circuit tag.">
		<cfargument name="circuitCode" type="any" required="true" 
					hint="I am the XML representation of the circuit file." />
		
		<cfset var attributes = circuitCode.xmlRoot.xmlAttributes />
		<cfset var attr = "" />
		<cfset var aLex = "" />
		<cfset var ns = "" />
		<cfset var strict = variables.fuseboxApplication.strictMode />
		
		<!--- pass 1: pull out any namespace declarations --->
		<cfloop collection="#attributes#" item="attr">
			<cfif len(attr) gt 6 and left(attr,6) is "xmlns:">
				<!--- found a namespace declaration, pull it out: --->
				<cfset aLex = structNew() />
				<cfset aLex.namespace = listLast(attr,":") />
				<cfif aLex.namespace is variables.fuseboxLexicon.namespace>
					<cfthrow type="fusebox.badGrammar.reservedName"
							message="Attempt to use reserved namespace" 
							detail="You have attempted to declare a namespace '#aLex.namespace#' (in Circuit #getAlias()#) which is reserved by the Fusebox framework." />
				</cfif>
				<cfset aLex.path = variables.fuseboxApplication.getCoreToAppRootPath() & variables.fuseboxApplication.lexiconPath & attributes[attr] />
				<cfset variables.lexicons[aLex.namespace] = aLex />
				<cfset variables.customAttributes[aLex.namespace] = structNew() />
			</cfif>
		</cfloop>
		
		<!--- pass 2: pull out any custom attributes --->
		<cfloop collection="#attributes#" item="attr">
			<cfif listLen(attr,":") eq 2>
				<!--- looks like a custom attribute: --->
				<cfset ns = listFirst(attr,":") />
				<cfif ns is "xmlns">
					<!--- special case - need to ignore xmlns:foo="bar" --->
				<cfelseif structKeyExists(variables.customAttributes,ns)>
					<cfset variables.customAttributes[ns][listLast(attr,":")] = attributes[attr] />
				<cfelse>
					<cfthrow type="fusebox.badGrammar.undeclaredNamespace" 
							message="Undeclared lexicon namespace" 
							detail="The lexicon prefix '#ns#' was found on a custom attribute in the <circuit> tag of Circuit #getAlias()# but no such lexicon namespace has been declared." />
				</cfif>
			<cfelseif strict and listFind("access,permissions",attr) eq 0>
				<cfthrow type="fusebox.badGrammar.unexpectedAttributes"
						message="Unexpected attributes"
						detail="Unexpected attributes were found in the 'circuit' tag of the '#getAlias()#' circuit.xml file." />
			</cfif>
		</cfloop>
				
	</cffunction>
	
	<cffunction name="loadPreAndPostFuseactions" returntype="void" access="private" output="false" 
				hint="I load the prefuseaction and postfuseaction definitions from the circuit file.">
		<cfargument name="circuitCode" type="any" required="true" 
					hint="I am the XML representation of the circuit file." />
		
		<cfset variables.hasAction = structNew() />
		<cfset variables.action = structNew() />
		<cfset variables.callsuper = structNew() />
		<cfset loadPrePostFuseaction(arguments.circuitCode,"pre") />
		<cfset loadPrePostFuseaction(arguments.circuitCode,"post") />
				
	</cffunction>
	
	<cffunction name="loadPrePostFuseaction" returntype="void" access="private" output="false" 
				hint="I load the either a prefuseaction or a postfuseaction definition from the circuit file.">
		<cfargument name="circuitCode" type="any" required="true" 
					hint="I am the XML representation of the circuit file." />
		<cfargument name="prePost" type="string" required="true" 
					hint="I specify whether to load a 'pre'fuseaction or a 'post'fuseaction." />
		
		<cfset var children = xmlSearch(arguments.circuitCode,"/circuit/#arguments.prePost#fuseaction") />
		<cfset var i = 0 />
		<cfset var n = arrayLen(children) />
		<cfset var nAttrs = 0 />
		
		<cfif n eq 0>
			<cfset variables.hasAction[arguments.prePost] = false />
		<cfelseif n eq 1>
			<cfset variables.hasAction[arguments.prePost] = true />
			<cfif structKeyExists(children[1].xmlAttributes,"callsuper")>
				<cfif listFind("true,false",children[1].xmlAttributes.callsuper) eq 0>
					<cfthrow type="fusebox.badGrammar.invalidAttributeValue"
							message="Attribute has invalid value" 
							detail="The attribute 'callsuper' must either be ""true"" or ""false"", for a '#arguments.prePost#fuseaction' in Circuit #getAlias()#." />
				</cfif>
				<cfset nAttrs = 1 />
				<cfset variables.callsuper[arguments.prePost] = children[1].xmlAttributes.callsuper />
			<cfelse>
				<cfset variables.callsuper[arguments.prePost] = false />
			</cfif>
			<cfif variables.fuseboxApplication.strictMode and structCount(children[1].xmlAttributes) neq nAttrs>
				<cfthrow type="fusebox.badGrammar.unexpectedAttributes"
						message="Unexpected attributes"
						detail="Unexpected attributes found on '#arguments.prePost#fuseaction' in Circuit #getAlias()#." />
			</cfif>
			<cfset variables.action[arguments.prePost] =
					createObject("component","fuseboxAction")
						.init(this,
							"$#arguments.prePost#fuseaction",
								"internal",
									children[1].xmlChildren) />
		<cfelse>
			<cfthrow type="fusebox.badGrammar.nonUniqueDeclaration" 
					message="Declaration was not unique" 
					detail="More than one &lt;#arguments.prePost#fuseaction&gt; declaration was found in Circuit #getAlias()#." />
		</cfif>
		
	</cffunction>
	
	<cffunction name="loadFuseactions" returntype="void" access="private" output="false" 
				hint="I load all of the fuseaction definitions from the circuit file.">
		<cfargument name="circuitCode" type="any" required="true" 
					hint="I am the XML representation of the circuit file." />
		
		<cfset var children = xmlSearch(arguments.circuitCode,"/circuit/fuseaction") />
		<cfset var i = 0 />
		<cfset var n = arrayLen(children) />
		<cfset var attribs = 0 />
		<cfset var attr = "" />
		<cfset var ns = "" />
		<cfset var customAttribs = 0 />
		<cfset var access = "" />
		<cfset var permissions = "" />
		<cfset var strict = variables.fuseboxApplication.strictMode />
		
		<cfset this.fuseactions = structNew() />
		<cfloop from="1" to="#n#" index="i">
			<!--- default fuseaction access to circuit access --->
			<cfset access = this.access />
			<cfset attribs = children[i].xmlAttributes />
			
			<cfif not structKeyExists(attribs,"name")>
				<cfthrow type="fusebox.badGrammar.requiredAttributeMissing"
						message="Required attribute is missing"
						detail="The attribute 'name' is required, for a 'fuseaction' declaration in circuit #getAlias()#." />
			</cfif>

			<!--- scan for custom attributes --->
			<cfset customAttribs = structNew() />
			<cfloop collection="#attribs#" item="attr">

				<cfswitch expression="#attr#">
				<cfcase value="name">
					<cfif structKeyExists(this.fuseactions,attribs.name)>
						<cfthrow type="fusebox.overloadedFuseaction" 
								message="overloaded Fuseaction" 
								detail="You referenced a fuseaction, #attribs.name#, which has been defined multiple times in circuit #getAlias()#. Fusebox does not allow overloaded methods." />
					</cfif>
				</cfcase>
				<cfcase value="access">
					<cfset access = attribs.access />
					<cfif listFind("private,internal,public",access) eq 0>
						<cfthrow type="fusebox.badGrammar.illegalAccess"
								message="Fuseaction access illegal"
								detail="The 'access' value '#access#' is illegal on Fuseaction #attribs.name# in Circuit #getAlias()#. 'private', 'internal' or 'public' are the only legal values." />
					</cfif>
				</cfcase>
				<cfcase value="permissions">
					<cfset permissions = attribs.permissions />
				</cfcase>
				<cfdefaultcase>
					<cfif listLen(attr,":") eq 2>
						<!--- looks like a custom attribute: --->
						<cfset ns = listFirst(attr,":") />
						<cfif structKeyExists(variables.customAttributes,ns)>
							<cfset customAttribs[ns][listLast(attr,":")] = attribs[attr] />
						<cfelse>
							<cfthrow type="fusebox.badGrammar.undeclaredNamespace" 
									message="Undeclared lexicon namespace" 
									detail="The lexicon prefix '#ns#' was found on a custom attribute in the Fuseaction #attribs.name# in Circuit #getAlias()# but no such lexicon namespace has been declared." />
						</cfif>
	
					<cfelseif strict>
						<cfthrow type="fusebox.badGrammar.unexpectedAttributes"
								message="Unexpected attributes"
								detail="Unexpected attribute '#attr#' found on Fuseaction #attribs.name# in Circuit #getAlias()#." />
					</cfif>
				</cfdefaultcase>
				</cfswitch>
			</cfloop>

			<cfset this.fuseactions[attribs.name] =
					createObject("component","fuseboxAction")
						.init(this,attribs.name,access,children[i].xmlChildren,false,customAttribs) />
			<!--- FB41 security plugin compatibility: --->
			<cfset this.fuseactions[attribs.name].permissions = permissions />
		</cfloop>
		
	</cffunction>
	
</cfcomponent>
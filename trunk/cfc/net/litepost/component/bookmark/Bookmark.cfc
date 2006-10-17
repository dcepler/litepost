<!--- 
	  
  Copyright (c) 2006, Chris Scott, Matt Woodward, Adam Wayne Lehman, Dave Ross
  All rights reserved.
	
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
       http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

  $Id$

--->

<cfcomponent displayname="Bookmark"
	output="false" hint="A bean which models the Bookmark form.">

<!--- This bean was generated by the Rooibos Generator with the following template:
Bean Name: Bookmark
Path to Bean: net.litepost.component.category.Bookmark
Extends: 
Call super.init(): false
Create cfproperties: false
Bean Template:
	bookmarkID Numeric 
	name String 
	url String 
Create getMemento method: false
Create setMemento method: false
Create setStepInstance method: false
Create validate method: false
Create validate interior: false
Date Format: MM/DD/YYYY
--->

	<!---
	PROPERTIES
	--->
	<cfset variables.instance = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="net.litepost.component.bookmark.Bookmark" output="false">
		<cfargument name="bookmarkID" type="Numeric" required="false" default="0" />
		<cfargument name="name" type="String" required="false" default="" />
		<cfargument name="url" type="String" required="false" default="" />

		<!--- run setters --->
		<cfset setBookmarkID(arguments.bookmarkID) />
		<cfset setName(arguments.name) />
		<cfset setUrl(arguments.url) />

		<cfreturn this />
 	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setBookmarkID" access="public" returntype="void" output="false">
		<cfargument name="bookmarkID" type="Numeric" required="true" />
		<cfset variables.instance.bookmarkID = arguments.bookmarkID />
	</cffunction>
	<cffunction name="getBookmarkID" access="public" returntype="Numeric" output="false">
		<cfreturn variables.instance.bookmarkID />
	</cffunction>

	<cffunction name="setName" access="public" returntype="void" output="false">
		<cfargument name="name" type="String" required="true" />
		<cfset variables.instance.name = arguments.name />
	</cffunction>
	<cffunction name="getName" access="public" returntype="String" output="false">
		<cfreturn variables.instance.name />
	</cffunction>

	<cffunction name="setUrl" access="public" returntype="void" output="false">
		<cfargument name="url" type="String" required="true" />
		<cfset variables.instance.url = arguments.url />
	</cffunction>
	<cffunction name="getUrl" access="public" returntype="String" output="false">
		<cfreturn variables.instance.url />
	</cffunction>

</cfcomponent>
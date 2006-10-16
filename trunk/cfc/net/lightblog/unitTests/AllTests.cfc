<cfcomponent name="AllTests" extends="org.cfcunit.Object" output="false" hint="Runs all unit tests in package.">

	<cffunction name="suite" returntype="org.cfcunit.framework.Test" access="public" output="false" hint="">
		<cfset var testSuite = newObject("org.cfcunit.framework.TestSuite").init("All LightBlog Tests")>

		<cfset testSuite.addTestSuite(newObject("net.lightblog.unitTests.SimpleFactoryTest"))>
		<cfset testSuite.addTestSuite(newObject("net.lightblog.unitTests.BookmarkCategoryTests"))>
		<cfset testSuite.addTestSuite(newObject("net.lightblog.unitTests.EntryCommentsTests"))>
		
		<cfreturn testSuite/>
	</cffunction>	

</cfcomponent>
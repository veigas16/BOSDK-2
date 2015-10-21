<%@page import="com.crystaldecisions.sdk.plugin.authentication.enterprise.IsecEnterprise" %>
<%@page import="com.crystaldecisions.sdk.plugin.authentication.ldap.IsecLDAP" %>
<%@page import="com.crystaldecisions.sdk.framework.IEnterpriseSession" %>
<%@page import="com.crystaldecisions.sdk.framework.ISessionMgr" %>
<%@page import="com.crystaldecisions.sdk.framework.ITrustedPrincipal" %>
<%@page import="com.crystaldecisions.sdk.occa.security.IEnterpriseLogonInformation" %>
<%@page import="com.crystaldecisions.sdk.occa.security.ILogonTokenMgr" %>
<%@page import="com.crystaldecisions.sdk.framework.CrystalEnterprise" %>
<%@page import="com.crystaldecisions.sdk.exception.SDKException" %>
<%@ page import="com.crystaldecisions.sdk.occa.infostore.IInfoStore" %>
<%@ page import="com.crystaldecisions.sdk.occa.security.IUserInfo" %>
<%@ page import="com.crystaldecisions.sdk.occa.infostore.CeSecurityID" %>
<%@ page import="com.crystaldecisions.sdk.occa.infostore.IInfoObjects" %>
<%@ page import="com.crystaldecisions.sdk.occa.infostore.IInfoObject" %>
<%@ page import="com.crystaldecisions.sdk.plugin.desktop.server.IServer"%>
<%@ page import="com.businessobjects.rebean.wi.ReportEngines" %>
<%@ page import="com.businessobjects.rebean.wi.ReportEngine" %>
<%@ page import="com.businessobjects.rebean.wi.DocumentInstance" %>
<%@ page import="com.businessobjects.rebean.wi.DataProviders" %>
<%@ page import="com.businessobjects.rebean.wi.DataProvider" %>
<%@ page import="com.businessobjects.rebean.wi.Query" %>
<%@ page import="com.businessobjects.rebean.wi.DataSource" %>
<%@ page import="com.crystaldecisions.sdk.plugin.CeKind" %>



<%
	//Authentification innformation
	String user = "Administrator";
	String pwd = "Manager00";
	String CMS = "AS1-300-61:6400";
	String auth = "secEnterprise";
	
	//Session manager to make the connection with SAP BO
	ISessionMgr sessionManager = CrystalEnterprise.getSessionMgr();
	IEnterpriseSession enterpriseSession = sessionManager.logon(user, pwd, CMS, auth);
	
	IUserInfo userInfo = null;
	userInfo = enterpriseSession.getUserInfo();	    
	
	ReportEngines reportEngines = null;
	ReportEngine wiRepEngine = null;

	ILogonTokenMgr iLManager = enterpriseSession.getLogonTokenMgr();
	reportEngines = (ReportEngines)session.getAttribute("ReportEngines");
	
	//Create a new ReportEngines to create our new document
	reportEngines = (ReportEngines)enterpriseSession.getService("ReportEngines");
	wiRepEngine = reportEngines.getService(ReportEngines.ReportEngineType.WI_REPORT_ENGINE);
	
	//Locate the desired universe that is going to be used on the document
	IInfoStore infoStore = (IInfoStore) enterpriseSession.getService("InfoStore");
	String unvQuery = "select * from CI_APPOBJECTS where SI_KIND = 'DSL.MetaDataFile' and SI_NAME like '%Sinistro Painel_SAP%'";
	IInfoObjects infoObjects = (IInfoObjects) infoStore.query(unvQuery);
	IInfoObject infoObject = (IInfoObject)infoObjects.get(0); 
	
	//Create document Instance. This document instance can be modified to add styling or content.
	DocumentInstance documentInstance = wiRepEngine.newDocument("UnivCUID="+infoObject.getCUID());
	
	//Locate the Target folder where the new document its going to be saved
	String folderQuery = "select * from CI_INFOOBJECTS where SI_KIND = 'Folder' and SI_NAME='Porto_Seguro'";
	infoObjects = (IInfoObjects) infoStore.query(folderQuery);
	infoObject = (IInfoObject)infoObjects.get(0); 
			
	//Save the document to target
	documentInstance.saveAs("Test", infoObject.getID(), null, null, true);
	documentInstance.closeDocument();	
	
	enterpriseSession.logoff();
%>

<%=
	"Finalized!"
%>


<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="com.businessobjects.rebean.wi.BinaryView" %>
<%@ page import="com.businessobjects.rebean.wi.CSVView" %>
<%@ page import="com.businessobjects.rebean.wi.DocumentInstance" %>
<%@ page import="com.businessobjects.rebean.wi.HTMLView" %>
<%@ page import="com.businessobjects.rebean.wi.OutputFormatType" %>
<%@ page import="com.businessobjects.rebean.wi.PaginationMode" %>
<%@ page import="com.businessobjects.rebean.wi.Prompt" %>
<%@ page import="com.businessobjects.rebean.wi.Prompts" %>
<%@ page import="com.businessobjects.rebean.wi.Report" %>
<%@ page import="com.businessobjects.rebean.wi.ReportEngine" %>
<%@ page import="com.businessobjects.rebean.wi.ReportEngines" %>
<%@ page import="com.businessobjects.rebean.wi.Reports" %>
<%@ page import="com.crystaldecisions.sdk.exception.SDKException" %>
<%@ page import="com.crystaldecisions.sdk.framework.CrystalEnterprise" %>
<%@ page import="com.crystaldecisions.sdk.framework.IEnterpriseSession" %>
<%@ page import="com.crystaldecisions.sdk.framework.ISessionMgr" %>
<%@ page import="com.crystaldecisions.sdk.occa.infostore.IInfoObject" %>
<%@ page import="com.crystaldecisions.sdk.occa.infostore.IInfoObjects" %>
<%@ page import="com.crystaldecisions.sdk.occa.infostore.IInfoStore" %>
<%@ page import="com.crystaldecisions.sdk.occa.security.IUserInfo" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.FileOutputStream" %>
<%@ page import="java.io.IOException" %>


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

	//Create Report Engine instance
	ReportEngines reportEngines = (ReportEngines) enterpriseSession.getService("ReportEngines");
	ReportEngine reportEngine = (ReportEngine) reportEngines.getService(ReportEngines.ReportEngineType.WI_REPORT_ENGINE);

	//Retrieve webi reports on SAP BO
	IInfoStore infoStore = (IInfoStore) enterpriseSession.getService("InfoStore");
	String query = "select * from CI_INFOOBJECTS where SI_KIND = 'Webi'";
	IInfoObjects infoObjects = (IInfoObjects) infoStore.query(query);
	IInfoObject infoObject = (IInfoObject)infoObjects.get(0); 

	String title = infoObject.getTitle();

	//Create document instance
	DocumentInstance doc = reportEngine.openDocument(infoObject.getID());

	doc.refresh();

	//Format to PDF
	BinaryView binaryView2 = (BinaryView)doc.getView(OutputFormatType.PDF);
	response.setContentType("application/pdf"); 
	response.setHeader("Content-Type", "application/pdf"); 
	response.setDateHeader("expires", 0); 
	binaryView2.getContent(response.getOutputStream()); 
	
	doc.closeDocument();	

	reportEngines.close();
	enterpriseSession.logoff();
%>

<%!
public static File writeBytes(byte[] data, String filename) throws IOException{
		File file = new File(filename); 
		FileOutputStream fstream = new FileOutputStream(file); 
		fstream.write(data); 
		fstream.close();
		return file;
}
%>

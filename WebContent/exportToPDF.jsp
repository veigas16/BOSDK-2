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
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.FileOutputStream" %>
<%@ page import="org.apache.commons.httpclient.HttpClient" %>
<%@ page import="org.apache.commons.httpclient.auth.AuthScope" %>
<%@ page import="org.apache.commons.httpclient.methods.PostMethod" %>
<%@ page import="org.apache.commons.httpclient.methods.multipart.FilePart" %>
<%@ page import="org.apache.commons.httpclient.methods.multipart.MultipartRequestEntity" %>
<%@ page import="org.apache.commons.httpclient.methods.multipart.Part" %>
<%@ page import="org.apache.commons.httpclient.methods.multipart.StringPart" %>
<%@ page import="org.apache.commons.httpclient.Credentials" %>
<%@ page import="org.apache.commons.httpclient.HttpClient" %>
<%@ page import="org.apache.commons.httpclient.HttpException" %>
<%@ page import="org.apache.commons.httpclient.HttpStatus" %>
<%@ page import="org.apache.commons.httpclient.UsernamePasswordCredentials" %>
<%@ page import="org.apache.commons.httpclient.methods.GetMethod" %>
<%@ page import="org.apache.commons.httpclient.Credentials" %>
<%@ page import="org.apache.commons.httpclient.HttpClient" %>
<%@ page import="org.apache.commons.httpclient.HttpStatus" %>
<%@ page import="org.apache.commons.httpclient.NTCredentials" %>
<%@ page import="org.apache.commons.httpclient.UsernamePasswordCredentials" %>
<%@ page import="org.apache.commons.httpclient.auth.AuthScheme" %>
<%@ page import="org.apache.commons.httpclient.auth.CredentialsNotAvailableException" %>
<%@ page import="org.apache.commons.httpclient.auth.CredentialsProvider" %>
<%@ page import="org.apache.commons.httpclient.auth.NTLMScheme" %>
<%@ page import="org.apache.commons.httpclient.auth.RFC2617Scheme" %>
<%@ page import="org.apache.commons.httpclient.methods.GetMethod" %>

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
	File pdf = writeBytes(binaryView2.getContent(), title + ".pdf");	
	
	String alfrescoTiccketURL = "http://172.18.23.64:8080/alfresco" + "/service/api/login?u=" + "admin" + "&pw=" + "admin";
	String ticketURLResponse = getTicket(alfrescoTiccketURL);
	
	uploadDocument(ticketURLResponse, pdf, title + ".pdf", "application/pdf", "description", "workspace://SpacesStore/60273b3a-b9f2-42d9-bc2d-9697246bdacd");
	
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

<%!
public static void uploadDocument(String authTicket, File fileobj,
	String filename, String filetype, String description,
	String destination) {
	try {

		String urlString = "http://172.18.23.64:8080/alfresco/service/api/upload?alf_ticket=" + authTicket;
		System.out.println("The upload url:::" + urlString);
		HttpClient client = new HttpClient();
		PostMethod mPost = new PostMethod(urlString);

		Part[] parts = {
			new FilePart("filedata", filename, fileobj, filetype, null),
			new StringPart("filename", filename),
			new StringPart("description", description),
			new StringPart("destination", destination),
			new StringPart("description", description),
		};
		mPost.setRequestEntity(new MultipartRequestEntity(parts, mPost.getParams()));
		int statusCode1 = client.executeMethod(mPost);
		System.out.println("statusLine>>>" + statusCode1 + "......" + "\n status line \n" + mPost.getStatusLine() + "\nbody \n" + mPost.getResponseBodyAsString());
		mPost.releaseConnection();
	} catch (Exception e) {
		System.out.println(e);
	}
}
%>

<%!
	public String getTicket(String url) throws IOException {

		HttpClient client = new HttpClient();
		client.getParams().setParameter(CredentialsProvider.PROVIDER, new ConsoleAuthPrompter());
		GetMethod httpget = new GetMethod(url);
		httpget.setDoAuthentication(true);

		String response = null;
		String ticketURLResponse = null;

		try {
			int status = client.executeMethod(httpget);

			if (status != HttpStatus.SC_OK) {
				System.err.println("Method failed: " + httpget.getStatusLine());
			}

			response = new String(httpget.getResponseBodyAsString());
			System.out.println("response = " + response);

			int startindex = response.indexOf("_") -6;
			int endindex = response.indexOf("/") -1;
			ticketURLResponse = response.substring(startindex, endindex);
			System.out.println("ticket = " + ticketURLResponse);

		} finally {
			httpget.releaseConnection();
		}
		return ticketURLResponse;
	}
%>

<%!
	public class ConsoleAuthPrompter implements CredentialsProvider {

		private BufferedReader in = null;
		public ConsoleAuthPrompter() {
			super();
			this. in = new BufferedReader(new InputStreamReader(System. in ));
		}

		private String readConsole() throws IOException {
			return this. in .readLine();
		}

		public Credentials getCredentials(
		final AuthScheme authscheme,
		final String host,
		int port,
		boolean proxy)
		throws CredentialsNotAvailableException {
			if (authscheme == null) {
				return null;
			}
			try {
				if (authscheme instanceof NTLMScheme) {
					System.out.println(host + ":" + port + " requires Windows authentication");
					System.out.print("Enter domain: ");
					String domain = readConsole();
					System.out.print("Enter username: ");
					String user = readConsole();
					System.out.print("Enter password: ");
					String password = readConsole();
					return new NTCredentials(user, password, host, domain);
				} else if (authscheme instanceof RFC2617Scheme) {
					System.out.println(host + ":" + port + " requires authentication with the realm '" + authscheme.getRealm() + "'");
					System.out.print("Enter username: ");
					String user = readConsole();
					System.out.print("Enter password: ");
					String password = readConsole();
					return new UsernamePasswordCredentials(user, password);
				} else {
					throw new CredentialsNotAvailableException("Unsupported authentication scheme: " + authscheme.getSchemeName());
				}
			} catch (IOException e) {
				throw new CredentialsNotAvailableException(e.getMessage(), e);
			}
		}
	}
%>



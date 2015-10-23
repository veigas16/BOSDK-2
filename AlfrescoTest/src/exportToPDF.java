import com.businessobjects.rebean.wi.BinaryView;
import com.businessobjects.rebean.wi.CSVView;
import com.businessobjects.rebean.wi.DocumentInstance;
import com.businessobjects.rebean.wi.HTMLView;
import com.businessobjects.rebean.wi.OutputFormatType;
import com.businessobjects.rebean.wi.PaginationMode;
import com.businessobjects.rebean.wi.Prompt;
import com.businessobjects.rebean.wi.Prompts;
import com.businessobjects.rebean.wi.Report;
import com.businessobjects.rebean.wi.ReportEngine;
import com.businessobjects.rebean.wi.ReportEngines;
import com.businessobjects.rebean.wi.Reports;
import com.crystaldecisions.sdk.exception.SDKException;
import com.crystaldecisions.sdk.framework.CrystalEnterprise;
import com.crystaldecisions.sdk.framework.IEnterpriseSession;
import com.crystaldecisions.sdk.framework.ISessionMgr;
import com.crystaldecisions.sdk.occa.infostore.IInfoObject;
import com.crystaldecisions.sdk.occa.infostore.IInfoObjects;
import com.crystaldecisions.sdk.occa.infostore.IInfoStore;
import com.crystaldecisions.sdk.occa.security.IUserInfo;
import java.io.File;
import java.io.BufferedReader;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;
import java.io.FileOutputStream;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.auth.AuthScope;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.httpclient.methods.multipart.FilePart;
import org.apache.commons.httpclient.methods.multipart.MultipartRequestEntity;
import org.apache.commons.httpclient.methods.multipart.Part;
import org.apache.commons.httpclient.methods.multipart.StringPart;
import org.apache.commons.httpclient.Credentials;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpException;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.UsernamePasswordCredentials;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.Credentials;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.NTCredentials;
import org.apache.commons.httpclient.UsernamePasswordCredentials;
import org.apache.commons.httpclient.auth.AuthScheme;
import org.apache.commons.httpclient.auth.CredentialsNotAvailableException;
import org.apache.commons.httpclient.auth.CredentialsProvider;
import org.apache.commons.httpclient.auth.NTLMScheme;
import org.apache.commons.httpclient.auth.RFC2617Scheme;
import org.apache.commons.httpclient.methods.GetMethod;

public class exportToPDF {
	public static void main(String[] args) {
		try
		{
		// Authentification innformation
		String user = "Administrator";
		String pwd = "Manager00";
		String CMS = "AS1-300-61:6400";
		String auth = "secEnterprise";

		// Session manager to make the connection with SAP BO
		ISessionMgr sessionManager = CrystalEnterprise.getSessionMgr();
		IEnterpriseSession enterpriseSession = sessionManager.logon(user, pwd, CMS, auth);

		IUserInfo userInfo = null;
		userInfo = enterpriseSession.getUserInfo();

		// Create Report Engine instance
		ReportEngines reportEngines = (ReportEngines) enterpriseSession.getService("ReportEngines");
		ReportEngine reportEngine = (ReportEngine) reportEngines
				.getService(ReportEngines.ReportEngineType.WI_REPORT_ENGINE);

		// Retrieve webi reports on SAP BO
		IInfoStore infoStore = (IInfoStore) enterpriseSession.getService("InfoStore");
		String query = "select * from CI_INFOOBJECTS where SI_KIND = 'Webi'";
		IInfoObjects infoObjects = (IInfoObjects) infoStore.query(query);
		IInfoObject infoObject = (IInfoObject) infoObjects.get(0);

		String title = infoObject.getTitle();

		// Create document instance
		DocumentInstance doc = reportEngine.openDocument(infoObject.getID());

		doc.refresh();

		// Format to PDF
		BinaryView binaryView2 = (BinaryView) doc.getView(OutputFormatType.PDF);
		File pdf = writeBytes(binaryView2.getContent(), title + ".pdf");

		String alfrescoTiccketURL = "http://172.18.23.64:8080/alfresco" + "/service/api/login?u=" + "admin" + "&pw="
				+ "admin";
		String ticketURLResponse = getTicket(alfrescoTiccketURL);

		uploadDocument(ticketURLResponse, pdf, title + ".pdf", "application/pdf", "description",
				"workspace://SpacesStore/60273b3a-b9f2-42d9-bc2d-9697246bdacd");

		doc.closeDocument();

		reportEngines.close();
		enterpriseSession.logoff();
		}
		catch(Exception e)
		{
			System.out.println(e);
		}
	}

	public static File writeBytes(byte[] data, String filename) throws IOException {
		File file = new File(filename);
		FileOutputStream fstream = new FileOutputStream(file);
		fstream.write(data);
		fstream.close();
		return file;
	}

	public static void uploadDocument(String authTicket, File fileobj, String filename, String filetype,
			String description, String destination) {
		try {

			String urlString = "http://172.18.23.64:8080/alfresco/service/api/upload?alf_ticket=" + authTicket;
			System.out.println("The upload url:::" + urlString);
			HttpClient client = new HttpClient();
			PostMethod mPost = new PostMethod(urlString);

			Part[] parts = { new FilePart("filedata", filename, fileobj, filetype, null),
					new StringPart("filename", filename), new StringPart("description", description),
					new StringPart("destination", destination), new StringPart("description", description), };
			mPost.setRequestEntity(new MultipartRequestEntity(parts, mPost.getParams()));
			int statusCode1 = client.executeMethod(mPost);
			System.out.println("statusLine>>>" + statusCode1 + "......" + "\n status line \n" + mPost.getStatusLine()
					+ "\nbody \n" + mPost.getResponseBodyAsString());
			mPost.releaseConnection();
		} catch (Exception e) {
			System.out.println(e);
		}
	}

	public static String getTicket(String url) throws IOException {

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

			int startindex = response.indexOf("_") - 6;
			int endindex = response.indexOf("/") - 1;
			ticketURLResponse = response.substring(startindex, endindex);
			System.out.println("ticket = " + ticketURLResponse);

		} finally {
			httpget.releaseConnection();
		}
		return ticketURLResponse;
	}
}

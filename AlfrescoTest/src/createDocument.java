import com.crystaldecisions.sdk.plugin.authentication.enterprise.IsecEnterprise;
import com.crystaldecisions.sdk.plugin.authentication.ldap.IsecLDAP;
import com.crystaldecisions.sdk.framework.IEnterpriseSession;
import com.crystaldecisions.sdk.framework.ISessionMgr;
import com.crystaldecisions.sdk.framework.ITrustedPrincipal;
import com.crystaldecisions.sdk.occa.security.IEnterpriseLogonInformation;
import com.crystaldecisions.sdk.occa.security.ILogonTokenMgr;
import com.crystaldecisions.sdk.framework.CrystalEnterprise;
import com.crystaldecisions.sdk.exception.SDKException;
import com.crystaldecisions.sdk.occa.infostore.IInfoStore;
import com.crystaldecisions.sdk.occa.security.IUserInfo;
import com.crystaldecisions.sdk.occa.infostore.CeSecurityID;
import com.crystaldecisions.sdk.occa.infostore.IInfoObjects;
import com.crystaldecisions.sdk.occa.infostore.IInfoObject;
//import com.crystaldecisions.sdk.plugin.desktop.server;
import com.businessobjects.rebean.wi.ReportEngines;
import com.businessobjects.rebean.wi.ReportEngine;
import com.businessobjects.rebean.wi.DocumentInstance;
import com.businessobjects.rebean.wi.DataProviders;
import com.businessobjects.rebean.wi.DataProvider;
import com.businessobjects.rebean.wi.Query;
import com.businessobjects.rebean.wi.DataSource;
import com.crystaldecisions.sdk.plugin.CeKind;

public class createDocument {
	public static void main(String[] args) {
		try
		{
		String user = "Administrator";
		String pwd = "Manager00";
		String CMS = "AS1-300-89:6400";
		String auth = "secEnterprise";

		// Session manager to make the connection with SAP BO
		ISessionMgr sessionManager = CrystalEnterprise.getSessionMgr();
		IEnterpriseSession enterpriseSession = sessionManager.logon(user, pwd, CMS, auth);

		IUserInfo userInfo = enterpriseSession.getUserInfo();

		ReportEngines reportEngines = null;
		ReportEngine wiRepEngine = null;

		ILogonTokenMgr iLManager = enterpriseSession.getLogonTokenMgr();

		//reportEngines = (ReportEngines) session.getAttribute("ReportEngines");

		// Create a new ReportEngines to create our new document
		reportEngines = (ReportEngines) enterpriseSession.getService("ReportEngines");
		wiRepEngine = reportEngines.getService(ReportEngines.ReportEngineType.WI_REPORT_ENGINE);

		// Locate the desired universe that is going to be used on the document
		IInfoStore infoStore = (IInfoStore) enterpriseSession.getService("InfoStore");
		String unvQuery = "select * from CI_APPOBJECTS where SI_KIND = 'DSL.MetaDataFile' and SI_NAME like '%Sinistro Painel_SAP%'";
		IInfoObjects infoObjects = (IInfoObjects) infoStore.query(unvQuery);
		IInfoObject infoObject = (IInfoObject) infoObjects.get(0);

		// Create document Instance. This document instance can be modified to
		// add
		// styling or content.
		DocumentInstance documentInstance = wiRepEngine.newDocument("UnivCUID=" + infoObject.getCUID());

		// Locate the Target folder where the new document its going to be saved
		String folderQuery = "select * from CI_INFOOBJECTS where SI_KIND = 'Folder' and SI_NAME='Porto_Seguro'";
		infoObjects = (IInfoObjects) infoStore.query(folderQuery);
		infoObject = (IInfoObject) infoObjects.get(0);

		// Save the document to target
		documentInstance.saveAs("Test2", infoObject.getID(), null, null, true);
		documentInstance.closeDocument();

		enterpriseSession.logoff();
		}
		catch(Exception e)
		{
			System.out.println(e);
		}
	}
}

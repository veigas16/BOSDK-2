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

public class ConsoleAuthPrompter implements CredentialsProvider {

	private BufferedReader in = null;

	public ConsoleAuthPrompter() {
		super();
		this.in = new BufferedReader(new InputStreamReader(System.in));
	}

	private String readConsole() throws IOException {
		return this.in.readLine();
	}

	public Credentials getCredentials(final AuthScheme authscheme, final String host, int port, boolean proxy)
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
				System.out.println(
						host + ":" + port + " requires authentication with the realm '" + authscheme.getRealm() + "'");
				System.out.print("Enter username: ");
				String user = readConsole();
				System.out.print("Enter password: ");
				String password = readConsole();
				return new UsernamePasswordCredentials(user, password);
			} else {
				throw new CredentialsNotAvailableException(
						"Unsupported authentication scheme: " + authscheme.getSchemeName());
			}
		} catch (IOException e) {
			throw new CredentialsNotAvailableException(e.getMessage(), e);
		}
	}
}
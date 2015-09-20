package com.inutilfutil.html2canvas;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.net.URL;
import java.net.URLConnection;
import java.util.regex.Pattern;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.common.io.BaseEncoding;
import com.google.common.io.ByteStreams;
import com.google.gson.Gson;

public class Html2CanvasProxyServlet extends HttpServlet {
	private static final long serialVersionUID = -3408677365195660129L;
	Pattern callbackPattern = Pattern.compile("[a-zA-Z_$][0-9a-zA-Z_$]*");
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		
		URL url = new URL(req.getParameter("url"));
		String callback = req.getParameter("callback");
		
		URLConnection connection = url.openConnection();
		InputStream data = connection.getInputStream();
		String contentType = connection.getContentType();

		if (callback == null) {
			resp.setContentType(contentType);
			ByteStreams.copy(data, resp.getOutputStream());
		} else {
			if (!callbackPattern.matcher(callback).matches()) {
				throw new ServletException("Invalid callback name");
			}
			resp.setContentType("application/javascript");
			Writer out = new OutputStreamWriter(resp.getOutputStream(), "UTF-8") {
				public void close() throws IOException {
					//Base64 stream will try to close before jsonp suffix is added.
				};
			};
					
			String dataUri = new Gson().toJson("data:" + contentType + ";base64,");
			out.write(callback + "(" + dataUri.substring(0, dataUri.length()-1));

			OutputStream base64Stream = BaseEncoding.base64().encodingStream(out);
			ByteStreams.copy(data, base64Stream); 
			base64Stream.close();

			out.write("\");");
			out.flush();
		}
	}
}

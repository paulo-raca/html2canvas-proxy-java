package com.inutilfutil.html2canvas;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.net.URL;
import java.net.URLConnection;
import java.util.regex.Pattern;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.QueryParam;
import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.StreamingOutput;

import com.google.common.io.BaseEncoding;
import com.google.common.io.ByteStreams;
import com.google.gson.Gson;

@Path("html2canvas")
public class Html2CanvasProxyService {
	Pattern callbackPattern = Pattern.compile("[a-zA-Z_$][0-9a-zA-Z_$]*");
	@GET
	public Response proxy(
			@QueryParam("url") final URL url,
			@QueryParam("callback") final String callback) throws IOException {

		final URLConnection connection = url.openConnection();
		final InputStream data = connection.getInputStream();
		final String contentType = connection.getContentType();

		if (callback == null) {
			return Response.ok(data, contentType).build();
		} else {
			if (!callbackPattern.matcher(callback).matches()) {
				throw new WebApplicationException("Invalid callback name");
			}
			StreamingOutput jsonpStream = new StreamingOutput() {
				public void write(OutputStream binOut) throws IOException, WebApplicationException {
					Writer out = new OutputStreamWriter(binOut, "UTF-8") {
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
			};
			return Response.ok(jsonpStream, "application/javascript").build();
		}
	}
}

<html>
<head>
  <title>HTML2Canvas Proxy</title>

  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.4/jquery.js"></script>
  
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.5/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.5/css/bootstrap-theme.min.css">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.5/js/bootstrap.min.js"></script>
    
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/jquery.fancybox.min.css">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/jquery.fancybox.pack.js"></script>
  
  <script src="http://cdnjs.cloudflare.com/ajax/libs/html2canvas/0.4.0/html2canvas.js"></script>
    
  <style>  
    .thumbnail-container {
      width: 18em;
      height: 18em;
      overflow: hidden;
      float: left;
      box-shadow: 0px 0px 1em #000;
      margin: 0.5em;
    }
  </style>
  <script>
    $(document).ready(function() {
      var examples = [
        "http://xkcd.com",
        "http://slashdot.org",
<%--          "http://twitter.com",  --%>
        "http://yahoo.com",
<%--          "http://jquery.com",  --%>
        "http://google.com",
<%--          "http://github.com",  --%>
        "http://smashingmagazine.com",
        "http://mashable.com",
<%--          "http://facebook.com/google",  --%>
        "http://mashable.com",
<%--          "http://youtube.com",  --%>
        "http://cnn.com",
<%--          "http://engadget.com",  --%>
        "http://battle.net"
      ];
    
      function render(url, proxy) {
        var urlParts = document.createElement('a');
        urlParts.href = url;   

        $.getJSON(
          "http://html2canvas.appspot.com/query?callback=?", 
          { 
            xhr2:false, 
            url:urlParts.href 
          }, 
          function(html) {
            iframe = document.createElement('iframe');
            $(iframe)
              .hide()
              .width(640)
              .data("url", url)
              .appendTo($('#iframes'));

            function iframeLoadFail(iframe) {
<%--                alert("Failed to load " + url);  --%>
<%--                $(iframe).remove();  --%>
              renderExample();
            };
              
            function iframeLoaded(iframe) {
              var body = $(iframe).contents().find('body');
              html2canvas(body, {
                onrendered: function( canvas ) {
                  $(iframe).remove();
                  renderExample();
                  var dataUri = canvas.toDataURL();
                  $("#screenshots")
//<%--                      .empty()  --%>
                    .prepend($("<div>")
                      .fadeIn()
                      .addClass("thumbnail-container")
                      .append($("<a>")
                        .attr("href", dataUri)
                        .attr("title", url)
                        .data("fancybox-group", "snapshots")
                        .append(
                          $("<img>")
                            .attr("src", dataUri)
                            .css({
                              width: "100%"
                            })
                        )
                        .fancybox({
                          fitToView: false
<%--                            transitionIn: 'elastic',  --%>
<%--                            transitionOut: 'elastic'  --%>
                        })
                      )
                    )
                },
                logging: true,
                proxy: proxy,
                width: $(iframe).width(),
              });
            };
            
            d = iframe.contentWindow.document;
            d.open();
            $(iframe.contentWindow).on("load", iframeLoaded.bind(null, iframe));
            $(iframe.contentWindow).on("error", iframeLoadFail.bind(null, iframe));
            $('base').attr('href',urlParts.protocol+"//"+urlParts.hostname+"/" + urlParts.pathname);
            html = html.replace("<head>","<head><base href='"+urlParts.protocol+"//"+urlParts.hostname+"/" + urlParts.pathname + "'  />");
            d.write(html);
            d.close();
          }
        );
      }
      
      $("#render").click(function() {
        render(
          $("#url").val(), 
          $("#proxy .active input").val() || null
        );
      });
      
      function renderExample() {
        if (examples && $("#iframes").children().length == 0) {
          render(examples.shift(), "/jax-rs/html2canvas");
        }
      }
      renderExample();
    });
  </script>
</head>
<body>
  <h2>Hello</h2>
  <p>This server hosts 2 implementations of the <a href="http://html2canvas.hertzen.com/">HTML2Canvas</a> proxy, one using <a href="https://docs.oracle.com/javaee/6/api/javax/servlet/Servlet.html">Servlets</a> and one using <a href="https://jax-rs-spec.java.net/">JAX-RS</a>.
  <p>Select your implementation:</p>
  <div>
    <input type="text" id="url" value="http://www.xkcd.com"></input>
    <div id="proxy" class="btn-group" data-toggle="buttons">
      <label class="btn btn-default active"><input type="radio"value="/jax-rs/html2canvas">JAX-RS</label>
      <label class="btn btn-default"><input type="radio" value="/servlet/html2canvas">Servlet</label>
      <label class="btn btn-default"><input type="radio" value="">None</label>
    </div>    
    <button type="button" class="btn btn-primary" id="render">Render!</button>
  </div>
  <hr>
  <div id="screenshots"></div>
  <div id="iframes"></div>
</body>
</html>

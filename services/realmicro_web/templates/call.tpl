{{define "leftbar"}}
<div class="side-bar position-fixed">
    <div class="J_appFound">
        {{template "menu-env" .}}
    </div>
</div>
{{end}}
{{define "title"}}Call Test{{end}}
{{define "style"}}
pre {
    word-wrap: break-word;
}
{{end}}
{{define "heading"}}<h3>Call Test</h3>{{end}}
{{define "content"}}
<div class="row">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="col-sm-5">
                <form id="call-form" onsubmit="return call();">
                    <div class="form-group">
                        <label for="service">Service</label>
                        <select class="form-control" type=text name=service id=service>
                            <option disabled selected> -- select a service -- </option>
                        {{range $key, $value := .Results.ServiceMap}}
                            <option class = "list-group-item" value="{{$key}}">{{$key}}</option>
                        {{end}}
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="method">Method</label>
                        <select class="form-control" type=text name=method id=method>
                            <option disabled selected> -- select a method -- </option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="othermethod">Other Method</label>
                        <input class="form-control" type=text name=othermethod id=othermethod disabled placeholder="Method"/>
                    </div>
                    <div class="form-group">
                        <label for="request">Request</label>
                        <textarea class="form-control" name=request id=request rows=8>{}</textarea>
                    </div>
                    <div class="form-group">
                        <button class="btn btn-default">Execute</button>
                    </div>
                </form>
            </div>
            <div class="col-sm-7">
                <p><b>Response</b></p>
                <pre id="response" style="min-height: 385px;">{}</pre>
            </div>
        </div>
    </div>
</div>
{{end}}
{{define "script"}}
<script>
    let env = {{.Results.Env}};
    let envName = {{.Results.EnvName}};

    $(document).ready(function(){
        //Function executes on change of first select option field
        $("#service").change(function(){
            var select = $("#service option:selected").val();
            $("#othermethod").attr("disabled", true);
            $('#othermethod').val('');
            $("#method").empty();
            $("#method").append("<option disabled selected> -- select a method -- </option>");
            var s_map = {};
        {{ range $service, $methods := .Results.ServiceMap }}
            var m_list = [];
        {{range $index, $element := $methods}}
        m_list[{{$index}}] = {{$element.Name}}
        {{end}}
                s_map[{{$service}}] = m_list;
        {{ end }}
            if (select in s_map) {
                var serviceMethods = s_map[select];
                var len = serviceMethods.length;
                for(var i = 0; i < len; i++) {
                    $("#method").append("<option value=\""+serviceMethods[i]+"\">"+serviceMethods[i]+"</option>");
                }
            }
            $("#method").append("<option value=\"other\"> - Other</option>");
        });
        //Function executes on change of second select option field
        $("#method").change(function(){
            var select = $("#method option:selected").val();
            if (select == "other") {
                $("#othermethod").attr("disabled", false);
            } else {
                $("#othermethod").attr("disabled", true);
                $('#othermethod').val('');
            }

        });
    });
</script>
<script>
    function call() {
        var req = new XMLHttpRequest();
        req.onreadystatechange = function() {
            if (req.readyState == 4 && req.status == 200) {
                document.getElementById("response").innerText = JSON.stringify(JSON.parse(req.responseText), null, 2);
            } else if (req.responseText.slice(0, 1) == "{") {
                document.getElementById("response").innerText = JSON.stringify(JSON.parse(req.responseText), null, 2);
            } else if (req.responseText.length > 0) {
                document.getElementById("response").innerText = req.responseText;
            } else {
                document.getElementById("response").innerText = "Request error " + req.status;
            }
            console.log(req.responseText);
        };
        var method = document.forms[0].elements["method"].value;
        if (!($('#othermethod').prop('disabled'))) {
            method = document.forms[0].elements["othermethod"].value
        }
        var request = {
            "env": env,
            "envName": envName,
            "service": document.forms[0].elements["service"].value,
            "method": method,
            "request": JSON.parse(document.forms[0].elements["request"].value)
        };
        req.open("POST", "/rpc", true);
        req.setRequestHeader("Content-type","application/json");
        req.send(JSON.stringify(request));

        return false;
    };
</script>
{{end}}
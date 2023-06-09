{{define "heading"}}<h4><input class="form-control input-lg search" type=text placeholder="Search"/></h4>{{end}}
{{define "title"}}Web{{end}}
{{define "content"}}
{{if .Results.HasWebServices}}
<div>
{{range .Results.WebServices}}
    <a href="/{{.}}" data-filter={{.}} class="btn btn-default btn-lg" style="margin: 5px 3px 5px 3px;">{{.}}</a>
{{end}}
</div>
{{else}}
<div class="alert alert-info" role="alert">
    <strong>No web services found</strong>
</div>
{{end}}
{{end}}
{{define "script"}}
<script type="text/javascript">
    jQuery(function($, undefined) {
        var refs = $('a[data-filter]');
        $('.search').on('keyup', function() {
            var val = $.trim(this.value);
            refs.hide();
            refs.filter(function() {
                return $(this).data('filter').search(val) >= 0
            }).show();
        });
    });
</script>
{{end}}

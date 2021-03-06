module publishermod
fn template_wiki_errors(reponame string, repourl string) string {
    out := r'
<!DOCTYPE html>
<html lang="en">
<head>
  <title></title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
</head>
<body>

<div class="container">
  
  <h1> @sitename Errors</h1>
  
  @if site_errors.len > 0
  
  <br>
  <br>

  <h3> Site Errors</h3>
  
  <table class="table">
    <thead>
      <tr>
        <th>Page</th>
        <th>Error</th>
      </tr>
    </thead>
    <tbody>
        @for error in site_errors
      <tr>
        <td>@error.path</td>
        <td>@error.error</td>
      </tr>
      @end
    </tbody>
  </table>
 
  <br>
  <br>
  @else
  <h3> Site Errors</h3>
  <div style="color: green;">
    No Errors
  </div>
  
  @end

 
@if page_errors.len > 0
  <h3> Page Errors</h3>
  
  <table class="table">
    
        @for name, errors in page_errors
        <h4 style="color:red">@name</h4>
        <table class="table">
          <thead>
            <tr>
              <th>Line</th>
              <th>Error</th>
            </tr>
          </thead>
          <tbody>
          @for error in errors
            <tr>
              <td>@error.linenr : @error.line</td>
              <td>@error.msg</td>
            </tr>
          @end
        </tbody>

      </table>
      
      @end
@else
<div style="color: green;">
  No Errors
</div>
@end


</div>
</body>
</html>


    '
    return out
}

// fn template_wiki_errors_save(destdir string, reponame string, repourl string){
//     out := index_wiki_get(reponame, repourl)
//     os.write_file("$destdir/index.html",out) or {panic(err)}
// }


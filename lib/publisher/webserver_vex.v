module publisher

import os
import nedpals.vex.router
import nedpals.vex.server
import nedpals.vex.ctx
import nedpals.vex.utils
import myconfig
import json

// this webserver is used for looking at the builded results

struct MyContext {
	config &myconfig.ConfigRoot
	// now you can inject other stuff also
}

enum FileType {
	unknown
	wiki
	file
	image
	html
}

struct ErrorJson {
pub:
	site_errors []SiteError
	page_errors map[string][]PageError
}

fn print_req_info(mut req ctx.Req, mut res ctx.Resp) {
	println('$utils.red_log() $req.method $req.path')
}

fn path_wiki_get(mut config myconfig.ConfigRoot, site string, name string) ?(FileType, string) {
	// println(" - wiki get: '$site' '$name'")
	site_config := config.site_wiki_get(site)?
	mut name2 := name.to_lower().trim(' ').trim(".").trim(' ')
	mut path2 := ''
	extension := os.file_ext(name2).trim('.')
	mut sitename := site_config.alias
	if sitename.starts_with('wiki_') || sitename.starts_with('info_') {
		sitename = sitename[5..]
	}

	if name.starts_with('file__') || name.starts_with('page__') || name.starts_with('html__') {
		splitted := name.split('__')
		if splitted.len != 3 {
			return error('filename not well formatted. Needs to have 3 parts. Now $name2 .')
		}
		name2 = splitted[2]
		if sitename != splitted[1] {
			return error('Sitename in name should correspond to ${sitename}. Now $name2 .')
		}
	}

	// println( " - ${app.req.url}")
	if name2.trim(" ")==""{
		name2="index.html"
	}else{
		name2 = name_fix_keepext(name2)
	}


	mut filetype := FileType{}
	if name2.starts_with('file__') {
		// app.set_content_type('text/html')
		filetype = FileType.file
	} else if name2.starts_with('page__') {
		filetype = FileType.wiki
	} else if name2.starts_with('html__') {
		filetype = FileType.html
	} else if name2.ends_with('.html') {
		filetype = FileType.html
	} else if name2.ends_with('.md') {
		filetype = FileType.wiki
	} else if extension == "" {
		filetype = FileType.wiki		
	} else {
		// consider all to be files (images)
		filetype = FileType.file
	}

	if filetype == FileType.wiki{
		if ! name2.ends_with(".md"){
			name2 += ".md"
		}
	}

	if name2 == '_sidebar.md' {
		name2 = 'sidebar.md'
	}

	if name2 == '_navbar.md' {
		name2 = 'navbar.md'
	}

	path2 = os.join_path(config.paths.publish, "wiki_"+sitename, name2)

	if name2 == 'readme.md' && (!os.exists(path2)) {
		name2 = 'sidebar.md'
		path2 = os.join_path(config.paths.publish, "wiki_"+sitename, name2)
	}

	// println('  > get: $path2 ($name)')

	if !os.exists(path2) {
		return error('cannot find file in: $path2')
	}

	return filetype, path2
}

fn index_template(wikis map[string][]string, sites map[string][]string, port int) string{
	mut port_str := ""
	if port != 80{
		port_str = ":$port"
	}
	return $tmpl('index_root.html')
}
fn error_template(sitename string, path string) string{
	err_file := os.read_file(path) or {
			return "ERROR: could not find errors file on $path"
		}
	errors := json.decode(ErrorJson, err_file) or {
			return "ERROR: json not well formatted on $path"
		}
	mut site_errors := errors.site_errors
	mut page_errors := errors.page_errors	
	return $tmpl('errors.html')
}

// Index (List of wikis) -- reads index.html
fn index_root(req &ctx.Req, mut res ctx.Resp) {
	config := (&MyContext(req.ctx)).config
	mut wikis := map[string][]string{}
	mut sites := map[string][]string{}

	mut all := map[string][]string{}
	for site in config.sites{
		all[site.alias] = site.domains
	}

	path := os.join_path(config.paths.publish)
	list := os.ls(path) or { panic(err) }
	for item in list {
		mut alias := ""
		if item.starts_with("wiki_"){
			alias = item.replace("wiki_", "")
			wikis[alias] = all[alias]
		}else if item.starts_with("www_"){
			alias = item.replace("www_", "")
			sites[alias] = all[alias]
		}
	}
	res.headers['Content-Type'] = ['text/html']
	res.send(index_template(wikis, sites, config.port), 200)
}

fn return_wiki_errors(sitename string, req &ctx.Req, mut res ctx.Resp) {
	config := (&MyContext(req.ctx)).config
	path := os.join_path(config.paths.publish, "wiki_$sitename", "errors.json")
	t := error_template(sitename,path)
	if t.starts_with("ERROR:") { 
			res.send(t, 501) 
			return
		}
	// println(t)
	res.send(t, 200)
}

fn site_wiki_deliver(mut config myconfig.ConfigRoot, site string, path string, req &ctx.Req, mut res ctx.Resp) {
	name := os.base(path)

	if path.ends_with("errors") || path.ends_with("error") {
		return_wiki_errors(site,req,mut res)
		return
	}
	filetype, path2 := path_wiki_get(mut config,site,name) or { 
		println("could not get path for: $site:$name\n$err")
		res.send("$err", 404) 
		return
		}
	println(" - '$site:$name' -> $path2")
	if filetype == FileType.wiki{
		content := os.read_file(path2) or {res.send("Cannot find file: $path2\n$err", 404) return}
		res.headers['Content-Type'] = ['text/html']
		res.send(content, 200)
	}else{
		if ! os.exists(path2){
			println(" - ERROR: cannot find path:$path2")
			res.send("cannot find path:$path2", 404) 
			return
		}else{
			// println("deliver: '$path2'")
			content := os.read_file(path2) or {res.send("Cannot find file: $path2\n$err", 404) return}
			//NOT GOOD NEEDS TO BE NOT LIKE THIS: TODO: find way how to send file
			res.send(content, 200)
			// res.send_file(path2,200)
		}
	}
}

fn site_www_deliver(mut config myconfig.ConfigRoot, domain string, path string, req &ctx.Req, mut res ctx.Resp) {
	mut site_path := config.path_publish_web_get_domain(domain)or {res.send("Cannot find domain: $domain\n$err", 404) return}
	mut path2 := path
	
	if path2.trim("/")==""{
		path2="index.html"
		res.headers['Content-Type'] = ['text/html']
	}
	path2 = os.join_path(site_path,path2)
	
	if ! os.exists(path2){
		println(" - ERROR: cannot find path:$path2")
		res.send("cannot find path:$path2", 404) 
		return
	}else{
		if os.is_dir(path2){
			path2 = os.join_path(path2, "index.html")
			res.headers['Content-Type'] = ['text/html']
		}
		// println("deliver: '$path2'")
		content := os.read_file(path2) or {res.send("Cannot find file: $path2\n$err", 404) return}
		//NOT GOOD NEEDS TO BE NOT LIKE THIS: TODO: find way how to send file
		if path2.ends_with(".css"){
			res.headers['Content-Type'] = ['text/css']
		}
		if path2.ends_with(".js"){
			res.headers['Content-Type'] = ['text/javascript']
		}
		if path2.ends_with(".svg"){
			res.headers['Content-Type'] = ['image/svg+xml']
		}
		if path2.ends_with(".png"){
			res.headers['Content-Type'] = ['image/png']
		}
		if path2.ends_with(".jpg"){
			res.headers['Content-Type'] = ['image/jpg']
		}
		if path2.ends_with(".jpeg"){
			res.headers['Content-Type'] = ['image/jpeg']
		}
		if path2.ends_with(".gif"){
			res.headers['Content-Type'] = ['image/gif']
		}


		res.send(content, 200)
	}
}

fn site_deliver(req &ctx.Req, mut res ctx.Resp) {
	mut config := (&MyContext(req.ctx)).config
	mut host := req.headers['Host'][0]
	mut splitted := host.split(":")
	mut domain := "localhost"
	mut site := ""

	if splitted.len > 0{
		domain = splitted[0]
	}
	
	mut iswiki := true
	for siteconfig in config.sites{
		if domain in siteconfig.domains{
			if siteconfig.cat == myconfig.SiteCat.web{
				iswiki = false
			}else{
				site = siteconfig.name
			}
		}
	}

	mut path := req.params["path"]
	splitted = path.trim("/").split("/")
	
	path = splitted[0..].join("/").trim("/").trim(" ")
	
	if iswiki{
		site_wiki_deliver(mut config,site,path,req,mut res)		
	}else{	
		//if no wiki or www used then its a website
		site_www_deliver(mut config,domain,path,req,mut res)
	}
}


// Run server
pub fn webserver_run() {
	mut app := router.new()

	config := myconfig.get()
	mycontext := &MyContext{
		config: &config
	}
	app.inject(mycontext)

	app.use(print_req_info)

	app.route(.get, '/published/list', index_root)
    app.route(.get, '/*path',site_deliver)

	println("List all websites & Wikis in publishing tools @ http://localhost:$config.port/published/list")
	server.serve(app, config.port)
}


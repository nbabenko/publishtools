module publishermod

struct Site {
	id int [skip]
pub mut: // id and index in the Publisher.sites array
	// not in json if we would serialize
	errors []SiteError
	path   string
	name   string
	files  map[string]int
	pages  map[string]int
	state  SiteState
	config SiteConfig
}

pub enum SiteErrorCategory {
	duplicatefile
	duplicatepage
	emptypage
	unknown
}

struct SiteError {
pub:
	path  string
	error string
	cat   SiteErrorCategory
}

pub enum SiteState {
	init
	ok
	error
}

struct SiteConfig {
	// name of the wiki site
	name  string
	alias string
	// depends on which other wiki sites
	depends      []string
	wordreplace  []string
	filereplace  []string
	sitereplace  []string
	error_ignore []string
}

pub fn (mut site Site) error_ignore_check(name string) bool {
	for mut item in site.config.error_ignore {
		if name_fix(name) == name_fix(item) {
			return true
		}
	}
	return false
}

pub fn (site Site) page_get(name string, mut publisher Publisher) ?&Page {
	mut namelower := name_fix(name)
	if namelower in site.pages {
		return publisher.page_get_by_id(site.pages[namelower])
	}
	return error('cannot find page with name $name')
}

pub fn (site Site) file_get(name string, mut publisher Publisher) ?&File {
	mut namelower := name_fix(name)
	if namelower in site.files {
		return publisher.file_get_by_id(site.files[namelower])
	}
	return error('cannot find file with name $name')
}

pub fn (site Site) page_exists(name string) bool {
	mut namelower := name_fix(name)
	return namelower in site.pages
}

pub fn (site Site) file_exists(name string) bool {
	mut namelower := name_fix(name)
	return namelower in site.files
}

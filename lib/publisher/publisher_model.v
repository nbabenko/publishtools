module publishermod

import texttools

struct Publisher {
mut:
	gitlevel int
pub mut:
	sites      []Site
	pages      []Page
	files      []File
	site_names map[string]int
	// maps definition name to page id
	defs     map[string]int
	develop  bool
	replacer ReplacerInstructions
}

struct ReplacerInstructions {
pub mut:
	site texttools.ReplaceInstructions
	file texttools.ReplaceInstructions
	word texttools.ReplaceInstructions
}

pub fn (mut publisher Publisher) site_get_by_id(id int) ?&Site {
	if id > publisher.sites.len {
		return error('cannot get site with id: $id because not enough sites in the list')
	}
	return &publisher.sites[id]
}

pub fn (mut publisher Publisher) page_get_by_id(id int) ?&Page {
	if id > publisher.pages.len {
		return error('cannot get page with id: $id because not enough pages in the list')
	}
	return &publisher.pages[id]
}

pub fn (mut publisher Publisher) file_get_by_id(id int) ?&File {
	if id > publisher.files.len {
		return error('cannot get file with id: $id because not enough files in the list')
	}
	return &publisher.files[id]
}

////////////////////////////////////////////////////////////////

pub fn (mut publisher Publisher) site_exists(name string) bool {
	pagename := name_fix(name)
	return pagename in publisher.site_names
}

pub fn (mut publisher Publisher) file_exists(name string) bool {
	sitename, itemname := name_split(name) or { panic(err) }
	if sitename == '' {
		for site in publisher.sites {
			if itemname in site.files {
				return true
			}
		}
		return false
	} else {
		site := publisher.site_get(sitename) or { panic(err) }
		return itemname in site.files
	}
}

pub fn (mut publisher Publisher) page_exists(name string) bool {
	mut sitename, itemname := name_split(name) or { return false }
	if sitename == '' {
		for site in publisher.sites {
			if itemname in site.pages {
				return true
			}
		}
		return false
	} else {
		site := publisher.site_get(sitename) or { return false }
		return itemname in site.pages
	}
}

////////////// GET BY NAME

pub fn (mut publisher Publisher) site_get(name string) ?&Site {
	sitename := name_fix(name)
	if sitename in publisher.site_names {
		mut site := publisher.site_get_by_id(publisher.site_names[sitename]) or {
			return error('cannot find site: $sitename')
		}
		return site
	}
	return error('cannot find site: $sitename')
}

// name in form: 'sitename:filename' or 'filename'
pub fn (mut publisher Publisher) file_get(name string) ?&File {
	n := name.trim_left('.')
	sitename, itemname := name_split(n) ?
	mut res := []int{}
	if sitename == '' {
		for site in publisher.sites {
			for file in publisher.files {
				if file.name == itemname {
					res << site.files[itemname]
				}
			}
		}
	} else {
		site := publisher.site_get(sitename) ?
		if itemname in site.files {
			return publisher.file_get_by_id(site.files[itemname])
		}
	}
	if res.len == 0 {
		return error("Could not find file: '$name'")
	} else if res.len > 1 {
		return error("Found more than 1 file with name: '$name'")
	} else {
		return publisher.file_get_by_id(res[0])
	}
}

// name in form: 'sitename:pagename' or 'pagename'
pub fn (mut publisher Publisher) page_get(name string) ?&Page {
	mut sitename, itemname := name_split(name) ?
	println(' - page get: $sitename:$itemname')
	mut res := []int{}
	if sitename == '' {
		for site in publisher.sites {
			if itemname in site.pages {
				res << site.pages[itemname]
			}
		}
		// return error("Could not find page, site not specified: '$name'")
	} else {
		site := publisher.site_get(sitename) ?
		if itemname in site.pages {
			return publisher.page_get_by_id(site.pages[itemname])
		}
	}
	if res.len == 0 {
		return error("Could not find page: '$name'")
	} else if res.len > 1 {
		return error("Found more than 1 page with name (maybe wrong specified site or none): '$name'")
	} else {
		return publisher.page_get_by_id(res[0])
	}
}

////////////// GET BY NAME

pub fn (mut publisher Publisher) def_page_get(name string) ?&Page {
	name2 := name_fix(name).replace('_', '')
	if name2 in publisher.defs {
		pageid := publisher.defs[name2]
		return &publisher.pages[pageid]
	}
	return error('cannot find def: $name')
}

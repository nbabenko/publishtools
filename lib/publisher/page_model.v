module publishermod
import os
pub enum PageStatus {
	unknown
	ok
	error
	reprocess
}

struct Page {
id      int  [skip]
site_id int [skip]
mut:
	path            string
pub:
	name            string
pub mut:
	state           PageStatus
	errors          []PageError
	pages_included []int //links to pages
	pages_linked  []int //links to pages
	content         string
	nrtimes_inluded int
}

pub enum PageErrorCat {
	unknown
	brokenfile
	brokenlink
	brokeninclude
}

struct PageError {
	pub:
		line   string
		linenr int
		msg    string
		cat    PageErrorCat
}


pub fn (page Page) site_get(mut publisher &Publisher) ?&Site {
	return publisher.site_get_by_id(page.site_id)
}

pub fn (page Page) path_relative_get(mut publisher Publisher) string {
	if page.path == ""{
		panic("file path should never be empty, is bug")
	}
	return page.path
}

pub fn (page Page) path_get(mut publisher Publisher) string {
	if page.site_id > publisher.sites.len {
		panic('cannot find site: $page.site_id, not enough elements in list.')
	}
	if page.path == ""{
		panic("file path should never be empty, is bug. For page\n$page")
	}
	site_path := publisher.sites[page.site_id].path
	return os.join_path(site_path, page.path)
}


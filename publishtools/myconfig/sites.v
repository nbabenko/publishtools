module myconfig

fn site_config(mut c ConfigRoot) {
	c.sites << SiteConfig{
		name: 'www_threefold_io'
		alias: 'tf'
		url: 'https://github.com/threefoldfoundation/www_threefold_io'
		cat: SiteCat.web
        domains: ["www3.threefold.io"]
	}
	c.sites << SiteConfig{
		name: 'www_threefold_cloud'
		alias: 'cloud'
		url: 'https://github.com/threefoldfoundation/www_threefold_cloud'
		cat: SiteCat.web
        domains:  ["www3.cloud.threefold.io"]
	}
	c.sites << SiteConfig{
		name: 'www_threefold_farming'
		alias: 'farming'
		url: 'https://github.com/threefoldfoundation/www_threefold_farming'
		cat: SiteCat.web
        domains: ["www3.farming.threefold.io"]
	}
	c.sites << SiteConfig{
		name: 'www_threefold_twin'
		alias: 'twin'
		url: 'https://github.com/threefoldfoundation/www_threefold_twin'
		cat: SiteCat.web
        domains: ["www3.twin.threefold.io"]
	}
	c.sites << SiteConfig{
		name: 'www_threefold_marketplace'
		alias: 'marketplace'
		url: 'https://github.com/threefoldfoundation/www_threefold_marketplace'
		cat: SiteCat.web
        domains: ["www3.marketplace.threefold.io"]
	}
	c.sites << SiteConfig{
		name: 'www_conscious_internet'
		alias: 'conscious_internet'
		url: 'https://github.com/threefoldfoundation/www_conscious_internet'
		cat: SiteCat.web
        domains: ["www3.consciousinternet.org"]
	}
	c.sites << SiteConfig{
		name: 'www_threefold_tech'
		alias: 'tech'
		url: 'https://github.com/threefoldtech/www_threefold_tech'
		cat: SiteCat.web
        domains: ["www3.threefold.tech"]
	}
	c.sites << SiteConfig{
		name: 'www_examplesite'
		alias: 'example'
		url: 'https://github.com/threefoldfoundation/www_examplesite'
		cat: SiteCat.web
        domains: ["www3.examplesite.threefold.io"]
	}
	c.sites << SiteConfig{
		name: 'info_threefold'
		alias: 'threefold'
		url: 'https://github.com/threefoldfoundation/info_threefold'
		domains: ["www3.info.threefold.io"]
	}
	// c.sites << SiteConfig{
	// 	name: 'info_marketplace'
	// 	alias: 'marketplace'
	// 	url: 'https://github.com/threefoldfoundation/info_marketplace'
	// }
	c.sites << SiteConfig{
		name: 'info_sdk'
		alias: 'sdk'
		url: 'https://github.com/threefoldfoundation/info_sdk'
		domains: ["www3.sdk.threefold.io"]
	}
	c.sites << SiteConfig{
		name: 'info_legal'
		alias: 'legal'
		url: 'https://github.com/threefoldfoundation/info_legal'
		domains: ["www3.legal.threefold.io"]
	}
	c.sites << SiteConfig{
		name: 'info_cloud'
		alias: 'cloud'
		url: 'https://github.com/threefoldfoundation/info_cloud'
		domains: ["www3.tftech.threefold.io"]
	}
	c.sites << SiteConfig{
		name: 'info_tftech'
		alias: 'tftech'
		url: 'https://github.com/threefoldtech/info_tftech'
		domains: ["www3.tftech.threefold.io"]
	}
	c.sites << SiteConfig{
		name: 'info_digitaltwin'
		alias: 'twin'
		url: 'https://github.com/threefoldfoundation/info_digitaltwin.git'
		domains: ["www3.digitaltwin.threefold.io"]
	}
	c.sites << SiteConfig{
		name: 'data_threefold'
		alias: 'data'
		url: 'https://github.com/threefoldfoundation/data_threefold'
		cat: SiteCat.data
		domains : []string{}
	}
}

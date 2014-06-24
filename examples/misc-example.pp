# here is some example usage for some of the firewalld classes and types

class {'firewalld::configuration':
        default_zone    =>      'home',
        minimal_mark    =>      '666',
}

# define a zone
$zone = 'public'	# use a variable
firewalld::zone { "${zone}":
	ports => [],
	services => [],
	masquerade => false,
}

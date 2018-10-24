i18n.merge_file(
			input: 'com.github.naxuroqa.venom.desktop.in',
			output: 'com.github.naxuroqa.venom.desktop',
			type: 'desktop',
			po_dir: '../po',
			install: true,
			install_dir: join_paths(get_option('datadir'), 'applications')
)

service_conf = configuration_data()
service_conf.set('bindir', join_paths(get_option('prefix'), get_option('bindir')))
configure_file(
			input: 'com.github.naxuroqa.venom.service.in',
			output: 'com.github.naxuroqa.venom.service',
			configuration: service_conf,
			install: true,
			install_dir: join_paths(get_option('datadir'), 'dbus-1', 'services')
)

install_data(
			'icons/symbolic/com.github.naxuroqa.venom-symbolic.svg',
			install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'symbolic', 'apps'),
)

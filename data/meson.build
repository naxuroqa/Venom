i18n.merge_file(
			input: 'im.tox.venom.desktop.in',
			output: 'im.tox.venom.desktop',
			type: 'desktop',
			po_dir: '../po',
			install: true,
			install_dir: join_paths(get_option('datadir'), 'applications')
)

service_conf = configuration_data()
service_conf.set('bindir', join_paths(get_option('prefix'), get_option('bindir')))
configure_file(
			input: 'im.tox.venom.service.in',
			output: 'im.tox.venom.service',
			configuration: service_conf,
			install: true,
			install_dir: join_paths(get_option('datadir'), 'dbus-1', 'services')
)

install_data(
			'icons/symbolic/im.tox.venom-symbolic.svg',
			install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'symbolic', 'apps'),
)

project('venom', ['vala', 'c'],
			license: 'GPL3+',
			version: '0.3.0'
)

i18n = import('i18n')
gnome = import('gnome')

localedir = join_paths(get_option('prefix'), get_option('localedir'))
add_project_arguments('-DGETTEXT_PACKAGE="' + meson.project_name() + '"', language: 'c')

conf_data = configuration_data()
conf_data.set_quoted('VENOM_VERSION', meson.project_version())
conf_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf_data.set_quoted('GETTEXT_PATH', localedir)

subdir('scripts')
subdir('data')
subdir('po')
subdir('src')
subdir('src/testing')

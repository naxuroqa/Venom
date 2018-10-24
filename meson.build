project('venom', ['vala', 'c'],
			license: 'GPL3+',
			version: '0.4.1'
)

i18n = import('i18n')
gnome = import('gnome')
valac = meson.get_compiler('vala')

localedir = join_paths(get_option('prefix'), get_option('localedir'))

conf_data = configuration_data()
conf_data.set_quoted('VENOM_VERSION', meson.project_version())
conf_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf_data.set_quoted('GETTEXT_PATH', localedir)

subdir('scripts')
subdir('data')
subdir('po')
subdir('src')
subdir('src/testing')

message('\n'.join(['',
'  @0@-@1@'.format(meson.project_name(), meson.project_version()),
'  prefix:    @0@'.format(get_option('prefix')),
'  buildtype: @0@'.format(get_option('buildtype'))
]))

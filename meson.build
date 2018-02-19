project('venom', ['vala', 'c'],
			license: 'GPL3+',
			version: '0.3.0'
)

i18n = import('i18n')
gnome = import('gnome')

gettext_package = 'venom'
gettext_path = join_paths(get_option('prefix'), get_option('localedir'))
add_project_arguments('-DGETTEXT_PACKAGE="' + gettext_package + '"', language: 'c')

version_split = meson.project_version().split('.')
MAJOR_VERSION = version_split[0]
MINOR_VERSION = version_split[1]
PATCH_VERSION = version_split[2]

conf_data = configuration_data()
conf_data.set('VENOM_VERSION_MAJOR', MAJOR_VERSION)
conf_data.set('VENOM_VERSION_MINOR', MINOR_VERSION)
conf_data.set('VENOM_VERSION_PATCH', PATCH_VERSION)
conf_data.set('VENOM_VERSION', meson.project_version())
conf_data.set('VENOM_COPYRIGHT_NOTICE', 'Copyright © 2013-2017 Venom authors and contributors')
conf_data.set('VENOM_SHORT_DESCRIPTION', 'GTK+-3.0 user interface for Tox')
conf_data.set('VENOM_WEBSITE', 'https://github.com/naxuroqa/Venom')
conf_data.set('GETTEXT_PACKAGE', gettext_package)
conf_data.set('GETTEXT_PATH', gettext_path)

subdir('scripts')
subdir('data')
subdir('po')
subdir('src')
subdir('src/testing')

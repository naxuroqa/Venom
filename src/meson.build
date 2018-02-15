root_source_dir = meson.current_source_dir()

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
			language: 'vala')

gtk_dep = dependency('gtk+-3.0')
gdk_dep = dependency('gdk-3.0')
gio_dep = dependency('gio-2.0')
glib_dep = dependency('glib-2.0')
gmodule_dep = dependency('gmodule-2.0')
sqlite_dep = dependency('sqlite3')
json_dep = dependency('json-glib-1.0')
soup_dep = dependency('libsoup-2.4')
tox_dep = dependency('toxcore')
toxav_dep = dependency('toxav')
gst_dep = dependency('gstreamer-1.0')
posix_dep = meson.get_compiler('vala').find_library('posix', required : false)

config_vapi = meson.get_compiler('vala').find_library('config', dirs: join_paths(meson.current_source_dir(), 'vapi'))
config_dep = declare_dependency(dependencies: [config_vapi], include_directories : include_directories('.'))
config_file = configure_file(input : 'config.h.in', output : 'config.h', configuration : conf_data)

venom_source = files(
			'Main.vala',
			'core/Application.vala',
			'core/Contact.vala',
			'core/Contacts.vala',
			'core/Conversation.vala',
			'core/Interfaces.vala',
			'core/Logger.vala',
			'core/Message.vala',
			'core/R.vala',
			'core/Tools.vala',
			'core/WidgetFactory.vala',
			'core/User.vala',
			'core/UserInfo.vala',
			'db/DatabaseInterfaces.vala',
			'db/SqliteSettingsDatabase.vala',
			'db/SqliteWrapper.vala',
			'plugin/Plugin.vala',
			'plugin/Pluginregistrar.vala',
			'tox/Contact.vala',
			'tox/ContactDatabase.vala',
			'tox/DhtNode.vala',
			'tox/DhtNodeDatabase.vala',
			'tox/GroupchatContact.vala',
			'tox/GroupMessage.vala',
			'tox/JsonWebDhtNodeDatabase.vala',
			'tox/MessageDatabase.vala',
			'tox/SqliteDhtNodeDatabase.vala',
			'tox/ToxSession.vala',
			'tox/ToxSessionIO.vala',
			'tox/ToxSessionListener.vala',
			'tox/ToxSessionThread.vala',
			'ui/AboutDialog.vala',
			'ui/AddContactWidget.vala',
			'ui/ApplicationWindow.vala',
			'ui/ConferenceInfoWidget.vala',
			'ui/ConferenceWindow.vala',
			'ui/ContactListEntry.vala',
			'ui/ContactListWidget.vala',
			'ui/ConversationWindow.vala',
			'ui/CreateGroupchatWidget.vala',
			'ui/DownloadsEntry.vala',
			'ui/DownloadsWidget.vala',
			'ui/FriendInfoWidget.vala',
			'ui/MessageWidget.vala',
			'ui/NodeWidget.vala',
			'ui/SettingsWidget.vala',
			'ui/UserInfoWidget.vala',
			'ui/UITools.vala',
			'ui/WelcomeWidget.vala'
			)

venom_ui_resources = gnome.compile_resources( 'venom_ui_resources', 'ui/venom.gresource.xml',
			source_dir : 'ui',
			c_name : 'c_venom_ui_res')

venom_icons_resources = gnome.compile_resources( 'venom_icons_resources', 'icons/icons.gresource.xml',
			source_dir : 'icons',
			c_name : 'c_venom_icons_res')

venom_binary = executable('venom', [venom_source, venom_ui_resources, venom_icons_resources],
			dependencies : [gtk_dep, gio_dep, gmodule_dep, sqlite_dep, json_dep, tox_dep, toxav_dep, config_dep, soup_dep],
			install : true
			)

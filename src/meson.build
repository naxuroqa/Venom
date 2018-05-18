root_source_dir = meson.current_source_dir()

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
			language: 'vala')

gtk_dep = dependency('gtk+-3.0')
gdk_dep = dependency('gdk-3.0')
gio_dep = dependency('gio-2.0')
glib_dep = dependency('glib-2.0')
gee_dep = dependency('gee-0.8')
gmodule_dep = dependency('gmodule-2.0')
sqlite_dep = dependency('sqlite3')
json_dep = dependency('json-glib-1.0')
soup_dep = dependency('libsoup-2.4')
tox_dep = dependency('toxcore')
gst_dep = dependency('gstreamer-1.0', required : false)
posix_dep = meson.get_compiler('vala').find_library('posix', required : false)

config_vapi = meson.get_compiler('vala').find_library('config', dirs: join_paths(meson.current_source_dir(), 'vapi'))
config_dep = declare_dependency(dependencies: [config_vapi], include_directories : include_directories('.'))
config_file = configure_file(input : 'config.h.in', output : 'config.h', configuration : conf_data)

venom_ui_resources = gnome.compile_resources( 'venom_ui_resources', 'ui/venom.gresource.xml',
			source_dir : 'ui',
			c_name : 'c_venom_ui_res')

venom_icons_resources = gnome.compile_resources( 'venom_icons_resources', 'icons/icons.gresource.xml',
			source_dir : 'icons',
			c_name : 'c_venom_icons_res')

venom_source = files(
			'core/Application.vala',
			'core/Contact.vala',
			'core/FileIO.vala',
			'core/FileTransfer.vala',
			'core/Interfaces.vala',
			'core/Logger.vala',
			'core/Message.vala',
			'core/NotificationListener.vala',
			'core/ObservableList.vala',
			'core/R.vala',
			'core/TimeStamp.vala',
			'core/Tools.vala',
			'core/WidgetFactory.vala',
			'core/WindowState.vala',
			'core/UserInfo.vala',
			'db/DatabaseInterfaces.vala',
			'db/SqliteSettingsDatabase.vala',
			'db/SqliteWrapper.vala',
			'plugin/Plugin.vala',
			'plugin/Pluginregistrar.vala',
			'tox/Conference.vala',
			'tox/ConferenceMessage.vala',
			'tox/ContactDatabase.vala',
			'tox/DhtNode.vala',
			'tox/DhtNodeDatabase.vala',
			'tox/FriendRequest.vala',
			'tox/JsonWebDhtNodeDatabase.vala',
			'tox/MessageDatabase.vala',
			'tox/SqliteDhtNodeDatabase.vala',
			'tox/ToxAdapterConferenceListener.vala',
			'tox/ToxAdapterFriendListener.vala',
			'tox/ToxAdapterFiletransferListener.vala',
			'tox/ToxAdapterSelfListener.vala',
			'tox/ToxContact.vala',
			'tox/ToxSession.vala',
			'tox/ToxSessionIO.vala',
			'tox/ToxSessionThread.vala',
			'undo/SimpleUndoStack.vala',
			'undo/TextBufferUndoBinding.vala',
			'undo/UndoCommand.vala',
			'undo/UndoStack.vala',
			'view/AboutDialog.vala',
			'view/AddContactWidget.vala',
			'view/ApplicationWindow.vala',
			'view/ConferenceInfoWidget.vala',
			'view/ConferenceInviteEntry.vala',
			'view/ConferenceWindow.vala',
			'view/ContactListEntry.vala',
			'view/ContactListRequestEntry.vala',
			'view/ContactListWidget.vala',
			'view/ContextStyleBinding.vala',
			'view/ConversationWindow.vala',
			'view/CreateGroupchatWidget.vala',
			'view/FileTransferEntry.vala',
			'view/FileTransferWidget.vala',
			'view/FriendInfoWidget.vala',
			'view/FriendRequestWidget.vala',
			'view/MessageWidget.vala',
			'view/NodeWidget.vala',
			'view/PeerEntry.vala',
			'view/SettingsWidget.vala',
			'view/UserInfoWidget.vala',
			'view/WelcomeWidget.vala',
			'viewmodel/AddContactViewModel.vala',
			'viewmodel/ConferenceInfoViewModel.vala',
			'viewmodel/ContactListEntryViewModel.vala',
			'viewmodel/ContactListViewModel.vala',
			'viewmodel/CreateGroupchatViewModel.vala',
			'viewmodel/FileTransferEntryViewModel.vala',
			'viewmodel/FriendInfoViewModel.vala',
			'viewmodel/MessageViewModel.vala',
			'viewmodel/UserInfoViewModel.vala'
			)

venom_deps = [gtk_dep, gio_dep, gmodule_dep, gee_dep, sqlite_dep, json_dep, tox_dep, config_dep, soup_dep]

venom_lib = static_library('venom', [venom_source, venom_ui_resources, venom_icons_resources],
			dependencies : venom_deps
			)

venom_dep = declare_dependency(
			dependencies : venom_deps,
			link_with : venom_lib
			)

venom_binary = executable('venom', ['Main.vala', venom_ui_resources, venom_icons_resources],
			dependencies : venom_dep,
			install : true
			)

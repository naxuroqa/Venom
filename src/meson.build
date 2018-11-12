vapi_dir = join_paths(meson.current_source_dir(), 'vapi')

add_project_arguments(['--vapidir', vapi_dir], language: 'vala')
add_project_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language: 'c')

gtk_dep = dependency('gtk+-3.0')
gdk_dep = dependency('gdk-3.0')
gio_dep = dependency('gio-2.0')
glib_dep = dependency('glib-2.0')
gee_dep = dependency('gee-0.8')
gspell_dep = dependency('gspell-1')
canberra_dep = dependency('libcanberra')
gmodule_dep = dependency('gmodule-2.0')
sqlcipher_dep = dependency('sqlcipher')
json_dep = dependency('json-glib-1.0')
soup_dep = dependency('libsoup-2.4')
tox_dep = dependency('toxcore')
gst_dep = dependency('gstreamer-1.0', required : false)
posix_dep = valac.find_library('posix', required : false)

if (posix_dep.found())
			add_project_arguments(['-D', 'ENABLE_POSIX'], language: 'vala')
endif

config_vapi = valac.find_library('config', dirs: vapi_dir)
config_dep = declare_dependency(dependencies: [config_vapi], include_directories : include_directories('.'))
configure_file(output : 'config.h', configuration : conf_data)

venom_ui_resources = gnome.compile_resources('venom_ui_resources', 'ui/venom.gresource.xml',
			source_dir : 'ui',
			c_name : 'c_venom_ui_res')

venom_icons_resources = gnome.compile_resources('venom_icons_resources', 'icons/icons.gresource.xml',
			source_dir : 'icons',
			c_name : 'c_venom_icons_res')

venom_source = files(
			'core/Application.vala',
			'core/Contact.vala',
			'core/FileIO.vala',
			'core/FileTransfer.vala',
			'core/Identicon.vala',
			'core/Logger.vala',
			'core/Message.vala',
			'core/NotificationListener.vala',
			'core/ObservableList.vala',
			'core/Profile.vala',
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
			'portal/Request.vala',
			'portal/Screenshot.vala',
			'tox/Conference.vala',
			'tox/ConferenceMessage.vala',
			'tox/DhtNode.vala',
			'tox/FriendRequest.vala',
			'tox/JsonWebDhtNodeUpdater.vala',
			'tox/SqliteContactRepository.vala',
			'tox/SqliteDhtNodeRepository.vala',
			'tox/SqliteFriendRequestRepository.vala',
			'tox/SqliteMessageRepository.vala',
			'tox/SqliteNospamRepository.vala',
			'tox/StaticDhtNodeUpdater.vala',
			'tox/ToxAdapterConferenceListener.vala',
			'tox/ToxAdapterFriendListener.vala',
			'tox/ToxAdapterFiletransferListener.vala',
			'tox/ToxAdapterSelfListener.vala',
			'tox/ToxContact.vala',
			'tox/ToxMessage.vala',
			'tox/ToxSession.vala',
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
			'view/ContactListEntryCompact.vala',
			'view/ContactListWidget.vala',
			'view/ContextStyleBinding.vala',
			'view/ConversationWindow.vala',
			'view/CreateGroupchatWidget.vala',
			'view/ErrorWidget.vala',
			'view/FileTransferEntry.vala',
			'view/FileTransferEntryInline.vala',
			'view/FileTransferWidget.vala',
			'view/FriendInfoWidget.vala',
			'view/FriendRequestWidget.vala',
			'view/InAppNotification.vala',
			'view/LoginWidget.vala',
			'view/MessageWidget.vala',
			'view/NodeWidget.vala',
			'view/NospamEntry.vala',
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

venom_deps = [gtk_dep, gio_dep, gmodule_dep, gee_dep, sqlcipher_dep, json_dep, tox_dep, config_dep, soup_dep, posix_dep, gspell_dep, canberra_dep]

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

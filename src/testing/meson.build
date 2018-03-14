if posix_dep.found()
			executable('group_bot', ['GroupBot.vala',
						join_paths(root_source_dir, 'core/Tools.vala')],
						dependencies : [gio_dep, tox_dep, posix_dep]
						)
endif

if gst_dep.found()
			executable('toxav', ['ToxAVTest.vala',
						join_paths(root_source_dir, 'core/Tools.vala')],
						dependencies : [gtk_dep, tox_dep, toxav_dep, gst_dep]
						)
endif

test_glib_testing = executable('test_glib_testing', ['TestGlibTesting.vala'],
			dependencies : [gio_dep]
			)

test_mock = executable('test_mock', ['TestMock.vala', 'MockFramework.vala'],
			dependencies : [gio_dep]
			)

test_tox_core = executable('test_tox_core', ['TestToxCore.vala'],
			dependencies : [gio_dep, tox_dep]
			)

test_venom_config = executable('test_venom_config', ['TestVenomConfig.vala'],
			dependencies : [gio_dep, config_dep]
			)

test_contact = executable('test_contact', ['TestContact.vala',
			join_paths(root_source_dir, 'core/Contact.vala'),
			join_paths(root_source_dir, 'core/Interfaces.vala'),
			join_paths(root_source_dir, 'core/Tools.vala'),
			join_paths(root_source_dir, 'tox/ToxContact.vala')],
			dependencies : [gtk_dep, config_dep, gdk_dep, tox_dep]
			)

test_about = executable('test_about', ['TestAbout.vala',
			'Mock.vala', 'MockFramework.vala',
			join_paths(root_source_dir, 'view/AboutDialog.vala')],
			join_paths(root_source_dir, 'core/Interfaces.vala'),
			dependencies : [gtk_dep, config_dep]
			)

test_sqlite_db = executable('test_sqlite_db', ['TestSqliteDb.vala',
			join_paths(root_source_dir, 'tox/ContactDatabase.vala'),
			join_paths(root_source_dir, 'tox/MessageDatabase.vala'),
			join_paths(root_source_dir, 'core/Interfaces.vala'),
			join_paths(root_source_dir, 'db/DatabaseInterfaces.vala'),
			join_paths(root_source_dir, 'db/SqliteWrapper.vala'),
			join_paths(root_source_dir, 'tox/SqliteDhtNodeDatabase.vala'),
			join_paths(root_source_dir, 'db/SqliteSettingsDatabase.vala')
			],
			dependencies : [gtk_dep, sqlite_dep]
			)

test_message_db = executable('test_message_db', ['TestMessageDb.vala',
			'Mock.vala', 'MockFramework.vala',
			'MockDb.vala',
			'MockMessageDb.vala',
			join_paths(root_source_dir, 'tox/MessageDatabase.vala'),
			join_paths(root_source_dir, 'tox/SqliteDhtNodeDatabase.vala'),
			join_paths(root_source_dir, 'db/SqliteSettingsDatabase.vala'),
			join_paths(root_source_dir, 'db/SqliteWrapper.vala'),
			join_paths(root_source_dir, 'tox/ContactDatabase.vala'),
			join_paths(root_source_dir, 'core/Interfaces.vala'),
			join_paths(root_source_dir, 'db/DatabaseInterfaces.vala')
			],
			dependencies : [gtk_dep, sqlite_dep]
			)

test_dht_node_db = executable('test_dht_node_db', ['TestDhtNodeDb.vala',
			'Mock.vala', 'MockFramework.vala',
			'MockDb.vala',
			'MockDht.vala',
			join_paths(root_source_dir, 'tox/DhtNodeDatabase.vala'),
			join_paths(root_source_dir, 'db/SqliteWrapper.vala'),
			join_paths(root_source_dir, 'tox/SqliteDhtNodeDatabase.vala'),
			join_paths(root_source_dir, 'db/SqliteSettingsDatabase.vala'),
			join_paths(root_source_dir, 'tox/MessageDatabase.vala'),
			join_paths(root_source_dir, 'tox/ContactDatabase.vala'),
			join_paths(root_source_dir, 'core/Interfaces.vala'),
			join_paths(root_source_dir, 'db/DatabaseInterfaces.vala')
			],
			dependencies : [gtk_dep, sqlite_dep]
			)

test_json_web_dht_node_db = executable('test_json_web_dht_node_db', ['TestJsonWebDhtNodeDb.vala',
			'Mock.vala', 'MockFramework.vala',
			'MockDht.vala',
			join_paths(root_source_dir, 'tox/JsonWebDhtNodeDatabase.vala'),
			join_paths(root_source_dir, 'tox/DhtNodeDatabase.vala'),
			join_paths(root_source_dir, 'core/Interfaces.vala'),
			join_paths(root_source_dir, 'db/DatabaseInterfaces.vala')
			],
			dependencies : [gtk_dep, soup_dep, json_dep]
			)

example_plugin_lib = library('example_plugin', ['ExamplePlugin.vala',
			join_paths(root_source_dir, 'plugin/Plugin.vala'),
			join_paths(root_source_dir, 'core/Interfaces.vala')
			],
			dependencies : [gio_dep, gmodule_dep]
			)

test_plugin = executable('test_plugin', ['TestPlugin.vala', 'Mock.vala', 'MockFramework.vala',
			join_paths(root_source_dir, 'core/Interfaces.vala'),
			join_paths(root_source_dir, 'plugin/Pluginregistrar.vala'),
			join_paths(root_source_dir, 'plugin/Plugin.vala')
			],
			dependencies : [gio_dep, gmodule_dep]
			)

test('test glib', test_glib_testing)
test('test mocking framework', test_mock)
test('test tox core vapi', test_tox_core)
test('test venom config', test_venom_config)
test('test contact', test_contact)
test('test about', test_about)
test('test sqlite db', test_sqlite_db)
test('test message db', test_message_db)
test('test dht node db', test_dht_node_db)
test('test json web dht node db', test_json_web_dht_node_db)
test('test plugin', test_plugin)

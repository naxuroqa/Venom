root_source_dir = join_paths(meson.current_source_dir(), '..')

if posix_dep.found()
			executable('group_bot', ['GroupBot.vala',
						join_paths(root_source_dir, 'core/Tools.vala')],
						dependencies : [gio_dep, tox_dep, posix_dep]
						)
endif

if gst_dep.found()
			executable('photobooth_test', 'PhotoboothTest.vala',
						dependencies : [venom_dep]
						)
			executable('test_av', 'ToxAVTest.vala',
						dependencies : [venom_dep]
						)
endif

mox_lib = library('mox',
			[
						'util/Assert.vala',
						'util/UnitTest.vala',
						'util/MockFramework.vala',
			],
			dependencies: [glib_dep, gee_dep]
			)
mox_dep = declare_dependency(link_with : mox_lib)


test_glib_testing = executable('test_glib_testing', ['TestGlibTesting.vala'],
			dependencies : [gio_dep]
			)

test_identicon = executable('test_identicon', ['TestIdenticon.vala',
			'mocks/MockLogger.vala'
			],
			dependencies : [venom_dep, mox_dep]
			)

test_observable_list = executable('test_observable_list', ['TestObservableList.vala'],
			dependencies : [venom_dep, mox_dep]
			)

test_mock = executable('test_mock', ['TestMock.vala'],
			dependencies : [venom_dep, mox_dep]
			)

test_tox_core = executable('test_tox_core', ['TestToxCore.vala'],
			dependencies : [venom_dep, mox_dep]
			)

test_contact = executable('test_contact', ['TestContact.vala'],
			dependencies : [venom_dep, mox_dep]
			)

test_about = executable('test_about', ['TestAbout.vala',
			'mocks/MockLogger.vala'
			],
			dependencies : [venom_dep, mox_dep]
			)

test_sqlite_db = executable('test_sqlite_db', ['TestSqliteDb.vala'],
			dependencies : [venom_dep, mox_dep]
			)

test_dht_node_db = executable('test_dht_node_db', ['TestDhtNodeDb.vala',
			'mocks/MockLogger.vala',
			'mocks/MockDb.vala'
			],
			dependencies : [venom_dep, mox_dep]
			)

test_json_web_dht_node_db = executable('test_json_web_dht_node_db', ['TestJsonWebDhtNodeDb.vala',
			'mocks/MockLogger.vala'
			],
			dependencies : [venom_dep, mox_dep]
			)

test_tox_transfer = executable('test_tox_transfer', ['TestToxAdapterFiletransferListener.vala',
			'mocks/MockContact.vala',
			'mocks/MockLogger.vala',
			'mocks/MockFiletransfer.vala',
			'mocks/MockNotificationListener.vala',
			'mocks/MockToxSession.vala'
			],
			dependencies : [venom_dep, mox_dep]
			)

test_undo = executable('test_undo', ['TestUndo.vala'],
			dependencies : [venom_dep, mox_dep]
			)

test('test glib', test_glib_testing)
test('test identicon', test_identicon)
test('test mocking framework', test_mock)
test('test tox core vapi', test_tox_core)
test('test tox transfer', test_tox_transfer)
test('test observable list', test_observable_list)
test('test contact', test_contact)
test('test about', test_about)
test('test sqlite db', test_sqlite_db)
test('test dht node db', test_dht_node_db)
test('test json web dht node db', test_json_web_dht_node_db)
test('test undo', test_undo)

/*
 *    Pluginregistrar.vala
 *
 *    Copyright (C) 2018  Venom authors and contributors
 *
 *    This file is part of Venom.
 *
 *    Venom is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    Venom is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with Venom.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Venom {
  public errordomain PluginError {
    LOAD
  }

  class Pluginregistrar<T> : GLib.Object {
    private string path;
    private GLib.Type type;
    private GLib.Module module;
    private Logger logger;

    private delegate GLib.Type RegisterPluginFunction(GLib.Module module);

    public Pluginregistrar(Logger logger, string name) {
      assert(GLib.Module.supported());
      this.logger = logger;
      this.path = GLib.Module.build_path(GLib.Environment.get_variable("PWD"), name);
    }

    public void load() throws PluginError {
      logger.d("Loading plugin with path: '%s'".printf(path));

      module = GLib.Module.open(path, GLib.ModuleFlags.BIND_LAZY);
      if (module == null) {
        throw new PluginError.LOAD("Opening module at path '%s' failed".printf(path));
      }

      logger.d("Loaded module: '%s'".printf(module.name()));

      void* function;
      module.symbol("register_plugin", out function);
      unowned RegisterPluginFunction register_plugin = (RegisterPluginFunction) function;

      type = register_plugin(module);
      logger.d("Plugin type: " + type.name());
    }

    public T new_object () {
      return GLib.Object.new (type);
    }
  }
}

namespace org.freedesktop.portal {
  [DBus(name = "org.freedesktop.portal.Request", timeout = 120000)]
  public interface Request : GLib.Object {

    [DBus(name = "Close")]
    public abstract void close() throws DBusError, IOError;

    [DBus(name = "Response")]
    public signal void response(uint response, GLib.HashTable<string, GLib.Variant> results);
  }
}

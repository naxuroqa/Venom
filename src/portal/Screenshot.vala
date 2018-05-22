namespace org.freedesktop.portal {
  [DBus(name = "org.freedesktop.portal.Screenshot", timeout = 120000)]
  public interface Screenshot : GLib.Object {

    [DBus(name = "Screenshot")]
    public abstract GLib.ObjectPath screenshot(string parent_window, GLib.HashTable<string, GLib.Variant> options) throws DBusError, IOError;
  }
}

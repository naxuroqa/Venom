using Gtk;
using GLib;
using Tox;
namespace Venom {

public class Main {
    public static int main (string[] args) {

      Gtk.init (ref args);

      ContactList contact_list;

      try {
        contact_list = ContactList.create();
        contact_list.show();
      } catch ( Error e ) {
        stderr.printf("Could not load UI: %s\n", e.message);
        return 1;
      }

      Gtk.main();

      return 0;
    }
  }
}

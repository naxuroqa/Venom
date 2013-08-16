using Gtk;

namespace Venom {
public class Main {
    public static int main (string[] args) {
        Gtk.init (ref args);

        ContactList contact_list;

        try {
          contact_list = ContactList.createContactList();
          contact_list.contact_list_window.destroy.connect (Gtk.main_quit);
          contact_list.contact_list_window.show_all ();
        } catch ( Error e ) {
          stderr.printf("Could not load UI: %s\n", e.message);
          return 1;
        }

        Gtk.main();
        return 0;
    }
  }
}

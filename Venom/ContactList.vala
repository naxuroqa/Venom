using Gtk;
using Gee;
namespace Venom {
  public class ContactList : Object {
    private ArrayList<Contact> contacts;
    private ToxSession session;

    public Window contact_list_window { get; private set; }

    public ContactList( Window contact_list_window ) {
      this.contacts = new ArrayList<Contact>();
      this.contact_list_window = contact_list_window;
      session = new ToxSession();

      try {
        session.load_from_file("data");
        stdout.printf("Successfully loaded messenger data.\n");
      } catch (Error e) {
        session.save_to_file("data");
      }
      session.start();
    }

    ~ContactList() {
      session.stop();
      session.join();
      session.save_to_file("data");
      stdout.printf("Session ended gracefully.\n");
    }

    public static ContactList create_contact_list( string filename, string window_name ) throws Error {
      Builder builder = new Builder();
      builder.add_from_file("sample.ui");
      builder.connect_signals(null);
      Window window = builder.get_object("window") as Window;
      return new ContactList(window);
    }
  }
}

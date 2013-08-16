using Gtk;
namespace Venom {
  public class ContactList : Object {
    private Contact[] contacts;
    private Window _contact_list_window;

    public Window contact_list_window {
      get { return _contact_list_window; }
    }

    public ContactList( Window contact_list_window ) {
      contacts = new Contact[10];
      _contact_list_window = contact_list_window;
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

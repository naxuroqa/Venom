namespace Venom {
  public class ContactStore : Gtk.ListStore {
    private Gee.Collection<Contact> contacts;
    public ContactStore() {
      Contacts = new List<Contact>();
    }
    
  }
}

/*
 *    ConferenceInfoViewModel.vala
 *
 *    Copyright (C) 2018 Venom authors and contributors
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
  public class ConferenceInfoViewModel : GLib.Object {

    public string title { get; set; }
    public string title_error { get; set; }
    public bool title_error_visible { get; set; }
    public signal void leave_view();

    private ILogger logger;
    private ConferenceInfoWidgetListener listener;

    private Conference contact;
    private ObservableList peers_list;

    public ConferenceInfoViewModel(ILogger logger, ConferenceInfoWidgetListener listener, Conference contact) {
      logger.d("ConferenceInfoViewModel created.");
      this.logger = logger;
      this.contact = contact;
      this.listener = listener;

      set_info();
      contact.changed.connect(set_info);
      peers_list = new ObservableList();
      peers_list.set_collection(contact.get_peers().values);

      notify["title"].connect(() => { title_error_visible = false; });
    }

    private void set_info() {
      title = contact.title;
    }

    public ListModel get_list_model() {
      return new ObservableListModel(peers_list);
    }

    private void show_error(string message) {
      title_error_visible = true;
      title_error = message;
    }

    public void on_apply_clicked() {
      logger.d("on_apply_clicked");
      try {
        listener.on_change_conference_title(contact, title);
      } catch (Error e) {
        var message = "Could not change title: " + e.message;
        show_error(message);
        logger.e(message);
      }
    }

    public void on_leave_clicked() {
      try {
        listener.on_remove_conference(contact);
      } catch (Error e) {
        var message = "Could not remove conference: " + e.message;
        show_error(message);
        logger.e(message);
        return;
      }
      leave_view();
    }

    ~ConferenceInfoViewModel() {
      logger.d("ConferenceInfoViewModel destroyed.");
    }
  }

  public interface ConferenceInfoWidgetListener : GLib.Object {
    public abstract void on_remove_conference(IContact contact) throws Error;
    public abstract void on_change_conference_title(IContact contact, string title) throws Error;
  }
}

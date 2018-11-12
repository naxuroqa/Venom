/*
 *    MessageViewModel.vala
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
  public class MessageViewModel : GLib.Object {
    public string sender            { get; set; }
    public bool   sender_sensitive  { get; set; }
    public Gdk.Pixbuf sender_image  { get; set; }
    public string timestamp         { get; set; }
    public string timestamp_tooltip { get; set; }
    public string message           { get; set; }
    public bool   sent_visible      { get; set; }
    public bool   sent_dim          { get; set; }
    public string sent_tooltip      { get; set; }
    public string sender_color      { get; set; default = ""; }
    public bool   sender_bold       { get; set; default = true; }

    private Logger logger;
    private Message message_content;
    private FormattedMessage formatted_message;
    private ISettingsDatabase settings;

    private const string[] colors_light = { "#F44336", "#E91E63", "#9C27B0", "#673AB7", "#2196F3", "#03A9F4", "#00BCD4", "#009688", "#4CAF50", "#FFEB3B" };
    private const string[] colors_dark = { "#8BC34A", "#3F51B5", "#CDDC39", "#FFC107", "#FF9800", "#FF5722", "#795548", "#9E9E9E", "#607D8B" };

    public MessageViewModel(Logger logger, Message message_content, UserInfo user_info, ISettingsDatabase settings) {
      logger.d("MessageViewModel created.");
      this.logger = logger;
      this.message_content = message_content;
      this.settings = settings;

      formatted_message = (FormattedMessage) message_content;

      settings.notify["enable-dark-theme"].connect(on_theme_changed);
      update_sender_color();

      message_content.notify["state"].connect(update_message_state);
      update_message_state();

      Gdk.Pixbuf? pixbuf = null;
      sender_sensitive = message_content.sender == MessageSender.REMOTE;
      switch (message_content.sender) {
        case MessageSender.LOCAL:
          sender = user_info.name;
          pixbuf = user_info.avatar.pixbuf;
          break;
        case MessageSender.SYSTEM:
          sender = _("Notice");
          break;
        case MessageSender.REMOTE:
          sender = formatted_message.get_sender_plain();
          pixbuf = formatted_message.get_sender_image();
          break;
        default:
          logger.e("MessageViewModel unknown message sender!");
          break;
      }

      message = formatted_message.get_message_plain();
      if (pixbuf != null) {
        sender_image = round_corners(pixbuf.scale_simple(20, 20, Gdk.InterpType.BILINEAR));
      }
      timestamp = message_content.timestamp.format("%X");
      timestamp_tooltip = message_content.timestamp.format("%c");
    }

    private void update_message_state() {
      if (message_content.sender == MessageSender.LOCAL) {
        sent_dim = message_content.state != TransmissionState.RECEIVED;
        if (message_content.state == TransmissionState.SENT) {
          sent_visible = true;
          sent_tooltip = _("Message sent ✓");
        } else if (message_content.state == TransmissionState.RECEIVED) {
          sent_visible = true;
          sent_tooltip = _("Message received ✓");
        }
      }
    }

    private void on_theme_changed() {
      update_sender_color();
      notify_property("sender");
    }

    private void update_sender_color() {
      if (message_content.sender != MessageSender.REMOTE) {
        return;
      }
      var hash = formatted_message.get_sender_id().hash();
      if (settings.enable_dark_theme) {
        sender_color = colors_light[hash % colors_light.length];
      } else {
        sender_color = colors_dark[hash % colors_dark.length];
      }
    }

    ~MessageViewModel() {
      logger.d("MessageViewModel destroyed.");
    }
  }

  public class PangoTransform : GLib.Object {
    public string color { get; set; default = ""; }
    public bool bold { get; set; }

    public bool transform(GLib.Binding binding, GLib.Value source, ref GLib.Value dest) {
      var source_string = source.get_string();
      if (bold || color != "") {
        var builder = new StringBuilder();
        builder.append("<span ");
        if (bold) {
          builder.append("font_weight=\"bold\" ");
        }
        if (color != "") {
          builder.append(@"color=\"$color\"");
        }
        builder.append(">");
        builder.append(Markup.escape_text(source_string));
        builder.append("</span>");
        dest.set_string(builder.str);
      } else {
        dest.set_string(Markup.escape_text(source_string));
      }
      return true;
    }
  }

  public class UriTransform {
    private Logger logger;
    public UriTransform(Logger logger) {
      this.logger = logger;
    }

    public bool transform(GLib.Binding binding, GLib.Value source, ref GLib.Value dest) {
      var source_string = source.get_string();
      try {
        dest.set_string(uri_regex().replace(Markup.escape_text(source_string), -1, 0, "<a href=\"\\g<u>\">\\g<u></a>"));
      } catch (RegexError e) {
        logger.e("Error transforming text: " + e.message);
        return false;
      }
      return true;
    }

    private static GLib.Regex _uri_regex;
    private static GLib.Regex uri_regex() throws RegexError {
      if (_uri_regex == null) {
        _uri_regex = new GLib.Regex("(?<u>[a-z]+://\\S*)");
      }
      return _uri_regex;
    }
  }
}

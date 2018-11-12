/*
 *    Logger.vala
 *
 *    Copyright (C) 2013-2018 Venom authors and contributors
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
  public interface Logger : Object {
    public abstract void d(string message);
    public abstract void i(string message);
    public abstract void w(string message);
    public abstract void e(string message);
    public abstract void f(string message);
    public abstract string get_log();
    public abstract void attach_to_glib();
  }

  namespace TermColor {
    public const string BLACK = "\x1B[30m";
    public const string RED = "\x1B[31m";
    public const string GREEN = "\x1B[32m";
    public const string YELLOW = "\x1B[33m";
    public const string BLUE = "\x1B[34m";
    public const string MAGENTA = "\x1B[35m";
    public const string CYAN = "\x1B[36m";
    public const string WHITE = "\x1B[37m";

    public const string RESET = "\x1B[0m";

    public const string INFO = TermColor.GREEN;
    public const string WARNING = TermColor.YELLOW;
    public const string ERROR = TermColor.RED;
    public const string FATAL = TermColor.MAGENTA;
  }

  namespace PangoHelper {
    public static string insert_span(string attributes, string content) {
      return @"<span $attributes>$content</span>";
    }
    public static string bold(string text) {
      return @"<b>$text</b>";
    }
  }

  public enum LogLevel {
    DEBUG,
    INFO,
    WARNING,
    ERROR,
    FATAL;

    public string to_string() {
      switch (this) {
        case DEBUG:
          return "DEBUG";
        case INFO:
          return TermColor.INFO + "INFO " + TermColor.RESET;
        case WARNING:
          return TermColor.WARNING + "WARN " + TermColor.RESET;
        case ERROR:
          return TermColor.ERROR + "ERROR" + TermColor.RESET;
        case FATAL:
          return TermColor.FATAL + "FATAL" + TermColor.RESET;
        default:
          assert_not_reached();
      }
    }

    public string to_markup() {
      switch(this) {
        case DEBUG:
          return "DEBUG";
        case INFO:
          return PangoHelper.insert_span("foreground=\"green\"", "INFO ");
        case WARNING:
          return PangoHelper.insert_span("foreground=\"yellow\"", "WARN ");
        case ERROR:
          return PangoHelper.insert_span("foreground=\"red\"", "ERROR");
        case FATAL:
          return PangoHelper.insert_span("foreground=\"magenta\"", "FATAL");
        default:
          assert_not_reached();
      }
    }
  }

  public class CommandLineLogger : Logger, Object {
    public static LogLevel displayed_level { get; set; default = LogLevel.WARNING; }
    private StringBuilder log_builder;
    public string get_log() {
      return log_builder.str;
    }

    public CommandLineLogger() {
      log_builder = new StringBuilder();
      d("CommandLineLogger created.");
    }

    ~CommandLineLogger() {
      d("CommandLineLogger destroyed.");
    }

    public void d(string message) {
      log(LogLevel.DEBUG, message);
    }

    public void i(string message) {
      log(LogLevel.INFO, message);
    }

    public void w(string message) {
      log(LogLevel.WARNING, message);
    }

    public void e(string message) {
      log(LogLevel.ERROR, message);
    }

    public void f(string message) {
      log(LogLevel.FATAL, message);
    }

    private void glib_log_function(string? log_domain, LogLevelFlags log_levels, string message) {
      string concatMessage = log_domain != null
                             ? log_domain + " : " + message
                             : message;
      switch (log_levels) {
        case LogLevelFlags.FLAG_FATAL:
        case LogLevelFlags.LEVEL_CRITICAL:
          f(concatMessage);
          break;
        case LogLevelFlags.LEVEL_ERROR:
          e(concatMessage);
          break;
        case LogLevelFlags.LEVEL_WARNING:
          w(concatMessage);
          break;
        case LogLevelFlags.LEVEL_INFO:
          i(concatMessage);
          break;
        case LogLevelFlags.LEVEL_DEBUG:
          d(concatMessage);
          break;
        default:
          w(concatMessage);
          break;
      }
    }

    public void attach_to_glib() {
      //GLib.Log.set_default_handler(glib_log_function);
      GLib.Log.set_handler(null, LogLevelFlags.LEVEL_MASK, glib_log_function);
      GLib.Log.set_handler("GLib", LogLevelFlags.LEVEL_MASK, glib_log_function);
      GLib.Log.set_handler("GLib-GObject", LogLevelFlags.LEVEL_MASK, glib_log_function);
      GLib.Log.set_handler("Gdk", LogLevelFlags.LEVEL_MASK, glib_log_function);
      GLib.Log.set_handler("Json", LogLevelFlags.LEVEL_MASK, glib_log_function);
    }

    public void log(LogLevel level, string message) {
      log_builder.append("[%s] %s\n".printf(level.to_markup(), message));

      if (level < displayed_level) {
        return;
      }

      unowned FileStream s = level < LogLevel.ERROR ? stdout : stderr;
      s.printf("[%s] %s\n", level.to_string(), message);
    }
  }
}

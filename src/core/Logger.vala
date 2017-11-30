/*
 *    Logger.vala
 *
 *    Copyright (C) 2013-2014  Venom authors and contributors
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
          return "\x1B[32m" + "INFO " + "\x1B[0m";
        case WARNING:
          return "\x1B[33m" + "WARN " + "\x1B[0m";
        case ERROR:
          return "\x1B[31m" + "ERROR" + "\x1B[0m";
        case FATAL:
          return "\x1B[35m" + "FATAL" + "\x1B[0m";
        default:
          assert_not_reached();
      }
    }
  }

  public class Logger : ILogger, Object {
    public static LogLevel displayed_level { get; set; default = LogLevel.WARNING; }

    public Logger() {
      d("Logger created.");
    }

    ~Logger() {
      d("Logger destroyed.");
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
    }

    public static void log(LogLevel level, string message) {
      if (level < displayed_level) {
        return;
      }
      unowned FileStream s = level < LogLevel.ERROR ? stdout : stderr;
      s.printf("[%s] %s\n", level.to_string(), message);
    }
  }
}

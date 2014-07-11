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
      switch(this) {
        case DEBUG:
          return "DBG   ";
        case INFO:
          return "INFO  ";
        case WARNING:
          return "WARN  ";
        case ERROR:
          return "ERROR ";
        case FATAL:
          return "FATAL ";
        default:
          return "UNKOWN";
      }
    }
  }
  public class Logger : GLib.Object {
    public static LogLevel displayed_level {get; set; default = LogLevel.WARNING;}
    public static bool use_coloring {get; set; default = true;}
    public static void init() {
      Log.set_default_handler (glib_log);
    }
    public static void log(LogLevel level, string message) {
      if(level < displayed_level) {
        return;
      }
      unowned FileStream s = level < LogLevel.ERROR ? stdout : stderr;
      if(use_coloring) {
        s.printf("\x001b[%dm[%s]\x001b[0m %s\n", level + 90, level.to_string(), message);
      } else {
        s.printf("[%s] %s\n", level.to_string(), message);
      }
    }
    private static void glib_log(string? domain, LogLevelFlags flags, string message) {
      string logmessage = "%s %s".printf(domain ?? "", message);

      switch (flags) {
        case LogLevelFlags.LEVEL_CRITICAL:
          log(LogLevel.FATAL, logmessage);
          break;
        case LogLevelFlags.LEVEL_ERROR:
          log(LogLevel.ERROR, logmessage);
          break;
        case LogLevelFlags.LEVEL_INFO:
        case LogLevelFlags.LEVEL_MESSAGE:
          log(LogLevel.INFO, logmessage);
          break;
        case LogLevelFlags.LEVEL_DEBUG:
          log(LogLevel.DEBUG, logmessage);
          break;
        case LogLevelFlags.LEVEL_WARNING:
        default:
          log(LogLevel.WARNING, logmessage);
          break;
      }
    }
  }
}

/*
 *    config.vapi
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

[CCode (cprefix = "", lower_case_cprefix = "VENOM_", cheader_filename = "config.h")]
namespace Venom.Config {
  public const int VERSION_MAJOR;
  public const int VERSION_MINOR;
  public const int VERSION_PATCH;
  public const string VERSION;

  public const string COPYRIGHT_NOTICE;
  public const string SHORT_DESCRIPTION;
  public const string WEBSITE;
}

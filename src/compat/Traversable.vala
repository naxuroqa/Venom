/*
 *    Traversable.vala
 *
 *    Copyright (C) 2019 Venom authors and contributors
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
 /* This file is partially adapted from traversable.vala in libgee
  *
  * Copyright (C) 2011-2012  Maciej Piechotka
  *
  * This library is free software; you can redistribute it and/or
  * modify it under the terms of the GNU Lesser General Public
  * License as published by the Free Software Foundation; either
  * version 2.1 of the License, or (at your option) any later version.

  * This library is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  * Lesser General Public License for more details.

  * You should have received a copy of the GNU Lesser General Public
  * License along with this library; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
  *
  * Author:
  * 	Maciej Piechotka <uzytkownik2@gmail.com>
  */

namespace Venom.Compat {
  public static Gee.Iterator<G> order_by<G>(Gee.Traversable<G> traversable, owned CompareDataFunc<G> compare = null) {
    var result = new Gee.ArrayList<G> ();
    traversable.foreach ((item) => result.add(item));
    result.sort((owned) compare);
    return result.iterator();
  }
}

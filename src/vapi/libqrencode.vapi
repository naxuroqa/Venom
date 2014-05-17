/**
 * qrencode - QR Code encoder
 *
 * Copyright (C) 2006-2012 Kentaro Fukuchi <kentaro@fukuchi.org>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 */
/**
 *  Vapi file taken from https://github.com/apmasell/vapis/blob/master/libqrencode.vapi
 */
/**
 * A library for encoding data in a QR Code symbol, a kind of 2D symbology.
 */
[CCode (cheader_filename = "qrencode.h")]
namespace QR {
	/**
	 * The state of each module (dot).
	 *
	 * Only {@link Dot.BLACK} is useful for usual applications.
	 */
	[CCode (cname = "unsigned char", has_type_id = false)]
	[Flags]
	public enum Dot {
		[CCode (cname = "1")]
		BLACK,
		[CCode (cname = "2")]
		DATA_AND_ECC,
		[CCode (cname = "4")]
		FORMAT,
		[CCode (cname = "8")]
		VERSION,
		[CCode (cname = "16")]
		TIMING,
		[CCode (cname = "32")]
		ALIGNMENT,
		[CCode (cname = "64")]
		FINDER,
		[CCode (cname = "128")]
		NON_DATA
	}

	/**
	 * Level of error correction.
	 */
	[CCode (cname = "QRecLevel", cprefix = "QR_ECLEVEL_")]
	public enum ECLevel {
		/**
		 * Lowest
		 */
		L,
		M,
		Q,
		/**
		 * Highest
		 */
		H
	}

	/**
	 * Encoding mode.
	 */
	[CCode (cname = "QRencodeMode", cprefix = "QR_MODE_")]
	public enum Mode {
		/**
		 * Numeric mode
		 */
		NUM,
		/**
		 * Alphabet-numeric mode
		 */
		AN,
		/**
		 * 8-bit data mode
		 */
		[CCode (cname = "QR_MODE_8")]
		EIGHT_BIT,
		/**
		 * Kanji (shift-jis) mode
		 */
		KANJI,
		/**
		 * Internal use only
		 */
		STRUCTURE
	}

	/**
	 * Symbol data is represented as an array contains width*width {@link uint8}.
	 *
	 * Each point represents a module (dot).
	 * described.
	 */
	[CCode (cname = "QRcode", free_function = "QRcode_free", has_type_id = false)]
	[Compact]
	public class Code {
		public int version;
		public int width;
		[CCode (array_length = false)]
		public Dot[] data;
		/**
		 * Create a symbol from the string.
		 *
		 * The library automatically parses the input string and encodes in a QR Code
		 * symbol.
		 * This function is THREAD UNSAFE.
		 * @param str input string.
		 * @param version version of the symbol. If 0, the library chooses the
		 * minimum version for the given input data.
		 * @param level error correction level.
		 * @param hint tell the library how non-alphanumerical characters should be
		 * encoded. If {@link Mode.KANJI} is given, kanji characters will be encoded
		 * as Shif-JIS characters. If {@link Mode.EIGHT_BIT} is given, all of
		 * non-alphanumerical characters will be encoded as is. If you want to embed
		 * UTF-8 string, choose this.
		 * @param casesensitive case-sensitive or not.
		 * @return The version of the result QRcode may be larger than the designated
		 * version. On error, null is returned, and errno is set to indicate the
		 * error.
		 */
		[CCode (cname = "QRcode_encodeString")]
		public static Code? encode_string (string str, int version, ECLevel level, Mode hint, bool casesensitive);

		/**
		 * Create a symbol from the string encoding the whole data in 8-bit mode.
		 * @see encode_string
		 */
		[CCode (cname = "QRcode_encodeString8bit")]
		public static Code? encode_string_8bit (string str, int version, ECLevel level);
		public bool get (int x, int y) {
			if (x < width && y < width) {
				return Dot.BLACK in data[x * width + y];
			} else {
				return false;
			}
		}
	}

	/**
	 * The input strings and version and error correction level.
	 */
	[CCode (cname = "QRinput", free_function = "QRinput_free", has_type_id = false)]
	[Compact]
	public class Input {
		/**
		 * Instantiate an input data object.
		 * @param version version number.
		 * @param level Error correction level.
		 * @return On error, null is returned and errno is set to indicate the
		 * error.
		 */
		[CCode (cname = "QRinput_new2")]
		public Input? create (int version, ECLevel level);

		/**
		 * The current error correction level.
		 */
		public ECLevel correction {
			[CCode (cname = "QRinput_getErrorCorrectionLevel")]
			get;
			[CCode (cname = "QRinput_setErrorCorrectionLevel")]
			set;
		}

		/**
		 * The current version. (Zero for automatic)
		 */
		public int version {
			[CCode (cname = "QRinput_getVersion")]
			get;
			[CCode (cname = "QRinput_setVersion")]
			set;
		}

		/**
		 * Instantiate an input data object.
		 *
		 * The version is set to 0 (auto-select) and the error correction level is
		 * set to {@link ECLevel.L}.
		 */
		[CCode (cname = "QRinput_new")]
		public Input ();

		/**
		 * Append data to an input object.
		 * The data is copied and appended to the input object.
		 * @param mode encoding mode.
		 * @param data the input data.
		 * @return false on success
		 */
		[CCode (cname = "QRinput_append")]
		public bool append (Mode mode, [CCode (array_length_pos = 1.1)] uint8[] data);

		/**
		 * Validate the input data.
		 * @param mode encoding mode.
		 * @param data the input data.
		 * @return false on success
		 */
		[CCode (cname = "QRinput_check")]
		public bool check (Mode mode, [CCode (array_length_pos = 1.1)] uint8[] data);

		/**
		 * Create a symbol from the input data.
		 *
		 * This function is THREAD UNSAFE.
		 * @return The version of the result QRcode may be larger than the
		 * designated version. On error, NULL is returned, and errno is set to
		 * indicate the error.
		 */
		[CCode (cname = "QRcode_encodeInput")]
		public Code? encode ();

		/**
		 * Split an input.
		 *
		 * It calculates a parity, set it, then insert structured-append headers.
		 *
		 * Version number and error correction level must be set.
		 * @return a set of input data. On error, null is returned, and errno is
		 * set to indicate the error.
		 */
		[CCode (cname = "QRinput_splitQRinputToStruct")]
		public extern StructSym? split ();
	}
	/**
	 * Singly-linked list of {@link Code}s.
	 *
	 * Used to represent a structured symbols.
	 */
	[CCode (cname = "QRcode_List", free_function = "QRcode_List_free", has_type_id = false)]
	[Compact]
	public class List {
		public Code code;
		public List? next;

		/**
		 * The number of symbols included.
		 */
		public int size {
			[CCode (cname = "QRcode_List_size")]
			get;
		}
		/**
		 * Create structured symbols from the string.
		 *
		 * The library automatically parses the input string and encodes in a QR Code
		 * symbol.
		 *
		 * This function is THREAD UNSAFE.
		 * @param str input string.
		 * @param version version of the symbol.
		 * @param level error correction level.
		 * @param hint tell the library how non-alphanumerical characters should be
		 * encoded. If {@link Mode.KANJI} is given, kanji characters will be
		 * encoded as Shif-JIS characters. If {@link Mode.EIGHT_BIT} is given, all
		 * of non-alphanumerical characters will be encoded as is. If you want to
		 * embed UTF-8 string, choose this.
		 * @param casesensitive case-sensitive or not.
		 * @return On error, null is returned, and errno is set to indicate the
		 * error.
		 */
		[CCode (cname = "QRcode_encodeStringStructured")]
		public static List? encode_string (string str, int version, ECLevel level, Mode hint, bool casesensitive);

		/**
		 * Create structured symbols from the string encoding whole data in 8-bit mode.
		 * @see encode_string
		 */
		[CCode (cname = "QRcode_encodeString8bitStructured")]
		public static List? encode_string_8bit (string str, int version, ECLevel level);
	}
	/**
	 * Set of {@link Input} for structured symbols.
	 */
	[CCode (cname = "QRinput_Struct", free_function = "QRinput_Struct_free", has_type_id = false)]
	[Compact]
	public class StructSym {
		/**
		 * Instantiate a set of input data object.
		 */
		[CCode (cname = "QRinput_Struct_new")]
		public StructSym ();

		/**
		 * The parity of structured symbols.
		 */
		public uint8 parity {
			[CCode (cname = "QRinput_Struct_setParity")]
			set;
		}

		/**
		 * Append a QRinput object to the set.
		 *
		 * Never append the same QRinput object twice or more.
		 * @param input an input object.
		 * @return number of input objects in the structure or -1 if an error occurred.
		 */
		[CCode (cname = "QRinput_Struct_appendInput")]
		public int append (Input input);

		/**
		 * Create structured symbols from the input data.
		 *
		 * This function is THREAD UNSAFE.
		 */
		[CCode (cname = "QRcode_encodeInputStructured")]
		public List? encode ();

		/**
		 * Insert structured-append headers to the input structure.
		 *
		 * It calculates a parity and set it if the parity is not set yet.
		 * @return false on success
		 */
		[CCode (cname = "QRinput_Struct_insertStructuredAppendHeaders")]
		public bool insert_headers ();
	}
}

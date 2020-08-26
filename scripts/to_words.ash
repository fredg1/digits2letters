//Turns digits into words, with Engineering notation.

// ******************************
// *         Settings           *
// ******************************

// Do you want to get "2 hundred 'AND' six"? "five million 'AND' thirty-two"?
// (or whatever you put as __and_string)
boolean __separate_non_whole_hundreds_with___and_string = true;
string __and_string = "and ";

// Do you want to get "one billion',' three hundred forty thousand',' eighty-nine'"?
// (or whatever you put as __group_string)
boolean __separate_powers_of_1000_with___group_string = false;
string __group_string = ",";

// Choose which notation you'll want to use for big numbers
string [3] notation_selection = { //(don't touch that array, only look at the choices)
    0:"short scale", //million, billion, trillion, quadrillion
    1:"long scale",  //million, milliard, billion, billiard
    2:"base"         // * 10^6, * 10^9, * 10^12, * 10^15
};
int __notation_choice = 0; //choose 0, 1 or 2

// **************************************************
// *   End of Settings (and start of the script)    *
// **************************************************


if (!__separate_non_whole_hundreds_with___and_string)
    __and_string = "";
if (!__separate_powers_of_1000_with___group_string)
    __group_string = "";



boolean stringHasPrefix(string s, string prefix) {
    if (s.length() < prefix.length())
        return false;
    else if (s.length() == prefix.length())
        return (s == prefix);
    else if (substring(s, 0, prefix.length()) == prefix)
        return true;
    return false;
}

boolean stringHasSuffix(string s, string suffix) {
    if (s.length() < suffix.length())
        return false;
    else if (s.length() == suffix.length())
        return (s == suffix);
    else if (substring(s, s.length() - suffix.length()) == suffix)
        return true;
    return false;
}


static string [int] __uniwords_to_cardinal_map;
static string [int] __tens_to_cardinal_map;
string tens_to_cardinal(int value, boolean is_following_digits_of_larger_number) {
    // Takes [0-99] and turns it into ["zero"-"ninety-nine"] (no negatives)
    if (__uniwords_to_cardinal_map.count() == 0) //initiate map
        __uniwords_to_cardinal_map = split_string("zero,one,two,three,four,five,six,seven,eight,nine,ten,eleven,twelve,thirteen,fourteen,fifteen,sixteen,seventeen,eighteen,nineteen", ",");
    
    string result;
    if (is_following_digits_of_larger_number)
        result = __and_string;
    
    int v = value % 100; //Sent something bigger than 99? Your problem.
    
    if (v < 20) //stupid "teens"
        return result + __uniwords_to_cardinal_map[v];
    
    if (__tens_to_cardinal_map.count() == 0) //initiate map
        __tens_to_cardinal_map = {2:"twenty", 3:"thirty", 4:"forty", 5:"fifty", 6:"sixty", 7:"seventy", 8:"eighty", 9:"ninety"};
    
    int tens = v / 10;
    result += __tens_to_cardinal_map[tens];
    
    int units = v % 10;
    if (units != 0)
        return result + "-" + __uniwords_to_cardinal_map[units];
    return result;
}
string tens_to_cardinal(int value) {
    return tens_to_cardinal(value, false);
}

string hundreds_to_cardinal(int value, boolean is_following_digits_of_larger_number) {
    // Takes [0-999] and turns it into ["zero"-"nine hundred ninety-nine"] (no negatives)
    int v = value % 1000; //Sent something bigger than 999? Your problem.
    
    int hundreds = v / 100;
    if (hundreds == 0)
        return tens_to_cardinal(v, is_following_digits_of_larger_number);
    
    string result = tens_to_cardinal(hundreds, false) + " hundred";
    
    int rest = v % 100;
    if (rest > 0)
        return result + " " + tens_to_cardinal(rest, is_following_digits_of_larger_number);
    return result;
}
string hundreds_to_cardinal(int value) {
    return hundreds_to_cardinal(value, false);
}

buffer getPowerOf1000Suffix(int order_of_magnitude) {
    //Pretty sure I won't need to do the same thing as I did with th base input here; people won't send numbers with over 6.3 BILLION digits
    //https://en.wikipedia.org/wiki/Names_of_large_numbers
    buffer result;
    if (notation_selection[__notation_choice] == "base")
        return result.append(" * 10^" + order_of_magnitude);
    
    int power_of_1000 = order_of_magnitude / 3;
    
    if (power_of_1000 == 0) /* if power_of_1000 is 0 (i.e. original number was < 1000) */
        return result.append("");
    
    result.append(" ");
    
    if (power_of_1000 == 1) /* if power_of_1000 is 1 (i.e. original number was 999 < x < 1 000 000) */
        return result.append("thousand");
    
    //Still here? Now's the hard part
    string suffix = "illion";
    if (notation_selection[__notation_choice] == "long scale") { //"short scale" always stays "illion"
        if (power_of_1000 % 2 == 1)
            suffix = "illiard";
        power_of_1000 = power_of_1000 / 2;
    } else
        power_of_1000--;
    
    /* latin numbers, used for powers of 1000, go from 1 to 999 */
    string [10] single_digit_to_illion, units_to_latin, tens_to_latin, hundreds_to_latin;
    units_to_latin = {
        0:"",
        1:"un",
        2:"duo",
        3:"tre",
        4:"quattuor",
        5:"quin",
        6:"se",
        7:"septe",
        8:"octo",
        9:"nove"
    };
    tens_to_latin = {
        0:"",
        1:"deci",
        2:"viginti",
        3:"triginta",
        4:"quadraginta",
        5:"quinquaginta",
        6:"sexaginta",
        7:"septuaginta",
        8:"octoginta",
        9:"nonaginta"
    };
    hundreds_to_latin = {
        0:"",
        1:"centi",
        2:"ducenti",
        3:"trecenti",
        4:"quadringenti",
        5:"quingenti",
        6:"sescenti",
        7:"septingenti",
        8:"octingenti",
        9:"nongenti"
    };
    single_digit_to_illion = {
        0:"n",
        1:"m",
        2:"b",
        3:"tr",
        4:"quadr",
        5:"quint",
        6:"sext",
        7:"sept",
        8:"oct",
        9:"non"
    };
    
    
    int order_of_magnitude_of_power_of_1000 = power_of_1000.length() - 1;
    int power_of_1000_of_power_of_1000 = order_of_magnitude_of_power_of_1000 / 3;
    for current_power_of_1000 from power_of_1000_of_power_of_1000 downto 0 {
        int number_in_current_magnitude = power_of_1000 / 1000**current_power_of_1000 % 1000;
        
        if (number_in_current_magnitude < 10)
            result.append(single_digit_to_illion[number_in_current_magnitude]);
        else {
            result.append(units_to_latin[number_in_current_magnitude % 10]);
            result.append(tens_to_latin[number_in_current_magnitude / 10 % 10]);
            result.append(hundreds_to_latin[number_in_current_magnitude / 100]);
        }
        
        if (current_power_of_1000 == 0)
            result.append(suffix);
        else
            result.append("illi");
    }
    
    /* the name for that power of 1000 is now "build". However, before sending, a few corrections need to be applied */
    void update_buffer(string new_value) {
        result.set_length(0);
        result.append(new_value);
    }
    /* ii => i, ai => i */
    create_matcher("[ai]i", result).replace_all("i").update_buffer();
    
    void replace_groups(string prefix, string letters_to_check, string letter_to_add) {
        matcher m = create_matcher(prefix + letters_to_check, result);
        if (!m.find()) return;
        for i from 1 upto m.group_count()
            m.replace_all(prefix + letter_to_add + m.group(i)).update_buffer();
    }
    
    /* trev => tresv, treq => tresq, tret => trest */
    replace_groups("tre", "(v|q|t)", "s");
    /* sev => sesv, seq => sesq, set => sest */
    replace_groups("se", "(v|q|t)", "s");
    /* seo => sexo, sec => sexc */
    replace_groups("se", "(o|c)", "x");
    /* septeo => septemo, septev => septemv */
    replace_groups("septe", "(o|v)", "m");
    /* septec => septenc, septed => septend, septeq => septenq, septes => septens, septet => septent */
    replace_groups("septe", "(c|d|q|s|t)", "n");
    /* noveo => novemo, novev => novemv */
    replace_groups("nove", "(o|v)", "m");
    /* novec => novenc, noved => novend, noveq => novenq, noves => novens, novet => novent */
    replace_groups("nove", "(c|d|q|s|t)", "n");
    
    return result;
}

buffer int_to_cardinal(int v, int magnitude_offset, boolean is_start_of_number) {
    //max integer is 2 147 483 647, so process numbers +/-999 999 999 at a time
    buffer result;
    if (v < 0) {
        v = 0 - v;
        result.append("minus");
    }
    
    int order_of_magnitude = v.length() - 1;
    //876543210 => (876)(543)(210)
    //    43210 =>       (43)(210)
    int power_of_1000 = order_of_magnitude / 3;

    for current_power_of_1000 from power_of_1000 downto 0 {
        int v_in_current_magnitude = v / 1000**current_power_of_1000 % 1000;
        
        if (v_in_current_magnitude == 0)
            continue;
        
        boolean is_final_group = current_power_of_1000 + magnitude_offset == 0;
        boolean is_final_group_in_a_bigger_number = power_of_1000 > 0 && is_final_group;
        
        if (!is_start_of_number && (!is_final_group || v_in_current_magnitude > 99)) //want to avoid "<x> thousand, and five"
            result.append(__group_string);
        if (!is_start_of_number)
            result.append(" ");
        result.append(hundreds_to_cardinal(v_in_current_magnitude, is_final_group_in_a_bigger_number && notation_selection[__notation_choice] != "base")); //that final condition is to avoid a "<x> * 10^3 'and' <y> * 10^0"
        result.append(getPowerOf1000Suffix(current_power_of_1000 * 3 + magnitude_offset));
    }
    return result;
}
buffer int_to_cardinal(int v) {
    return int_to_cardinal(v, 0, true);
}

buffer to_cardinal(buffer raw) {
    buffer result;
    if (raw.stringHasPrefix("-"))
        result.append("minus ");

    buffer precleaned;
    precleaned.append(create_matcher("[^0-9a-zA-Z]", raw).replace_all("")); //remove anything other than digits and letters.

    buffer symbol_offset; //Look at the last number/letter of the chain of chars. If one of "those", offset the number accordingly.
    int [string] symbol_to_offset = {"d":1,"da":1,"h":2,"k":3,"m":6,"g":9,"t":12,"p":15,"e":18,"z":21,"y":24};
    matcher symbol = create_matcher("(da|d|DA|D|h|H|k|K|m|M|g|G|t|T|p|P|e|E|z|Z|y|Y)$", precleaned);
    if (symbol.find()) {
        int number_of_addl_zeroes = symbol_to_offset[symbol.group(1).to_lower_case()];
        while (number_of_addl_zeroes-- > 0)
            symbol_offset.append("0");
    }

    buffer cleaned;
    cleaned.append(create_matcher("[^0-9]", precleaned).replace_all("")).append(symbol_offset); //remove anything other than digits.


    //we now have our (potentially) very long number (stored as string). Only digits here
    //send them in groups of 9 digits max
    int extra_groups = ceil(cleaned.length() / 9.0) - 1;

    int start = 0;
    int end = cleaned.length() % 9;
    for i from extra_groups downto 0 {
        int current_magnitude =  i * 9;

        int current_number = cleaned.substring(start, end).to_int();

        if (current_number > 0)
            result.append(current_number.int_to_cardinal(current_magnitude, start == 0));

        start = end;
        end += 9;
    }
    return result;
}
buffer to_cardinal(string s) {
    buffer b;
    b.append(s);
    return b.to_cardinal();
}

string to_ordinal(buffer value) {
    buffer cardinal = to_cardinal(value);
    if (cardinal.stringHasSuffix("y"))
        return cardinal.substring(0, cardinal.length() - 1) + "ieth";
    if (cardinal.stringHasSuffix("one"))
        return cardinal.substring(0, cardinal.length() - 3) + "first";
    if (cardinal.stringHasSuffix("two"))
        return cardinal.substring(0, cardinal.length() - 3) + "second";
    if (cardinal.stringHasSuffix("three"))
        return cardinal.substring(0, cardinal.length() - 3) + "ird";
    if (cardinal.stringHasSuffix("five"))
        return cardinal.substring(0, cardinal.length() - 2) + "fth";
    if (cardinal.stringHasSuffix("eight"))
        return cardinal.append("h");
    if (cardinal.stringHasSuffix("nine"))
        return cardinal.substring(0, cardinal.length() - 1) + "th";
    if (cardinal.stringHasSuffix("twelve"))
        return cardinal.substring(0, cardinal.length() - 2) + "fth";
    return cardinal.append("th");
}
string to_ordinal(string s) {
    buffer b;
    b.append(s);
    return b.to_ordinal();
}

string int_to_position(int v) {
    if (v == 0)
        return "-";
    
    string result = v;
    if (v < 0)
        v = 0 - v;
    
    if (v / 10 % 10 == 1)
        return result + "th";
    
    switch (v % 10) {
        case 1:
            return result + "st";
        case 2:
            return result + "nd";
        case 3:
            return result + "rd";
    }
    return result + "th";
}

print("Supports negatives and metric prefix symbols (k = *1000, m or M = *1 000 000 ...)", "green");
print("");
print("cardinal (default): one, two, three...", "green");
print("ordinal: first, second, third...", "green");
print("position: 1st, 2nd, 3rd...", "green");
print("(only the first letter matters, really)", "green");
print("");
print("Set/tweak the separators and the notation in the start of the script.", "green");
void main(string number, string mode) {
    print("");
    mode = mode.to_lower_case();
    
    switch {
        default:
        case mode.stringHasPrefix("c"):
            print(number + " as cardinal: " + number.to_cardinal());
            break;
        case mode.stringHasPrefix("o"):
            print(number + " as ordinal: " + number.to_ordinal());
            break;
        case mode.stringHasPrefix("p"):
            print(number + " as position: " + number.to_int().int_to_position());
            break;
    }
}
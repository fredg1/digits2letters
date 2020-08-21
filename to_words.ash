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
string tens_to_cardinal(int value, boolean is_final_digits_of_larger_number) { /* from "zero" to "ninety-nine" (no negatives here)*/
    if (__uniwords_to_cardinal_map.count() == 0)
        __uniwords_to_cardinal_map = split_string("zero,one,two,three,four,five,six,seven,eight,nine,ten,eleven,twelve,thirteen,fourteen,fifteen,sixteen,seventeen,eighteen,nineteen", ",");
    
    string result;
    if (is_final_digits_of_larger_number)
        result = "and ";
    
    int v = value % 100;
    
    if (v < 20)
        return result + __uniwords_to_cardinal_map[v];
    
    if (__tens_to_cardinal_map.count() == 0)
        __tens_to_cardinal_map = {2:"twenty", 3:"thirty", 4:"forty", 5:"fifty", 6:"sixty", 7:"seventy", 8:"eighty", 9:"ninety"};
    
    int tens = v / 10;
    result += __tens_to_cardinal_map[tens];
    
    int digit = v % 10;
    if (digit == 0)
        return result;
    return result + "-" + __uniwords_to_cardinal_map[digit];
}
string tens_to_cardinal(int value) {
    return tens_to_cardinal(value, false);
}

string hundreds_to_cardinal(int value, boolean is_final_digits_of_larger_number) { /* from "zero" to "nine hundred ninety-nine" (no negatives here)*/
    int v = value % 1000;
    
    int hundreds = v / 100;
    if (hundreds == 0)
        return tens_to_cardinal(v, is_final_digits_of_larger_number); /* five million "and three" */
    
    string result = tens_to_cardinal(hundreds) + " hundred";
    
    int rest = v % 100;
    if (rest < 0)
        return "<error>";
    if (rest == 0)
        return result;
    return result + " and " + tens_to_cardinal(rest);
}
string hundreds_to_cardinal(int value) {
    return hundreds_to_cardinal(value, false);
}

static string [int] __short_scale_thousands_to_cardinal_map;
string int_to_cardinal(int v, int magnitude_offset) { /*from minus 1 octillion to 1 octillion (exclusive)... but max integer is 2 147 483 647... NEXT STEP: take large strings, and send them this way a billion (-1) at a time. Erase spaces, too.*/
    string result;
    if (v < 0) {
        v = 0 - v;
        result += "minus";
    }
    
    if (__short_scale_thousands_to_cardinal_map.count() == 0)
        __short_scale_thousands_to_cardinal_map = {0:"",3:" thousand",6:" million",9:" billion",12:" trillion",15:" quadrillion",18:" quintillion",21:" sextillion",24:" septillion",27:" octillion",30:" nonillion",33:" decillion",36:" undecillion",39:" duodecillion",42:" tredecillion",45:" quattuordecillion",48:" quindecillion",51:" sexdecillion",54:" septendecillion",57:" octodecillion",60:" novemdecillion",63:" vigintillion",66:" unvigintillion",69:" duovigintillion",72:" tresvigintillion",75:" quattuorvigintillion",78:" quinvigintillion",81:" sesvigintillion",84:" septemvigintillion",87:" octovigintillion",90:" novemvigintillion",93:" trigintillion",96:" untrigintillion",99:" duotrigintillion",102:" trestrigintillion",105:" quattuortrigintillion",108:" quintrigintillion",111:" sestrigintillion",114:" septentrigintillion",117:" octotrigintillion",120:" noventrigintillion",123:" quadragintillion",153:" quinquagintillion",183:" sexagintillion",213:" septuagintillion",243:" octogintillion",273:" nonagintillion",303:" centillion",306:" uncentillion",333:" decicentillion",336:" undecicentillion",363:" viginticentillion",366:" unviginticentillion",393:" trigintacentillion",423:" quadragintacentillion",453:" quinquagintacentillion",483:" sexagintacentillion",513:" septuagintacentillion",543:" octogintacentillion",573:" nonagintacentillion",603:" ducentillion",903:" trecentillion",1203:" quadringentillion",1503:" quingentillion",1803:" sescentillion",2103:" septingentillion",2403:" octingentillion",2703:" nongentillion",3003:" millinillion"};
    //https://en.wikipedia.org/wiki/Names_of_large_numbers, make a function generating the names?
    
    int magnitude = v.length() - 1;
    int order_of_magnitude = magnitude - magnitude % 3;
    int rest = v;
    boolean start = true;
    
    while (order_of_magnitude >= 0) {
        int current_magnitude = 10**order_of_magnitude;
        
        int v_in_current_magnitude = rest / current_magnitude;
        
        if (v_in_current_magnitude > 0)
            result += " " + hundreds_to_cardinal(v_in_current_magnitude, !start) + __short_scale_thousands_to_cardinal_map[order_of_magnitude + magnitude_offset];

        order_of_magnitude -= 3;
        start = false;
    }
    return result;
}
string int_to_cardinal(int v) {
    return int_to_cardinal(v, 0);
}
string int_to_wordy(int v) { /*one of the usable functions*/
    return int_to_cardinal(v, 0);
}

string int_to_position(int v) { /*one of the usable functions*/
    if (v == 0)
        return "-";
    
    string result = v;
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

string int_to_ordinal(int v) {
    string cardinal = int_to_cardinal(v);
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
        return cardinal + "h";
    if (cardinal.stringHasSuffix("nine"))
        return cardinal.substring(0, cardinal.length() - 1) + "th";
    if (cardinal.stringHasSuffix("twelve"))
        return cardinal.substring(0, cardinal.length() - 2) + "fth";
    return cardinal + "th";
}
string int_to_position_wordy(int v) { /*one of the usable functions*/
    return int_to_ordinal(v);
}

buffer buffer_to_cardinal(buffer raw) { /*Only a very large number at this point. Maybe a - at the start*/
    buffer result;
    if (raw.stringHasPrefix("-"))
        result.append("minus ");

    buffer cleaned;
    cleaned.append(create_matcher("[^0-9]", raw).replace_all("")); //remove anything other than numbers.

    //we now have our (potentially) very long number (stored as string). Only digits to see here
    //send them in groups of 9 digits max
    int extra_groups = ceil(cleaned.length() / 9.0) - 1;

    int start = 0;
    int end = cleaned.length() % 9;
    for i from extra_groups downto 0 {
        int current_magnitude =  i * 9;

        int current_number = cleaned.substring(start, end).to_int();

        if (current_number > 0)
            result.append(current_number.int_to_cardinal(current_magnitude) + " ");

        //result.append(current_number + " x 10^" + current_magnitude);
        //if (i > 0)  result.append(" + ");

        //end:
        start = end;
        end += 9;
    }
    return result;
    //could have a letter at the end? Negative? Many separated by ,s +s -s *s..? Not focussing on that for the moment
}

buffer string_to_cardinal(string s) {
    buffer b;
    b.append(s);
    return b.buffer_to_cardinal();
}

void main(string input) {
    print("started with: " + input);
    print(input.string_to_cardinal());
}
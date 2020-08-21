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
string tens_to_cardinal(int value)
    return tens_to_cardinal(value, false);

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
string hundreds_to_cardinal(int value)
    return hundreds_to_cardinal(value, false);

static string [int] __short_scale_thousands_to_cardinal_map;
string int_to_cardinal(int v) { /*from minus 1 octillion to 1 octillion (exclusive)... but max integer is 2 147 483 647... NEXT STEP: take large strings, and send them this way a billion (-1) at a time. Erase spaces, too. Split_string periods?*/
    string result;
    if (v < 0) {
        v = 0 - v;
        result += "minus";
    }
    
    if (__short_scale_thousands_to_cardinal_map.count() == 0)
        __short_scale_thousands_to_cardinal_map = {0:"",3:" thousand",6:" million",9:" billion",12:" trillion",15:" quadrillion",18:" quintillion",21:" sextillion",24:" septillion"};
    
    int magnitude = v.length() - 1;
    int order_of_magnitude = magnitude - magnitude % 3;
    int rest = v;
    boolean start = true;
    
    while (order_of_magnitude >= 0) {
        int current_magnitude = 10**order_of_magnitude;
        
        int v_in_current_magnitude = rest / current_magnitude;
        
        if (v_in_current_magnitude > 0)
            result += " " + hundreds_to_cardinal(v_in_current_magnitude, !start) + __short_scale_thousands_to_cardinal_map[order_of_magnitude];

        order_of_magnitude -= 3;
        start = false;
    }
    return result;
}
string int_to_wordy(int v) /*one of the usable functions*/
    return int_to_cardinal(v);

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
string int_to_position_wordy(int v) /*one of the usable functions*/
    return int_to_ordinal(v);
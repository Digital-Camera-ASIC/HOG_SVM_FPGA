
# Import the binascii module
import binascii


# 32 bit fixed point to decimal converter
# s: string represents for 32-bit hex
def hex_to_dec(s_hex: str) -> float:
    if len(s_hex) % 2:
        s_hex = "0" + s_hex
    if s_hex == "80000000":
        return 0
    is_negative = 0
    # Convert the hexadecimal string to binary using the binascii.unhexlify() function
    s = bin(int.from_bytes(binascii.unhexlify(s_hex), byteorder='big'))[2:]
    while len(s) < 32:
        s = "0" + s
    if s[0] == "1":
        is_negative = 1
        s_temp = ""
        for i in range(32):
            if s[i] == "1":
                s_temp = s_temp + "0"
            else:
                s_temp = s_temp + "1"
        s = s_temp
        temp = int(s, 2)
        temp = temp + 1
        s = bin(temp)
        s = s[2:]

    while len(s) < 32:
        s = "0" + s
    i = 9
    res = 0

    for x in s:
        if x == "1":
            res = res + 2 ** i
        i = i - 1

    if is_negative:
        res = -res
    return res


# decimal to 32 bit fixed point converter
def dec_to_hex(x: float) -> str:
    is_negative = 0
    if x < 0:
        x = -x
        x = x - 2 ** -22
        is_negative = 1
    
    integer_part = int(x)
    fractional_part = x - integer_part
    s = bin(integer_part)[2:]
    for i in range(22):
        res = fractional_part * 2
        if res >= 1:
            s = s + "1"
            res = res - 1
        else:
            s = s + "0"
        fractional_part = res

    while len(s) < 32:
        s = "0" + s
    
    if is_negative:
        s_temp = ""
        for x in s:
            if x == "1":
                s_temp = s_temp + "0"
            else:
                s_temp = s_temp + "1"
        s = s_temp
    s = hex(int(s, 2))[2:]
    return s

# for testing
print(hex_to_dec(dec_to_hex(-5.25)))

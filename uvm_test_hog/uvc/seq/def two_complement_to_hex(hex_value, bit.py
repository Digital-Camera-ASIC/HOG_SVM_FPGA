def two_complement_to_hex(hex_value, bit_width):
    # Chuyển đổi giá trị hexadecimal sang số nguyên
    int_value = int(hex_value, 16)
    
    # Kiểm tra nếu số là âm trong hệ thống bù hai
    if int_value & (1 << (bit_width - 1)):
        # Tính giá trị bù hai
        int_value = ~int_value + 1
        # Chuyển đổi số nguyên sang giá trị hexadecimal
        hex_value = hex(int_value & ((1 << bit_width) - 1))[2:].upper()
    else:
        # Nếu không phải số âm, giữ nguyên giá trị hexadecimal
        hex_value = hex_value.upper()
    
    return hex_value.zfill(bit_width // 4)

# Ví dụ sử dụng
hex_value = "F1000000"  # Số hexadecimal đầu vào
bit_width = 32          # Độ rộng bit

# Tính giá trị bù hai và chuyển đổi sang chuỗi hexadecimal
two_complement_hex = two_complement_to_hex(hex_value, bit_width)

# Hiển thị kết quả
print(f"Hex value: {hex_value}")
print(f"Two's complement value (hex): {two_complement_hex}")






hex_string = "b65138fadb08b50c9aaf906c071890e1cf4be26c1a869d4f84b4aa38c181e69a9d291f84"

# Kích thước của mỗi phần
chunk_size = 8

# Chia chuỗi thành các phần có kích thước 8 ký tự
chunks = [hex_string[i:i + chunk_size] for i in range(0, len(hex_string), chunk_size)]

# Kiểm tra số lượng phần
if len(chunks) != 9:
    print("Số lượng phần không đúng, kiểm tra lại chuỗi đầu vào hoặc kích thước phần.")
else:
    # Hiển thị các phần đã chia
    for i, chunk in enumerate(chunks):
        print(f"Chunk {i + 1}: {chunk}")

        two_complement_hex = two_complement_to_hex(chunk, bit_width)
        # print(f"Hex value: {hex_value}")
        print(f"Two's complement value (hex): {two_complement_hex}")
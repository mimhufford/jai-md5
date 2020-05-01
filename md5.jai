/*
    A simple MD5 utility
    Author: Mim Hufford
    Date:   01 May 2020
*/

md5 :: (input: string) -> string #must {

    // pad size to nearest 512 bits
    pad  := 512 - input.count % 512;
    size := input.count + pad;

    // create a buffer we can work with
    data : []u8 = ---;
    data.count = size;
    data.data  = alloc(size);

    // zero everything out
    memset(data.data, 0, size);

    // copy in the original input
    for 0..input.count-1 data[it] = input[it];

    // write a 1 bit right after the original input
    data[input.count] = 0b1000_0000;

    // write original size into last 64 bits
    data[size-8] = cast,trunc(u8) input.count >> 7 & 0xff;
    data[size-7] = cast,trunc(u8) input.count >> 6 & 0xff;
    data[size-6] = cast,trunc(u8) input.count >> 5 & 0xff;
    data[size-5] = cast,trunc(u8) input.count >> 4 & 0xff;
    data[size-4] = cast,trunc(u8) input.count >> 3 & 0xff;
    data[size-3] = cast,trunc(u8) input.count >> 2 & 0xff;
    data[size-2] = cast,trunc(u8) input.count >> 1 & 0xff;
    data[size-1] = cast,trunc(u8) input.count >> 0 & 0xff;

    // set up digest parts
    a0 : u32 = 0x67452301;
    b0 : u32 = 0xefcdab89;
    c0 : u32 = 0x98badcfe;
    d0 : u32 = 0x10325476;

    // for each 512 bit chunk
    for chunk: 0..cast(u32)(size/512)-1 {
        A, B, C, D := a0, b0, c0, d0;
        
        for 0..cast(u32)63 {
            F, g : u32;

            if it < 16 {
                F = (B & C) | ((~B) & D);
                g = it;
            } else if it < 32 {
                F = (D & B) | ((~D) & C);
                g := (it*5 + 1) % 16;
            } else if it < 48 {
                F = B ^ C ^ D;
                g := (it*3 + 5) % 16;
            } else {
                F = C ^ (B | (~D));
                g := (it*3) % 16;
            }

            // @SPEED: should do this outside the loop
            // grab the relevant 32 bits from the original input
            offset := chunk*512 + g*4;
            word : u32;
            word += data[offset+0] << 3;
            word += data[offset+1] << 2;
            word += data[offset+2] << 1;
            word += data[offset+3] << 0;

            // apply the hash to this section of data
            F += A + K[it] + word;
            A = D;
            D = C;
            C = B;
            B += left_rotate(F, s[it]); // @TODO: remove after <<<
        }

        // update the digest with this chunk's data
        a0 += A;
        b0 += B;
        c0 += C;
        d0 += D;
    }

    sb : String_Builder;
    append(*sb, tprint("%", formatInt(a0, base=16, minimum_digits=8)));
    append(*sb, tprint("%", formatInt(b0, base=16, minimum_digits=8)));
    append(*sb, tprint("%", formatInt(c0, base=16, minimum_digits=8)));
    append(*sb, tprint("%", formatInt(d0, base=16, minimum_digits=8)));

    return builder_to_string(*sb);
}

main :: () {
    input    := "The quick brown fox jumps over the lazy dog";
    result   := md5(input);
    expected := "9e107d9d372bb6826bd81d3542a419d6";
    print("Input:    %\nResult:   %\nExpected: %", input, result, expected);
}





#scope_file

#import "Basic";

// @TODO: remove once <<< is released
left_rotate :: (num: u32, amount: u32) -> u32 #must {
    return (num << amount) | (num >> (32 - amount)); 
}

s :: {:u32:
    7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
    5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
    4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
    6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,
};

K :: {:u32:
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
    0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
    0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
    0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
    0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
    0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
    0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
    0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
    0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391,
};
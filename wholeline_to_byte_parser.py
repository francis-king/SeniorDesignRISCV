#read a file called machinecode.txt and parse each line into 4 lines, each line is a byte
import sys
import os
import re
import struct
# Read the file

file_path = "e:/senior_design/machinecode.txt"
with open(file_path, "r") as file:
    lines = file.readlines()
#example of one line: 00112233, it need to be converted to 4 lines, each line is a byte, such that the new file have line 0 = 33, line 1 = 22, line 2 = 11, line 3 = 00
    # Clear the file before writing
    open("test.sim", "w").close()
    # Parse each line

    for line in lines:
        # Remove leading and trailing whitespace
        line = line.strip()

        # Split the line into two-character chunks
        chunks = [line[i:i+2] for i in range(0, len(line), 2)]

        # Reverse the order of the chunks
        chunks.reverse()

        # Write each byte on a new line in a file called test.sim
        # Clear the file before writing
        

        # Write each byte on a new line in the file
        with open("test.sim", "a") as file:
            for byte in chunks:
                file.write(byte + "\n")

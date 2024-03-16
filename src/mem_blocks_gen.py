def process_file(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()

    with open(output_file, 'w') as f:
        finstr = ""
        for i in range(0, len(lines), 8):
            chunk = lines[i:i+8]
            if len(chunk) < 8:
                break  # If less than 8 lines left, stop processing
            concatenated_line = ''.join(reversed([line.strip() for line in chunk]))
            finstr = "".join([finstr,concatenated_line])
        output_string = '\n'.join(finstr[i:i+64] for i in range(0, len(finstr), 64))
        f.write(output_string)

if __name__ == "__main__":
    input_file = "otter_memory.mem"  
    output_file = "otter_memory_blocks.mem"  
    process_file(input_file, output_file)
    print("Mem file processed successfully.")

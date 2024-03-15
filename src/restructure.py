def process_file(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()

    with open(output_file, 'w') as f:
        for i in range(0, len(lines), 8):
            chunk = lines[i:i+8]
            if len(chunk) < 8:
                break  # If less than 8 lines left, stop processing
            concatenated_line = ''.join(reversed([line.strip() for line in chunk]))
            f.write(concatenated_line)

if __name__ == "__main__":
    input_file = "otter_memory.mem"  # Change this to your input file name
    output_file = "otter_memory_temp.mem"  # Change this to your output file name
    process_file(input_file, output_file)
    print("File processed successfully.")

def insert_newlines(input_file, output_file):
    with open(input_file, 'r') as f:
        input_string = f.read()

    output_string = '\n'.join(input_string[i:i+64] for i in range(0, len(input_string), 64))

    with open(output_file, 'w') as f:
        f.write(output_string)

if __name__ == "__main__":
    input_file = "otter_memory_temp.mem"  # Change this to your input file name
    output_file = "otter_memory_blocks.mem"  # Change this to your output file name
    insert_newlines(input_file, output_file)
    print("New lines inserted successfully.")


FILENAME = 'demo1.fti'

with open(FILENAME, 'r') as file:
    lines = file.readlines()
    for line in lines:
        i = line.strip()
        print("  ", end='')
        if i == 'ESTABLISH':
            print("(chord E3 E4 E5) ; " + i)
        elif i == 'DEF_FUNC':
            print("(chord F1 F2 F3) ; " + i)
        elif i == 'FUNC_RETURNS':
            print("(chord F2 F3 F4) ; " + i)
        elif i == 'PRINT_INT':
            print("(chord A1 A2 A8) ; " + i)
        elif i == 'PRINT_CHAR':
            print("(chord A1 A2 A9) ; " + i)
        elif i == 'ADD':
            print("(chord A1 A2 A3) ; " + i)
        elif i == 'NAME' or i == 'ARGS' or i == '':
            continue
        else:
            print("(chord " + i + ")")
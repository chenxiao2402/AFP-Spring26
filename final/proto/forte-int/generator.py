c1 = 1
c2 = 1
c3 = 1
c4 = 1
c5 = 1

c5 = c5 + c1 + c2 + c3
c1 = c5 * c1
c2 = c2 + c3
c3 = c5 * c1 * c2
c6 = c3

d5 = c3 - c4
d1 = 0
d1 = d1 - c4

f5 = c1 * c2
f5 = f5 + c2

f1 = c1 + c2
f2 = f1 + c4
f1 = f1 * f2

while d5 > d1:
    e6 = d5 * c4
    g4 = 0
    while e6 > g4:
        print(chr(c3), end="")
        e6 = e6 - c4
    g5 = 0
    g6 = c3 - d5
    while g5 < g6:
        a1 = g5 & d5
        if a1 == g4:
            print(chr(f1) + chr(c3), end="")
        else:
            print(chr(c3) + chr(c6), end="")
        g5 = g5 + c4
    print(chr(f5), end="")
    d5 = d5 - c4
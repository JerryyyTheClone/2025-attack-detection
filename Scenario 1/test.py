def KSA(key):
    s = list(range(0,256))
    j = 0
    for i in range(256):
        j = (j+s[i]+key[i%len(key)])% 256
        s[i],s[j] = s[j],s[i]
    return s
    
    
def PRGA(S):
    i,j = 0,0
    while True:
        i = (i + 1) % 256
        j = (j + S[i]) % 256
        S[i], S[j] = S[j], S[i]
        K = S[(S[i] + S[j]) % 256]
        yield K

keygenerator = PRGA(KSA(list("jerryyytheevilduck".encode())))
a =  { ".txt", ".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx", ".odt", ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".mp3", ".wav", ".flac", ".mp4", ".avi", ".mkv", ".mov", ".zip", ".rar", ".7z", ".pdf" }

print(keygenerator)


# for c in range(10):
#     print(next(keygenerator),end=' ') #bytes decimal, format to hex for comparison with test vectors. 

# for i in a: 
    
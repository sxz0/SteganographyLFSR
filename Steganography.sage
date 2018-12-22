def generarClave(input,poly):
    actual=list(input)
    key=[]
        
    while(True):
        #Se realiza el XOR de las posiciones actuales de la palabra inicial en funcion del polinomio
        #Para ello hacemos la suma de los bits de la secuencia de entrada que coinciden con el polinomio       
        acum=0
        for p in poly:
            acum=acum+actual[p-1]
        
        #insertamos el nuevo bit en la secuencia (si la sumatoria de bits es par, el XOR da 0, en caso contrario es 1)
        if(acum%2==0):
            actual.insert(0,0)
        else:
            actual.insert(0,1)
            
        #extraemos de la secuencia el primer elemento (mas a la derecha) y añadimos el nuevo bit a la clave
        elem=actual.pop()
        key.insert(0,elem)
        
        #si la secuencia actual es igual a la palabra inicial, se detiene la generacion de la clave
        if(actual==input):
            break
    
    #print key
    return key

#funcion que cifra haciendo un XOR entre las dos listas que recibe
def cifrar(listaBinarios,listaClave):
    listaCifrada=[]
    
    #Se hace XOR de cada bit en orden con uno de la clave
    for i in range(0,len(listaBinarios)):
        listaCifrada.append((listaBinarios[i]+listaClave[i])%2)
    return listaCifrada    

def LFSR(textoInicial,input,poly):


    lista=[ord(c) for c in textoInicial]
    numero=ZZ(lista,256)
    listaBinarios=numero.digits(2)
    listaClave=generarClave(input,poly)
    if(len(listaClave)<len(listaBinarios)):
        return ''

    listaCifrada=cifrar(listaBinarios,listaClave)

    numeroCifrado=ZZ(listaCifrada,2)
    textoCifrado=''.join([chr(c) for c in numeroCifrado.digits(256)])

    return textoCifrado 

def desLFSR(textoCifrado,input,poly):

    listaClave=generarClave(input,poly)
    listaCif=[ord(c) for c in textoCifrado]
    numeroCif=ZZ(listaCif,256)
    listaBinariosCif=numeroCif.digits(2)
    listaDescifrada=cifrar(listaBinariosCif,listaClave)
    numeroDescifrado=ZZ(listaDescifrada,2)
    textoDescifrado=''.join([chr(c) for c in numeroDescifrado.digits(256)])
    return textoDescifrado

def hideText(archivo, texto,polyInput,poly):
    from PIL import Image, ImageFilter
    im = Image.open( archivo )

    textoLFSR=LFSR(texto,polyInput,poly)
    mensajeBinario=[ord(i) for i in textoLFSR]
    binarios=ZZ(mensajeBinario,256).digits(2)

    bytesBitCero=[chr(ord(t)&0xfe) for t in im.tobytes()]

    if(len(bytesBitCero)<len(binarios)):
        print "El texto es demasiado largo, usa una imagen más grande o un texto mas corto"
    else:
        for i in range (0,len(binarios)):
            if(binarios[i]==1):
                bytesBitCero[i]=chr(ord(bytesBitCero[i])|0x01)

    bb = ''.join(bytesBitCero)
   
    im2 = Image.frombytes(im.mode,im.size,bb)
    im2.save(archivo+".out.bmp","BMP")

def recoverText(archivo,polyInput,poly):
    from PIL import Image, ImageFilter
    im = Image.open(archivo)

    bits=[]
    bytesNum=[ord(t) for t in im.tobytes()]
    for n in bytesNum:
        if(n%2==1):
            bits.append(1)
        else:
            bits.append(0)
    
    num=ZZ(bits,2)
    textoCifrado=''.join([chr(c) for c in num.digits(256)])
    texto=desLFSR(textoCifrado,polyInput,poly)
    
    return texto



############USAGE EXAMPLE#############################

#Text to hidde
texto="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nibh diam, rutrum vitae arcu a, pellentesque condimentum sapien. Aliquam consectetur, erat eget porttitor suscipit, erat nisl imperdiet ex, nec scelerisque ex diam vitae nisl. Fusce scelerisque quam eget enim lobortis, et tempus odio posuere. Phasellus facilisis mauris non ligula rhoncus, in tempor ligula bibendum. Nullam ac orci eu turpis porttitor rhoncus in eget orci. Nam pretium neque ac eros pretium dictum. Aliquam sit amet finibus massa. Duis purus velit, condimentum eget aliquam ac, sodales rhoncus tortor. Ut varius non eros vel varius. Donec sit amet sodales ipsum. Vestibulum et risus eget massa bibendum tincidunt vel sit amet lectus. Aenean ullamcorper nunc in urna euismod, eu mattis lorem sagittis. Nam non tristique sem, egestas consectetur libero. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Phasellus congue mattis elit. Donec egestas auctor nulla quis convallis."

##LFSR input, composed by an array with the polynomial exponents and one array with the binary input to the poly
input = [1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1]
poly = [16,15,13,4]

##Hide the text, Params: Route of the BMP image used to hide the information, should be larger than the text-to-hide size
hideText('/home/pedromi/mp.bmp',texto,input,poly)

##Recover the hidden text in an BMP imagen. Params: Route to the image to recover, and LFSR inputs
info=recoverText('/home/pedromi/output.bmp',input,poly)
print info

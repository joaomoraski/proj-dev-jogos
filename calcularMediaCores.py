import sys

def main():
    while True:
        if len(sys.argv) < 2:
            nCores = int(input("Número de cores a serem calculadas: "))
            if nCores == 0:
                return
            montarListaCores(nCores)
        else:
            nCores = int(sys.argv[1])
            montarListaCores(nCores)
            break

def montarListaCores(nCores):
    cores = []
    print("R = Red | G = Green | B = Blue | r,g,b")
    for i in range(nCores):
        r = int(input(f"Insira o valor de R da cor {i + 1}: "))
        g = int(input(f"Insira o valor de G da cor {i + 1}: "))
        b = int(input(f"Insira o valor de B da cor {i + 1}: "))
        cores.append((r, g, b))
    calcularInterpolacaoRGB(cores)

def calcularInterpolacaoRGB(cores):
    nCores = len(cores)
    rf = sum([r for r, _, _ in cores]) // nCores
    gf = sum([g for _, g, _ in cores]) // nCores
    bf = sum([b for _, _, b in cores]) // nCores
    print(f"Interpolação: {rf},{gf},{bf}")

main()

// Módulo 05 — Arrays
// Prática: criar, percorrer, modificar arrays, usar Arrays.* e matrizes.
//
// Rode com: java Main.java   (JDK 11+)

import java.util.Arrays;

public class Main {

    // Exercício 1: Criar e imprimir um array
    // Mostra as 3 formas de declarar e como imprimir o conteúdo (Arrays.toString).
    static void exercicio1() {
        // Forma 1: tamanho definido, valores zerados
        int[] zeros = new int[5];
        System.out.println("zeros: " + Arrays.toString(zeros)); // [0, 0, 0, 0, 0]

        // Forma 2: literal com valores
        int[] nums = {10, 20, 30, 40, 50};
        System.out.println("nums:  " + Arrays.toString(nums));

        // Forma 3: declarar e atribuir depois (precisa do `new int[]`)
        int[] outros;
        outros = new int[]{1, 2, 3};
        System.out.println("outros: " + Arrays.toString(outros));

        // length: tamanho do array (campo, sem parênteses!)
        System.out.println("nums.length = " + nums.length);
    }

    // Exercício 2: Somar todos os elementos
    // Padrão clássico: acumulador + loop.
    static void exercicio2() {
        int[] nums = {10, 20, 30, 40, 50};

        int soma = 0;
        for (int n : nums) { // for-each: só precisamos do valor, não do índice
            soma += n;
        }

        System.out.println("Soma de " + Arrays.toString(nums) + " = " + soma);
    }

    // Exercício 3: Encontrar o maior valor
    // Começa assumindo que o primeiro é o maior e compara com os demais.
    static void exercicio3() {
        int[] nums = {30, 70, 10, 90, 50, 20};

        int maior = nums[0]; // assume o primeiro como ponto de partida
        for (int i = 1; i < nums.length; i++) {
            if (nums[i] > maior) {
                maior = nums[i];
            }
        }

        System.out.println("Array: " + Arrays.toString(nums));
        System.out.println("Maior: " + maior);
    }

    // Exercício 4: Inverter um array (sem usar Arrays.*)
    // Técnica de "dois ponteiros": troca extremidades caminhando pro meio.
    static void exercicio4() {
        int[] nums = {1, 2, 3, 4, 5};
        System.out.println("Antes:  " + Arrays.toString(nums));

        int esq = 0;
        int dir = nums.length - 1;
        while (esq < dir) {
            int temp = nums[esq];
            nums[esq] = nums[dir];
            nums[dir] = temp;
            esq++;
            dir--;
        }

        System.out.println("Depois: " + Arrays.toString(nums));
    }

    // Exercício 5: Copiar com Arrays.copyOf
    // Mostra que a cópia é INDEPENDENTE do original.
    static void exercicio5() {
        int[] original = {1, 2, 3};
        int[] copia = Arrays.copyOf(original, original.length);

        copia[0] = 999; // modifica só a cópia

        System.out.println("Original: " + Arrays.toString(original)); // [1, 2, 3]
        System.out.println("Cópia:    " + Arrays.toString(copia));    // [999, 2, 3]

        // copyOf também pode aumentar/diminuir o tamanho
        int[] maior = Arrays.copyOf(original, 5);
        System.out.println("Maior:    " + Arrays.toString(maior)); // [1, 2, 3, 0, 0]
    }

    // Exercício 6: Ordenar com Arrays.sort
    // Cuidado: sort MODIFICA o array original (é referência).
    static void exercicio6() {
        int[] nums = {50, 10, 40, 20, 30};
        System.out.println("Antes:  " + Arrays.toString(nums));

        Arrays.sort(nums); // ordem crescente
        System.out.println("Depois: " + Arrays.toString(nums));

        // Pra preservar o original, copie antes:
        int[] outro = {7, 3, 9, 1};
        int[] outroOrdenado = Arrays.copyOf(outro, outro.length);
        Arrays.sort(outroOrdenado);
        System.out.println("Original preservado: " + Arrays.toString(outro));
        System.out.println("Cópia ordenada:      " + Arrays.toString(outroOrdenado));
    }

    // Exercício 7: Demonstrar compartilhamento de referência
    // Passar um array pra um método NÃO faz cópia — o método mexe no original.
    static void exercicio7() {
        int[] nums = {1, 2, 3, 4, 5};
        System.out.println("Antes de dobrar: " + Arrays.toString(nums));

        dobrarTudo(nums); // passa a referência, não uma cópia!

        System.out.println("Depois de dobrar: " + Arrays.toString(nums));
        // Veja: o array foi modificado pelo método. Isso é referência em ação.
    }

    // método auxiliar do exercício 7
    static void dobrarTudo(int[] arr) {
        for (int i = 0; i < arr.length; i++) {
            arr[i] *= 2;
        }
    }

    // Exercício 8: Matriz 3x3
    // Arrays bidimensionais — útil pra tabelas, grids, tabuleiros.
    static void exercicio8() {
        int[][] matriz = {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        };

        // Acessando uma célula específica
        System.out.println("matriz[1][2] = " + matriz[1][2]); // 6

        // Imprimindo a matriz formatada
        System.out.println("Matriz:");
        for (int i = 0; i < matriz.length; i++) {           // linhas
            for (int j = 0; j < matriz[i].length; j++) {    // colunas
                System.out.print(matriz[i][j] + " ");
            }
            System.out.println(); // quebra de linha ao fim de cada linha
        }

        // Forma rápida pra debugar matriz inteira:
        System.out.println("deepToString: " + Arrays.deepToString(matriz));

        // Somando a diagonal principal (índices iguais: [0][0], [1][1], [2][2])
        int diagonal = 0;
        for (int i = 0; i < matriz.length; i++) {
            diagonal += matriz[i][i];
        }
        System.out.println("Soma da diagonal: " + diagonal); // 1 + 5 + 9 = 15
    }

    public static void main(String[] args) {
        System.out.println("=== Exercício 1: Criar e imprimir ===");
        exercicio1();

        System.out.println("\n=== Exercício 2: Somar ===");
        exercicio2();

        System.out.println("\n=== Exercício 3: Maior valor ===");
        exercicio3();

        System.out.println("\n=== Exercício 4: Inverter ===");
        exercicio4();

        System.out.println("\n=== Exercício 5: Copiar com copyOf ===");
        exercicio5();

        System.out.println("\n=== Exercício 6: Ordenar com sort ===");
        exercicio6();

        System.out.println("\n=== Exercício 7: Compartilhamento de referência ===");
        exercicio7();

        System.out.println("\n=== Exercício 8: Matriz 3x3 ===");
        exercicio8();
    }
}

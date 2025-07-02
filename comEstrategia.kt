// Este arquivo é uma adaptação do código referência em Python para a linguagem Kotlin.
// Bibliotecas semelhantes foram utilizadas para manter a lógica da referência.
//
// A função Syncronized da biblioteca Thread foi utilizada para atuar como monitor, permitindo que apenas uma thread acesse a área crítica.

package estrategia
import kotlin.concurrent.thread
import kotlin.random.Random
import kotlin.system.measureTimeMillis

val filaDePedidos = mutableListOf<Int>()
val pedidosProntos = mutableListOf<Int>()
val lock = Object()  // objeto usado como monitor
val numCozinheiros = 5
val numPedidos = 100

fun cozinheiro(num: Int) {
    println("Cozinheiro $num pronto para receber pedidos!")

    while (filaDePedidos.isNotEmpty()) {
        val pedido: Int

        // área crítica (remoção de pedidos)
        synchronized(lock) {    // atuação do monitor
            if (filaDePedidos.isEmpty()) return  // sair se não há mais pedidos
            pedido = filaDePedidos.removeAt(0)
        }

        println("Cozinheiro $num preparando pedido=$pedido")
        Thread.sleep(Random.nextLong(100, 500))
        println("Cozinheiro $num terminou pedido=$pedido")

        // área crítica (adição de pedido)
        synchronized(lock) {     // atuação do monitor
            pedidosProntos.add(pedido)
        }
    }
}

fun main() {
    for (i in 0 until numPedidos) {
        filaDePedidos.add(i)
        println("pedido=$i recebido...")
    }

    val tempo = measureTimeMillis {
        val threads = List(numCozinheiros) { c ->
            thread {
                cozinheiro(c)
            }
        }
        threads.forEach { it.join() }
    }

    println("Tempo total: ${tempo}ms")
    println("Pedidos restantes na fila: ${filaDePedidos.size}")
    println("Total prontos: ${pedidosProntos.size}")
}
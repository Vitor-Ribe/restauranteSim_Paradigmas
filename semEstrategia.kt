//
//    Este arquivo é uma adaptação do código referência em Python para a linguagem Kotlin. 
//    Bibliotecas semelhantes foram utilizadas para manter a lógica da referência.
//
package semEstrategia
import kotlin.concurrent.thread
import kotlin.random.Random
import kotlin.system.measureTimeMillis

val filaDePedidos = mutableListOf<Int>()
val pedidosProntos = mutableListOf<Int>()
val numCozinheiros = 5
val numPedidos = 100

fun cozinheiro(num: Int) {
    println("Cozinheiro $num pronto para receber pedidos!")
    while (filaDePedidos.isNotEmpty()) {
        val pedido = filaDePedidos[0]
        println("Cozinheiro $num preparando pedido=$pedido")
        Thread.sleep((Random.nextDouble(100.0, 500.0)).toLong())
        println("Cozinheiro $num terminou pedido=$pedido")
        pedidosProntos.add(pedido)
        filaDePedidos.remove(pedido)
    }
}

fun main() {
    // preencher pedidos
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

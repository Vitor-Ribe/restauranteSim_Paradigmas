# Seminário 2 - Paradigmas de Programação  :computer:
# Problema :dart:

O restaurante **Sim**, que precisa processar muitos pedidos de forma rápida. A ideia é escalar o sistema com **vários cozinheiros (threads)** para preparar os pedidos.
Eles tentaram algo simples: cada cozinheiro retira pedidos de uma fila global e marca como pronto. Mas… algo deu errado.

**problemas de concorrência**:
- Alguns pedidos desaparecem
- Cozinheiros preparam o mesmo pedido duas vezes
- A lista de pedidos prontos vem incompleta ou fora de ordem

---

## Objetivos do Grupo

1. Simular esse cenário em sua linguagem de programação 
2. Reproduzir o problema de concorrência.
3. Discutir por que o erro ocorreu (race condition).
4. Corrigir a implementação com controle de concorrência, ou equivalente da linguagem.

#### Código referência (Python):
```python
import time
import threading
from random import random

fila_de_pedidos = []
pedidos_prontos = []
num_cozinheiros = 5
num_pedidos = 100
cozinheiros = []


def cozinheiro(num_cozinheiro):
    print(f"cozinheiro {num_cozinheiro} pronto para receber pedidos!")
    while len(fila_de_pedidos) != 0:
        pedido = fila_de_pedidos[0]
        print(f"cozinheiro {num_cozinheiro} preparando {pedido=}")
        time.sleep(random())
        print(f"cozinheiro {num_cozinheiro} terminou {pedido=}")
        pedidos_prontos.append(pedido)
        fila_de_pedidos.remove(pedido)

def faz_pedido(pedido):
    fila_de_pedidos.append(pedido)
    print(f"{pedido=} recebido...")

for pedido in range(num_pedidos):
    faz_pedido(pedido)

for c in range(num_cozinheiros):
    t = threading.Thread(target=cozinheiro, args=(c, ))
    t.start()
    cozinheiros.append(t)

inicio = time.time()
for thread in cozinheiros:
    thread.join()
fim = time.time()
print(f"Tempo total: {fim-inicio} segundos", fila_de_pedidos)
```
# Solução adotada :bulb:

Para fins de controle, o código referência foi transcrito para a linguagem escolhida [Kotlin](https://kotlinlang.org/docs/home.html). Esta transcrição utilizou bibliotecas semelhantes de modo a preservar a lógica do código referência.

#### Código transcrito para Kotlin:
[semEstrategia.kt](./semEstrategia.kt)

## Concorrência
Para gerir a concorrência no código foi utilizada a biblioteca `kotlin.concurrent.thread`

Após compilação foram obtidos resultados imprecisos (veja seção Resultados), principalmente devido ao acesso de mais de uma thread a um bloco crítico do sistema, ocasionando race condition.

Para controlar o acesso destas áreas críticas e impedir race condition, foi utilizada a função `syncronized` da biblioteca `thread`. Desta forma, apenas uma thread tem acesso ao conteúdo da área crítica, garatindo que os dados sejam atualizados antes que outras threads os acessem.

#### Código com syncronized:
[comEstrategia.kt](./comEstrategia.kt)

# Resultados 🗒️
Saídas após execução

## Sem estrategia :x:
```bash
pedido=0 recebido...
pedido=1 recebido...
pedido=2 recebido...
pedido=3 recebido...
[...]
Cozinheiro 1 terminou pedido=98
Cozinheiro 3 terminou pedido=98
Cozinheiro 2 terminou pedido=99

Tempo total: 23517ms
Pedidos restantes na fila: 0
Total prontos: 383
```
> **Tempo total:** ≈ 23517ms  :x:  _// tempo alto devido vários cozinheiros trabalharem com o mesmo pedido_

> **Pedidos para atender:** 0     :white_check_mark:  _// Nenhum pedido deixou de ser atendido_

> **Pedidos atendidos:** 383  :x: _// deveria ser 100. Ou seja, mais de um cozinheiro atendeu ao mesmo pedido_

> **Resumo das 10 Execuções:**
- Total: 10
- Aprovadas: 0
- Reprovadas: 10
- Problemas: pedidos duplicados, perda de pedidos, ordem quebrada.

---

## Com estrategia :white_check_mark:
```bash
pedido=0 recebido...
pedido=1 recebido...
pedido=2 recebido...
[...]
Cozinheiro 0 terminou pedido=99
Cozinheiro 4 terminou pedido=97
Cozinheiro 1 terminou pedido=95
Cozinheiro 3 terminou pedido=98

Tempo total: 6243ms
Pedidos restantes na fila: 0
Total prontos: 100
```
> **Tempo total:** ≈ 6243ms  :white_check_mark:  _// tempo menor_

> **Pedidos para atender:** 0    :white_check_mark:  _// Nenhum pedido deixou de ser atendido_

> **Pedidos atendidos:** 100     :white_check_mark:  _// Cada pedido foi atendido por somente um cozinheiro_

> **Resumo das 10 Execuções:**
- Total: 10
- Aprovadas: 10
- Reprovadas: 0
- Resultado consistente e íntegro.

---

## Justificativa da Estratégia

**Por que `synchronized` (monitor):**

| Critério | `synchronized` | Semáforo |
|---------|----------------|----------|
| Simplicidade | ✅ Alta | ❌ Média |
| Robustez contra erros | ✅ Automático | ❌ Propenso a esquecer `release()` |
| Clareza de código | ✅ Muito clara | ❌ Mais verboso |
| Ideal para exclusão mútua simples | ✅ Sim | ✅ Também, mas menos direto |

---

## Scripts de Execução

Para rodar os testes automatizados:

```powershell
# Sem controle de concorrência
.
run_semEstrategia.ps1

# Com controle de concorrência
.
run_comEstrategia.ps1
```

---

## Conclusão :white_check_mark:

A utilização de `synchronized` foi suficiente para:
- Corrigir todos os erros de concorrência;
- Garantir integridade da fila e dos pedidos;
- Melhorar o desempenho médio da aplicação concorrente.

Essa abordagem é apropriada para cenários de **exclusão mútua simples** em aplicações multi-thread.



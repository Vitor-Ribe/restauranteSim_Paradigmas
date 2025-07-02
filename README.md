# Resultados
## Concorrência
Para controlar a concorrência do código foi utilizado a biblioteca thread herdada do Java

## Estratégia
Para controlar o acesso as áreas críticas do código foi utilizado a função `syncronized`

## sem estrategia
```
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
## com estrategia
```
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

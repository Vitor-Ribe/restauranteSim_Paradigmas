# Compila o arquivo semEstrategia.kt
Write-Host "Compilando semEstrategia.kt..."
kotlinc semEstrategia.kt -include-runtime -d semEstrategia.jar

Write-Host "`n--- Executando semEstrategia.kt 10 vezes ---"

$executions = 10
$passCount = 0
$failCount = 0
$results = @() # Array para armazenar os resultados de cada execução

for ($i = 1; $i -le $executions; $i++) {
    Write-Host "`n--- Execução $i de $executions (semEstrategia) ---"
    $output = java -jar semEstrategia.jar | Out-String # Captura a saída do console
    Write-Host $output

    # Analisar a saída
    $totalProntos = ($output | Select-String "Total prontos: (\d+)" | ForEach-Object { $_.Matches[0].Groups[1].Value })
    $pedidosRestantes = ($output | Select-String "Pedidos restantes na fila: (\d+)" | ForEach-Object { $_.Matches[0].Groups[1].Value })
    $tempoTotal = ($output | Select-String "Tempo total: (\d+)ms" | ForEach-Object { $_.Matches[0].Groups[1].Value })

    Write-Host "Análise da Execução ${i}:"
    Write-Host "  Tempo Total: ${tempoTotal}ms"
    Write-Host "  Pedidos Restantes na Fila: $pedidosRestantes"
    Write-Host "  Total Prontos: $totalProntos"

    $currentResult = @{
        Execution = $i
        Time = [int]$tempoTotal
        Remaining = [int]$pedidosRestantes
        Processed = [int]$totalProntos
        Status = "FAIL" # Assume falha até provar o contrário
        Errors = @()
    }

    # Verificações
    if ($pedidosRestantes -eq 0) {
        Write-Host "  ✅ Fila de pedidos vazia."
    } else {
        Write-Host "  ❌ Fila de pedidos NÃO vazia. Restantes: $pedidosRestantes"
        $currentResult.Errors += "Fila não vazia"
    }

    if ($totalProntos -eq 100) {
        Write-Host "  ✅ Todos os 100 pedidos foram processados (sem duplicação ou perda)."
    } elseif ($totalProntos -gt 100) {
        Write-Host "  ⚠️ Atenção: Pedidos duplicados detectados! Total prontos: $totalProntos (esperado: 100)."
        $currentResult.Errors += "Pedidos duplicados"
    } else { # $totalProntos -lt 100
        Write-Host "  ❌ Pedidos perdidos detectados! Total prontos: $totalProntos (esperado: 100)."
        $currentResult.Errors += "Pedidos perdidos"
    }

    if ($currentResult.Errors.Count -eq 0) {
        $currentResult.Status = "PASS"
        $passCount++
    } else {
        $failCount++
    }
    $results += $currentResult
}

Write-Host "`n--- Resumo Final de Todas as ${executions} Execuções (semEstrategia) ---"
Write-Host "Total de Execuções: $executions"
Write-Host "Execuções Aprovadas: $passCount"
Write-Host "Execuções Reprovadas: $failCount"
Write-Host ""

foreach ($result in $results) {
    Write-Host "Execução $($result.Execution): Status = $($result.Status), Tempo = $($result.Time)ms, Processados = $($result.Processed), Restantes = $($result.Remaining)"
    if ($result.Errors.Count -gt 0) {
        Write-Host "  Erros: $($result.Errors -join ', ')"
    }
}
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "🎉 Todas as execuções foram aprovadas!"
} else {
    Write-Host "⚠️ Algumas execuções falharam. Verifique os detalhes acima."
}
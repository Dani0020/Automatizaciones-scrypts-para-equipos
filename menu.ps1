# SCRIPT PARA BUSCAR Y GESTIONAR EVENTOS EN WINDOWS
# Este script presenta un menú interactivo para realizar tareas de diagnóstico básicas en el sistema.

# El bucle 'do-while' mantiene el menú en pantalla hasta que el usuario decida salir.
do {
    # Limpia la pantalla de la consola para una mejor visualización.
    Clear-Host

    # Muestra el encabezado del menú.
    Write-Host "=========================================="
    Write-Host "     Menú de Opciones de Eventos de Windows     "
    Write-Host "=========================================="
    
    # Muestra las opciones disponibles para el usuario.
    Write-Host "1. Buscar eventos de advertencia en las últimas 24 horas"
    Write-Host "2. Buscar eventos de error en la última semana"
    Write-Host "3. Buscar eventos criticos en la última semana"
    Write-Host "4. Mostrar uso de CPU y memoria"
    Write-Host "5. Salir"
    Write-Host "=========================================="
    
    # Solicita al usuario que ingrese una opción.
    $opcion = Read-Host "Por favor, selecciona una opción (1-5)"
    
    # La estructura 'switch' evalúa la opción seleccionada y ejecuta el código correspondiente.
    switch ($opcion) {
        # Opción 1: Buscar advertencias en las últimas 24 horas.
        "1" {
            Write-Host "Buscando eventos de advertencia de las últimas 24 horas..." -ForegroundColor Green
            
            # Define la hora de inicio (hace 24 horas).
            $startTime = (Get-Date).AddHours(-24)
            
            try {
                # Filtra los eventos en los registros 'System' y 'Application'.
                # Busca eventos de nivel de advertencia (nivel 3).
                $eventos = Get-WinEvent -FilterHashtable @{
                    LogName = 'System','Application'
                    Level = 3
                    StartTime = $startTime
                } -ErrorAction SilentlyContinue | Select-Object TimeCreated, LogName, LevelDisplayName, Message
                
                if ($eventos) {
                    Write-Host "Se encontraron $($eventos.Count) eventos de advertencia." -ForegroundColor Green
                    Write-Host ""
                    $eventos | Format-Table -AutoSize -Wrap
                }
                else {
                    Write-Host "No se encontraron eventos de advertencia en las últimas 24 horas." -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "Ocurrió un error al buscar eventos: $_" -ForegroundColor Red
            }
            
            Read-Host "Presiona Enter para continuar..."
        }

        # Opción 2: Buscar eventos de error en la última semana.
        "2" {
            Write-Host "Buscando eventos de error de la última semana..." -ForegroundColor Red
            
            # Define la hora de inicio (hace 7 días).
            $startTime = (Get-Date).AddDays(-7)
            
            try {
                # Filtra los eventos de nivel de error (nivel 2).
                $eventos = Get-WinEvent -FilterHashtable @{
                    LogName = 'System','Application'
                    Level = 2  # El nivel 2 es para errores
                    StartTime = $startTime
                } -ErrorAction SilentlyContinue | Select-Object TimeCreated, LogName, LevelDisplayName, Message
                
                if ($eventos) {
                    Write-Host "Se encontraron $($eventos.Count) eventos de error." -ForegroundColor Red
                    Write-Host ""
                    $eventos | Format-Table -AutoSize -Wrap
                }
                else {
                    Write-Host "No se encontraron eventos de error en la última semana." -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "Ocurrió un error al buscar eventos: $_" -ForegroundColor Red
            }
            
            Read-Host "Presiona Enter para continuar..."
        }

        # Opción 3: Buscar eventos críticos en la última semana.
        "3" {
            Write-Host "Buscando eventos críticos de la última semana..." -ForegroundColor Magenta
            
            # Define la hora de inicio (hace 7 días).
            $startTime = (Get-Date).AddDays(-7)
            
            try {
                # Filtra los eventos de nivel crítico (nivel 1).
                $eventos = Get-WinEvent -FilterHashtable @{
                    LogName = 'System','Application'
                    Level = 1  # El nivel 1 es para eventos críticos
                    StartTime = $startTime
                } -ErrorAction SilentlyContinue | Select-Object TimeCreated, LogName, LevelDisplayName, Message
                
                if ($eventos) {
                    Write-Host "Se encontraron $($eventos.Count) eventos críticos." -ForegroundColor Magenta
                    Write-Host ""
                    $eventos | Format-Table -AutoSize -Wrap
                }
                else {
                    Write-Host "No se encontraron eventos críticos en la última semana." -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "Ocurrió un error al buscar eventos: $_" -ForegroundColor Red
            }
            
            Read-Host "Presiona Enter para continuar..."
        }

        # Opción 4: Mostrar uso de CPU y memoria.
        "4" {
            Write-Host "Obteniendo uso de CPU y memoria..." -ForegroundColor Cyan
            
            try {
                # Se utiliza una forma más confiable de obtener el uso de CPU.
                $cpuUsage = (Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor | Where-Object { $_.Name -eq '_Total' }).PercentProcessorTime
                
                # Obtiene el total y la memoria libre en MB.
                $ramUsage = Get-CimInstance Win32_OperatingSystem
                $totalMemMB = [math]::Round($ramUsage.TotalVisibleMemorySize / 1MB, 2)
                $freeMemMB = [math]::Round($ramUsage.FreePhysicalMemory / 1MB, 2)
                
                Write-Host "Uso de CPU: $([math]::Round($cpuUsage, 2))%" -ForegroundColor Green
                Write-Host "Memoria total: $($totalMemMB) MB" -ForegroundColor Green
                Write-Host "Memoria libre: $($freeMemMB) MB" -ForegroundColor Green
                
                # Nuevo código para mostrar los procesos que más memoria consumen.
                Write-Host ""
                Write-Host "Procesos que más memoria están consumiendo (Top 10):" -ForegroundColor Cyan
                Write-Host "------------------------------------------------------"
                
                # Obtiene los procesos, los ordena por memoria y muestra los 10 primeros.
                # También se guardan en una variable para poder sumar su consumo.
                $topProcesses = Get-Process | Sort-Object -Property WorkingSet -Descending | Select-Object -First 10 -Property ProcessName, @{Name='Memoria (MB)'; Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}
                $topProcesses | Format-Table -AutoSize

                # Calcula y muestra el total de memoria consumida por estos 10 procesos.
                $totalTopMemory = ($topProcesses | Measure-Object -Property 'Memoria (MB)' -Sum).Sum
                Write-Host "Total de memoria consumida por los 10 procesos principales: $([math]::Round($totalTopMemory, 2)) MB" -ForegroundColor Yellow
            }
            catch {
                Write-Host "Ocurrió un error al obtener la información de CPU y memoria: $_" -ForegroundColor Red
            }
            
            Read-Host "Presiona Enter para continuar..."
        }
        
        # Opción 5: Salir del script.
        "5" {
            Write-Host "Saliendo del script. ¡Adiós!" -ForegroundColor Yellow
        }
        
        # Opción por defecto para cualquier entrada inválida.
        default {
            Write-Host "Opción no válida. Por favor, selecciona 1, 2, 3, 4 o 5." -ForegroundColor Red
            Read-Host "Presiona Enter para continuar..."
        }
    }
    # La condición 'while' se evalúa, si la opción no es "5", el menú se repite.
} while ($opcion -ne "5")

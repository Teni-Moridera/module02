# Полная установка БД practice6 (PowerShell)
# Требуется: PostgreSQL, psql в PATH

$dbName = "practice6"
$scripts = @("01_schema.sql", "02_users_roles.sql", "03_triggers.sql", "04_audit.sql", "07_demo_data.sql")

# Создание БД (если не существует)
psql -U postgres -c "SELECT 1 FROM pg_database WHERE datname = '$dbName'" -t | Out-Null
if ($LASTEXITCODE -ne 0) {
    psql -U postgres -c "CREATE DATABASE $dbName"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
foreach ($script in $scripts) {
    $path = Join-Path $scriptDir $script
    if (Test-Path $path) {
        Write-Host "Executing $script..."
        psql -U postgres -d $dbName -f $path
    }
}
Write-Host "Setup complete."

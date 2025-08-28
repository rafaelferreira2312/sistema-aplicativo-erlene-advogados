<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sistema Erlene Advogados - API</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #1e3a8a 0%, #dc2626 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            background: white;
            border-radius: 12px;
            padding: 40px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 500px;
            width: 90%;
        }
        .logo {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #dc2626, #b91c1c);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            color: white;
            font-size: 32px;
            font-weight: bold;
        }
        h1 {
            color: #1f2937;
            margin-bottom: 10px;
            font-size: 28px;
        }
        .subtitle {
            color: #6b7280;
            margin-bottom: 30px;
            font-size: 16px;
        }
        .status {
            background: #10b981;
            color: white;
            padding: 12px 24px;
            border-radius: 25px;
            display: inline-block;
            margin-bottom: 25px;
            font-weight: 500;
        }
        .info {
            background: #f3f4f6;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 25px;
        }
        .info-item {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #e5e7eb;
        }
        .info-item:last-child {
            border-bottom: none;
        }
        .label {
            font-weight: 600;
            color: #374151;
        }
        .value {
            color: #6b7280;
        }
        .footer {
            color: #9ca3af;
            font-size: 14px;
            margin-top: 30px;
        }
        .version {
            background: #3b82f6;
            color: white;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            display: inline-block;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">E</div>
        <h1>Sistema Erlene Advogados</h1>
        <p class="subtitle">API Backend Laravel</p>
        
        <div class="status">
            🟢 API Operacional
        </div>
        
        <div class="info">
            <div class="info-item">
                <span class="label">Status:</span>
                <span class="value">Conectado</span>
            </div>
            <div class="info-item">
                <span class="label">Ambiente:</span>
                <span class="value">{{ app()->environment() }}</span>
            </div>
            <div class="info-item">
                <span class="label">Versão Laravel:</span>
                <span class="value">{{ App::VERSION() }}</span>
            </div>
            <div class="info-item">
                <span class="label">Banco de Dados:</span>
                <span class="value">MySQL Conectado</span>
            </div>
            <div class="info-item">
                <span class="label">Data/Hora:</span>
                <span class="value">{{ now()->format('d/m/Y H:i:s') }}</span>
            </div>
        </div>
        
        <div class="footer">
            © 2024 Erlene Chaves Silva Advogados Associados
            <div class="version">v1.0.0</div>
        </div>
    </div>
</body>
</html>

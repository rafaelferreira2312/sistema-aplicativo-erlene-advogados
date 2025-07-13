<?php

namespace App\Services;

use App\Models\DocumentoGed;
use App\Models\Cliente;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class DocumentService extends BaseService
{
    protected $model = DocumentoGed::class;

    /**
     * Upload de documento
     */
    public function upload(UploadedFile $file, array $data)
    {
        return $this->executeWithLog(function() use ($file, $data) {
            return $this->transaction(function() use ($file, $data) {
                $validatedData = $this->validate($data, [
                    'cliente_id' => 'required|exists:clientes,id',
                    'descricao' => 'nullable|string',
                    'tags' => 'nullable|array',
                    'publico' => 'boolean',
                    'processo_id' => 'nullable|exists:processos,id'
                ]);

                // Validar arquivo
                $this->validateFile($file);

                $cliente = Cliente::findOrFail($validatedData['cliente_id']);
                
                // Processar upload baseado no tipo de storage
                $uploadResult = $this->processFileUpload($file, $cliente);

                // Criar registro no banco
                $documento = DocumentoGed::create([
                    'cliente_id' => $cliente->id,
                    'pasta' => $uploadResult['pasta'],
                    'nome_arquivo' => $uploadResult['nome_arquivo'],
                    'nome_original' => $file->getClientOriginalName(),
                    'caminho' => $uploadResult['caminho'],
                    'tipo_arquivo' => strtolower($file->getClientOriginalExtension()),
                    'mime_type' => $file->getMimeType(),
                    'tamanho' => $file->getSize(),
                    'data_upload' => now(),
                    'usuario_id' => auth()->id(),
                    'versao' => 1,
                    'storage_type' => $cliente->tipo_armazenamento,
                    'google_drive_id' => $uploadResult['google_drive_id'] ?? null,
                    'onedrive_id' => $uploadResult['onedrive_id'] ?? null,
                    'tags' => $validatedData['tags'] ?? [],
                    'descricao' => $validatedData['descricao'],
                    'publico' => $validatedData['publico'] ?? false,
                    'hash_arquivo' => $uploadResult['hash']
                ]);

                // Vincular a processo se especificado
                if (isset($validatedData['processo_id'])) {
                    $this->linkToProcess($documento, $validatedData['processo_id']);
                }

                $this->log('info', 'Documento enviado com sucesso', [
                    'documento_id' => $documento->id,
                    'cliente_id' => $cliente->id,
                    'nome_arquivo' => $documento->nome_original,
                    'tamanho' => $documento->tamanho,
                    'storage_type' => $documento->storage_type
                ]);

                return $documento->load(['cliente', 'usuario']);
            });
        }, ['operation' => 'upload_document']);
    }

    /**
     * Validar arquivo
     */
    private function validateFile(UploadedFile $file)
    {
        $maxSize = 10 * 1024 * 1024; // 10MB
        $allowedTypes = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png', 'gif', 'txt', 'zip', 'rar'];

        if ($file->getSize() > $maxSize) {
            throw new \InvalidArgumentException('Arquivo muito grande. Tamanho máximo: 10MB');
        }

        $extension = strtolower($file->getClientOriginalExtension());
        if (!in_array($extension, $allowedTypes)) {
            throw new \InvalidArgumentException('Tipo de arquivo não permitido');
        }

        // Verificar se o arquivo não está corrompido
        if (!$file->isValid()) {
            throw new \InvalidArgumentException('Arquivo corrompido ou inválido');
        }

        return true;
    }

    /**
     * Processar upload do arquivo
     */
    private function processFileUpload(UploadedFile $file, Cliente $cliente)
    {
        $nomeArquivo = Str::uuid() . '.' . $file->getClientOriginalExtension();
        $pastaCliente = $cliente->nome_pasta;
        $hash = hash_file('sha256', $file->getPathname());

        switch ($cliente->tipo_armazenamento) {
            case 'local':
                return $this->uploadToLocal($file, $pastaCliente, $nomeArquivo, $hash);
                
            case 'google_drive':
                return $this->uploadToGoogleDrive($file, $cliente, $nomeArquivo, $hash);
                
            case 'onedrive':
                return $this->uploadToOneDrive($file, $cliente, $nomeArquivo, $hash);
                
            default:
                throw new \InvalidArgumentException('Tipo de storage não suportado');
        }
    }

    /**
     * Upload para storage local
     */
    private function uploadToLocal(UploadedFile $file, string $pastaCliente, string $nomeArquivo, string $hash)
    {
        $pastaDiretorio = "clients/{$pastaCliente}/documentos";
        $caminho = $file->storeAs($pastaDiretorio, $nomeArquivo, 'local');

        return [
            'pasta' => $pastaCliente,
            'nome_arquivo' => $nomeArquivo,
            'caminho' => $caminho,
            'hash' => $hash
        ];
    }

    /**
     * Upload para Google Drive
     */
    private function uploadToGoogleDrive(UploadedFile $file, Cliente $cliente, string $nomeArquivo, string $hash)
    {
        // TODO: Implementar upload real para Google Drive
        // Por enquanto, fazer backup local
        $localResult = $this->uploadToLocal($file, $cliente->nome_pasta, $nomeArquivo, $hash);
        
        $googleDriveId = 'MOCK_GOOGLE_' . time() . '_' . Str::random(10);
        
        $this->log('info', 'Upload Google Drive simulado', [
            'cliente_id' => $cliente->id,
            'google_drive_id' => $googleDriveId
        ]);

        return array_merge($localResult, [
            'google_drive_id' => $googleDriveId
        ]);
    }

    /**
     * Upload para OneDrive
     */
    private function uploadToOneDrive(UploadedFile $file, Cliente $cliente, string $nomeArquivo, string $hash)
    {
        // TODO: Implementar upload real para OneDrive
        // Por enquanto, fazer backup local
        $localResult = $this->uploadToLocal($file, $cliente->nome_pasta, $nomeArquivo, $hash);
        
        $oneDriveId = 'MOCK_ONEDRIVE_' . time() . '_' . Str::random(10);
        
        $this->log('info', 'Upload OneDrive simulado', [
            'cliente_id' => $cliente->id,
            'onedrive_id' => $oneDriveId
        ]);

        return array_merge($localResult, [
            'onedrive_id' => $oneDriveId
        ]);
    }

    /**
     * Vincular documento a processo
     */
    private function linkToProcess(DocumentoGed $documento, int $processoId)
    {
        // TODO: Implementar vinculação processo-documento
        $this->log('info', 'Documento vinculado ao processo', [
            'documento_id' => $documento->id,
            'processo_id' => $processoId
        ]);
    }

    /**
     * Atualizar documento
     */
    public function update(DocumentoGed $documento, array $data)
    {
        return $this->executeWithLog(function() use ($documento, $data) {
            $validatedData = $this->validate($data, [
                'nome_original' => 'string',
                'descricao' => 'nullable|string',
                'tags' => 'nullable|array',
                'publico' => 'boolean'
            ]);

            $documento->update($validatedData);

            $this->log('info', 'Documento atualizado', [
                'documento_id' => $documento->id,
                'changes' => array_keys($validatedData)
            ]);

            return $documento->load(['cliente', 'usuario']);
        }, ['operation' => 'update_document', 'documento_id' => $documento->id]);
    }

    /**
     * Download de documento
     */
    public function download(DocumentoGed $documento)
    {
        return $this->executeWithLog(function() use ($documento) {
            switch ($documento->storage_type) {
                case 'local':
                    return $this->downloadFromLocal($documento);
                    
                case 'google_drive':
                    return $this->downloadFromGoogleDrive($documento);
                    
                case 'onedrive':
                    return $this->downloadFromOneDrive($documento);
                    
                default:
                    throw new \InvalidArgumentException('Tipo de storage não suportado para download');
            }
        }, ['operation' => 'download_document', 'documento_id' => $documento->id]);
    }

    /**
     * Download do storage local
     */
    private function downloadFromLocal(DocumentoGed $documento)
    {
        if (!Storage::disk('local')->exists($documento->caminho)) {
            throw new \Exception('Arquivo não encontrado no storage local');
        }

        $this->log('info', 'Download realizado', [
            'documento_id' => $documento->id,
            'storage_type' => 'local'
        ]);

        return Storage::disk('local')->download($documento->caminho, $documento->nome_original);
    }

    /**
     * Download do Google Drive
     */
    private function downloadFromGoogleDrive(DocumentoGed $documento)
    {
        // TODO: Implementar download real do Google Drive
        // Por enquanto, tentar download local como fallback
        
        $this->log('warning', 'Download Google Drive não implementado, usando fallback local', [
            'documento_id' => $documento->id
        ]);

        return $this->downloadFromLocal($documento);
    }

    /**
     * Download do OneDrive
     */
    private function downloadFromOneDrive(DocumentoGed $documento)
    {
        // TODO: Implementar download real do OneDrive
        // Por enquanto, tentar download local como fallback
        
        $this->log('warning', 'Download OneDrive não implementado, usando fallback local', [
            'documento_id' => $documento->id
        ]);

        return $this->downloadFromLocal($documento);
    }

    /**
     * Excluir documento
     */
    public function delete(DocumentoGed $documento)
    {
        return $this->executeWithLog(function() use ($documento) {
            return $this->transaction(function() use ($documento) {
                // Excluir arquivo físico
                $this->deletePhysicalFile($documento);

                // Excluir registro do banco
                $documento->delete();

                $this->log('info', 'Documento excluído', [
                    'documento_id' => $documento->id,
                    'nome_arquivo' => $documento->nome_original,
                    'storage_type' => $documento->storage_type
                ]);

                return true;
            });
        }, ['operation' => 'delete_document', 'documento_id' => $documento->id]);
    }

    /**
     * Excluir arquivo físico
     */
    private function deletePhysicalFile(DocumentoGed $documento)
    {
        try {
            switch ($documento->storage_type) {
                case 'local':
                    if (Storage::disk('local')->exists($documento->caminho)) {
                        Storage::disk('local')->delete($documento->caminho);
                    }
                    break;
                    
                case 'google_drive':
                    // TODO: Implementar exclusão do Google Drive
                    $this->log('info', 'Exclusão Google Drive simulada', [
                        'documento_id' => $documento->id,
                        'google_drive_id' => $documento->google_drive_id
                    ]);
                    break;
                    
                case 'onedrive':
                    // TODO: Implementar exclusão do OneDrive
                    $this->log('info', 'Exclusão OneDrive simulada', [
                        'documento_id' => $documento->id,
                        'onedrive_id' => $documento->onedrive_id
                    ]);
                    break;
            }
        } catch (\Exception $e) {
            $this->log('error', 'Erro ao excluir arquivo físico', [
                'documento_id' => $documento->id,
                'error' => $e->getMessage()
            ]);
            // Não falha a operação se não conseguir excluir o arquivo físico
        }
    }

    /**
     * Buscar documentos
     */
    public function search(array $filters)
    {
        $query = DocumentoGed::with(['cliente', 'usuario']);

        if (isset($filters['search'])) {
            $search = $filters['search'];
            $query->where(function($q) use ($search) {
                $q->where('nome_arquivo', 'like', "%{$search}%")
                  ->orWhere('nome_original', 'like', "%{$search}%")
                  ->orWhere('descricao', 'like', "%{$search}%");
            });
        }

        if (isset($filters['cliente_id'])) {
            $query->where('cliente_id', $filters['cliente_id']);
        }

        if (isset($filters['tipo_arquivo'])) {
            $query->where('tipo_arquivo', $filters['tipo_arquivo']);
        }

        if (isset($filters['storage_type'])) {
            $query->where('storage_type', $filters['storage_type']);
        }

        if (isset($filters['publico'])) {
            $query->where('publico', $filters['publico']);
        }

        if (isset($filters['usuario_id'])) {
            $query->where('usuario_id', $filters['usuario_id']);
        }

        if (isset($filters['tags'])) {
            $tags = is_array($filters['tags']) ? $filters['tags'] : [$filters['tags']];
            $query->where(function($q) use ($tags) {
                foreach ($tags as $tag) {
                    $q->orWhereJsonContains('tags', $tag);
                }
            });
        }

        if (isset($filters['data_upload_inicio']) && isset($filters['data_upload_fim'])) {
            $query->whereBetween('data_upload', [
                $filters['data_upload_inicio'],
                $filters['data_upload_fim']
            ]);
        }

        if (isset($filters['tamanho_min'])) {
            $query->where('tamanho', '>=', $filters['tamanho_min']);
        }

        if (isset($filters['tamanho_max'])) {
            $query->where('tamanho', '<=', $filters['tamanho_max']);
        }

        return $query->orderBy('data_upload', 'desc');
    }

    /**
     * Estatísticas de documentos
     */
    public function getStats(array $filters = [])
    {
        $cacheKey = 'document_stats_' . md5(serialize($filters));
        
        return $this->cache($cacheKey, function() use ($filters) {
            $query = DocumentoGed::query();

            if (isset($filters['cliente_id'])) {
                $query->where('cliente_id', $filters['cliente_id']);
            }

            if (isset($filters['unidade_id'])) {
                $query->whereHas('cliente', function($q) use ($filters) {
                    $q->where('unidade_id', $filters['unidade_id']);
                });
            }

            $documentos = $query->get();

            return [
                'total_documentos' => $documentos->count(),
                'tamanho_total' => $documentos->sum('tamanho'),
                'tamanho_medio' => $documentos->avg('tamanho'),
                'por_tipo' => $documentos->groupBy('tipo_arquivo')->map->count(),
                'por_storage' => $documentos->groupBy('storage_type')->map->count(),
                'publicos' => $documentos->where('publico', true)->count(),
                'upload_mes_atual' => $documentos->filter(function($doc) {
                    return $doc->data_upload >= now()->startOfMonth();
                })->count(),
                'por_cliente' => $documentos->groupBy('cliente.nome')->map->count()->take(10)
            ];
        }, 1800); // Cache por 30 minutos
    }

    /**
     * Migrar documentos entre storages
     */
    public function migrateStorage(Cliente $cliente, string $newStorageType)
    {
        return $this->executeWithLog(function() use ($cliente, $newStorageType) {
            if ($cliente->tipo_armazenamento === $newStorageType) {
                throw new \InvalidArgumentException('Cliente já utiliza este tipo de storage');
            }

            return $this->transaction(function() use ($cliente, $newStorageType) {
                $documentos = $cliente->documentos;
                $migratedCount = 0;
                $errors = [];

                foreach ($documentos as $documento) {
                    try {
                        $this->migrateDocument($documento, $newStorageType);
                        $migratedCount++;
                    } catch (\Exception $e) {
                        $errors[] = [
                            'documento_id' => $documento->id,
                            'nome' => $documento->nome_original,
                            'erro' => $e->getMessage()
                        ];
                    }
                }

                // Atualizar tipo de storage do cliente
                $cliente->update(['tipo_armazenamento' => $newStorageType]);

                $this->log('info', 'Migração de storage concluída', [
                    'cliente_id' => $cliente->id,
                    'from' => $cliente->getOriginal('tipo_armazenamento'),
                    'to' => $newStorageType,
                    'migrated' => $migratedCount,
                    'errors' => count($errors)
                ]);

                return [
                    'migrated' => $migratedCount,
                    'errors' => $errors,
                    'total' => $documentos->count()
                ];
            });
        }, ['operation' => 'migrate_storage', 'cliente_id' => $cliente->id]);
    }

    /**
     * Migrar documento individual
     */
    private function migrateDocument(DocumentoGed $documento, string $newStorageType)
    {
        // TODO: Implementar migração real entre storages
        $documento->update(['storage_type' => $newStorageType]);
        
        $this->log('info', 'Documento migrado', [
            'documento_id' => $documento->id,
            'new_storage' => $newStorageType
        ]);
    }

    /**
     * Verificar integridade dos arquivos
     */
    public function checkIntegrity(array $filters = [])
    {
        return $this->executeWithLog(function() use ($filters) {
            $query = DocumentoGed::query();
            
            if (isset($filters['cliente_id'])) {
                $query->where('cliente_id', $filters['cliente_id']);
            }

            if (isset($filters['storage_type'])) {
                $query->where('storage_type', $filters['storage_type']);
            }

            $documentos = $query->get();
            $results = [
                'total_verificados' => 0,
                'arquivos_ok' => 0,
                'arquivos_com_erro' => 0,
                'erros' => []
            ];

            foreach ($documentos as $documento) {
                $results['total_verificados']++;
                
                try {
                    $this->verifyDocumentIntegrity($documento);
                    $results['arquivos_ok']++;
                } catch (\Exception $e) {
                    $results['arquivos_com_erro']++;
                    $results['erros'][] = [
                        'documento_id' => $documento->id,
                        'nome' => $documento->nome_original,
                        'erro' => $e->getMessage()
                    ];
                }
            }

            $this->log('info', 'Verificação de integridade concluída', $results);

            return $results;
        }, ['operation' => 'check_integrity']);
    }

    /**
     * Verificar integridade de documento individual
     */
    private function verifyDocumentIntegrity(DocumentoGed $documento)
    {
        switch ($documento->storage_type) {
            case 'local':
                if (!Storage::disk('local')->exists($documento->caminho)) {
                    throw new \Exception('Arquivo não encontrado no storage local');
                }
                
                // Verificar hash se disponível
                if ($documento->hash_arquivo) {
                    $currentHash = hash_file('sha256', Storage::disk('local')->path($documento->caminho));
                    if ($currentHash !== $documento->hash_arquivo) {
                        throw new \Exception('Hash do arquivo não confere - arquivo pode estar corrompido');
                    }
                }
                break;
                
            case 'google_drive':
                // TODO: Implementar verificação Google Drive
                if (!$documento->google_drive_id) {
                    throw new \Exception('ID do Google Drive não encontrado');
                }
                break;
                
            case 'onedrive':
                // TODO: Implementar verificação OneDrive
                if (!$documento->onedrive_id) {
                    throw new \Exception('ID do OneDrive não encontrado');
                }
                break;
        }

        return true;
    }
}

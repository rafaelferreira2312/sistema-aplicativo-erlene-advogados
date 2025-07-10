<?php

namespace App\Http\Controllers\Api\Admin\Documents;

use App\Http\Controllers\Controller;
use App\Models\DocumentoGed;
use App\Models\Cliente;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class DocumentController extends Controller
{
    /**
     * @OA\Get(
     *     path="/admin/documents",
     *     summary="Listar documentos",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Lista de documentos")
     * )
     */
    public function index(Request $request)
    {
        $user = auth()->user();
        $query = DocumentoGed::with(['cliente', 'usuario'])
                            ->whereHas('cliente', function($q) use ($user) {
                                $q->where('unidade_id', $user->unidade_id);
                            });

        // Filtros
        if ($request->search) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('nome_arquivo', 'like', "%{$search}%")
                  ->orWhere('nome_original', 'like', "%{$search}%")
                  ->orWhere('descricao', 'like', "%{$search}%");
            });
        }

        if ($request->cliente_id) {
            $query->where('cliente_id', $request->cliente_id);
        }

        if ($request->tipo_arquivo) {
            $query->where('tipo_arquivo', $request->tipo_arquivo);
        }

        if ($request->storage_type) {
            $query->where('storage_type', $request->storage_type);
        }

        if ($request->publico !== null) {
            $query->where('publico', $request->publico);
        }

        $documentos = $query->orderBy('data_upload', 'desc')
                           ->paginate($request->per_page ?? 15);

        return $this->paginated($documentos);
    }

    /**
     * @OA\Post(
     *     path="/admin/documents/upload",
     *     summary="Upload de documento",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\MediaType(
     *             mediaType="multipart/form-data",
     *             @OA\Schema(
     *                 required={"arquivo","cliente_id"},
     *                 @OA\Property(property="arquivo", type="string", format="binary"),
     *                 @OA\Property(property="cliente_id", type="integer"),
     *                 @OA\Property(property="descricao", type="string"),
     *                 @OA\Property(property="publico", type="boolean")
     *             )
     *         )
     *     ),
     *     @OA\Response(response=201, description="Documento enviado com sucesso")
     * )
     */
    public function upload(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'arquivo' => 'required|file|max:10240', // 10MB max
            'cliente_id' => 'required|exists:clientes,id',
            'descricao' => 'nullable|string',
            'tags' => 'nullable|array',
            'publico' => 'boolean'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $user = auth()->user();
        
        // Verificar se cliente pertence à unidade
        $cliente = Cliente::where('id', $request->cliente_id)
                         ->where('unidade_id', $user->unidade_id)
                         ->first();
        
        if (!$cliente) {
            return $this->error('Cliente não encontrado', 404);
        }

        $arquivo = $request->file('arquivo');
        $nomeOriginal = $arquivo->getClientOriginalName();
        $extensao = $arquivo->getClientOriginalExtension();
        $mimeType = $arquivo->getMimeType();
        $tamanho = $arquivo->getSize();
        
        // Gerar nome único
        $nomeArquivo = Str::uuid() . '.' . $extensao;
        
        // Definir pasta do cliente
        $pastaCliente = $cliente->nome_pasta;
        $caminhoCompleto = "clients/{$pastaCliente}/{$nomeArquivo}";

        // Fazer upload baseado no tipo de storage
        $storageType = $cliente->tipo_armazenamento;
        $googleDriveId = null;
        $oneDriveId = null;

        try {
            switch ($storageType) {
                case 'local':
                    $caminho = $arquivo->storeAs("clients/{$pastaCliente}", $nomeArquivo, 'local');
                    break;
                    
                case 'google_drive':
                    // TODO: Implementar upload para Google Drive
                    $caminho = $arquivo->storeAs("clients/{$pastaCliente}", $nomeArquivo, 'local');
                    $googleDriveId = 'MOCK_GOOGLE_ID_' . time();
                    break;
                    
                case 'onedrive':
                    // TODO: Implementar upload para OneDrive
                    $caminho = $arquivo->storeAs("clients/{$pastaCliente}", $nomeArquivo, 'local');
                    $oneDriveId = 'MOCK_ONEDRIVE_ID_' . time();
                    break;
                    
                default:
                    $caminho = $arquivo->storeAs("clients/{$pastaCliente}", $nomeArquivo, 'local');
            }

            // Gerar hash do arquivo para verificação de integridade
            $hashArquivo = hash_file('sha256', $arquivo->getPathname());

            // Salvar no banco de dados
            $documento = DocumentoGed::create([
                'cliente_id' => $cliente->id,
                'pasta' => $pastaCliente,
                'nome_arquivo' => $nomeArquivo,
                'nome_original' => $nomeOriginal,
                'caminho' => $caminho,
                'tipo_arquivo' => strtolower($extensao),
                'mime_type' => $mimeType,
                'tamanho' => $tamanho,
                'data_upload' => now(),
                'usuario_id' => $user->id,
                'versao' => 1,
                'storage_type' => $storageType,
                'google_drive_id' => $googleDriveId,
                'onedrive_id' => $oneDriveId,
                'tags' => $request->tags ?? [],
                'descricao' => $request->descricao,
                'publico' => $request->publico ?? false,
                'hash_arquivo' => $hashArquivo
            ]);

            $documento->load(['cliente', 'usuario']);

            return $this->success($documento, 'Documento enviado com sucesso', 201);

        } catch (\Exception $e) {
            return $this->error('Erro ao fazer upload do documento: ' . $e->getMessage(), 500);
        }
    }

    /**
     * @OA\Get(
     *     path="/admin/documents/{id}",
     *     summary="Obter documento",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Dados do documento")
     * )
     */
    public function show($id)
    {
        $user = auth()->user();
        $documento = DocumentoGed::with(['cliente', 'usuario'])
                                ->whereHas('cliente', function($q) use ($user) {
                                    $q->where('unidade_id', $user->unidade_id);
                                })
                                ->findOrFail($id);

        return $this->success($documento);
    }

    /**
     * @OA\Put(
     *     path="/admin/documents/{id}",
     *     summary="Atualizar documento",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Documento atualizado com sucesso")
     * )
     */
    public function update(Request $request, $id)
    {
        $user = auth()->user();
        $documento = DocumentoGed::whereHas('cliente', function($q) use ($user) {
                                     $q->where('unidade_id', $user->unidade_id);
                                 })
                                 ->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'nome_original' => 'string',
            'descricao' => 'nullable|string',
            'tags' => 'nullable|array',
            'publico' => 'boolean'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $documento->update($request->all());
        $documento->load(['cliente', 'usuario']);

        return $this->success($documento, 'Documento atualizado com sucesso');
    }

    /**
     * @OA\Delete(
     *     path="/admin/documents/{id}",
     *     summary="Excluir documento",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Documento excluído com sucesso")
     * )
     */
    public function destroy($id)
    {
        $user = auth()->user();
        $documento = DocumentoGed::whereHas('cliente', function($q) use ($user) {
                                     $q->where('unidade_id', $user->unidade_id);
                                 })
                                 ->findOrFail($id);

        try {
            // Excluir arquivo físico
            if ($documento->storage_type === 'local' && Storage::exists($documento->caminho)) {
                Storage::delete($documento->caminho);
            }

            // TODO: Implementar exclusão no Google Drive e OneDrive

            $documento->delete();

            return $this->success(null, 'Documento excluído com sucesso');

        } catch (\Exception $e) {
            return $this->error('Erro ao excluir documento: ' . $e->getMessage(), 500);
        }
    }

    /**
     * @OA\Get(
     *     path="/admin/documents/{id}/download",
     *     summary="Download de documento",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Download do arquivo")
     * )
     */
    public function download($id)
    {
        $user = auth()->user();
        $documento = DocumentoGed::whereHas('cliente', function($q) use ($user) {
                                     $q->where('unidade_id', $user->unidade_id);
                                 })
                                 ->findOrFail($id);

        try {
            if ($documento->storage_type === 'local') {
                if (!Storage::exists($documento->caminho)) {
                    return $this->error('Arquivo não encontrado', 404);
                }

                return Storage::download($documento->caminho, $documento->nome_original);
            }

            // TODO: Implementar download do Google Drive e OneDrive
            return $this->error('Download não implementado para este tipo de storage', 501);

        } catch (\Exception $e) {
            return $this->error('Erro ao fazer download: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Listar documentos por cliente
     */
    public function porCliente($clienteId, Request $request)
    {
        $user = auth()->user();
        
        // Verificar se cliente pertence à unidade
        $cliente = Cliente::where('id', $clienteId)
                         ->where('unidade_id', $user->unidade_id)
                         ->first();
        
        if (!$cliente) {
            return $this->error('Cliente não encontrado', 404);
        }

        $query = DocumentoGed::with(['usuario'])
                            ->where('cliente_id', $clienteId);

        if ($request->tipo_arquivo) {
            $query->where('tipo_arquivo', $request->tipo_arquivo);
        }

        $documentos = $query->orderBy('data_upload', 'desc')
                           ->paginate($request->per_page ?? 20);

        return $this->paginated($documentos);
    }

    /**
     * Estatísticas de documentos
     */
    public function estatisticas()
    {
        $user = auth()->user();
        
        $stats = [
            'total_documentos' => DocumentoGed::whereHas('cliente', function($q) use ($user) {
                                                 $q->where('unidade_id', $user->unidade_id);
                                             })->count(),
            
            'por_tipo' => DocumentoGed::whereHas('cliente', function($q) use ($user) {
                                         $q->where('unidade_id', $user->unidade_id);
                                     })
                                     ->selectRaw('tipo_arquivo, COUNT(*) as total')
                                     ->groupBy('tipo_arquivo')
                                     ->get(),
            
            'por_storage' => DocumentoGed::whereHas('cliente', function($q) use ($user) {
                                          $q->where('unidade_id', $user->unidade_id);
                                      })
                                      ->selectRaw('storage_type, COUNT(*) as total')
                                      ->groupBy('storage_type')
                                      ->get(),
            
            'tamanho_total' => DocumentoGed::whereHas('cliente', function($q) use ($user) {
                                            $q->where('unidade_id', $user->unidade_id);
                                        })->sum('tamanho')
        ];

        return $this->success($stats);
    }
}

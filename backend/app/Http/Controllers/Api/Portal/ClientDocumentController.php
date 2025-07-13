<?php

namespace App\Http\Controllers\Api\Portal;

use App\Http\Controllers\Controller;
use App\Models\DocumentoGed;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ClientDocumentController extends Controller
{
    /**
     * @OA\Get(
     *     path="/portal/documents",
     *     summary="Listar documentos do cliente",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Lista de documentos")
     * )
     */
    public function index(Request $request)
    {
        $cliente = auth('cliente')->user();
        
        $query = $cliente->documentos()->with(['usuario']);

        // Filtros
        if ($request->tipo_arquivo) {
            $query->where('tipo_arquivo', $request->tipo_arquivo);
        }

        if ($request->publico !== null) {
            $query->where('publico', $request->publico);
        }

        if ($request->search) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('nome_original', 'like', "%{$search}%")
                  ->orWhere('descricao', 'like', "%{$search}%");
            });
        }

        $documentos = $query->orderBy('data_upload', 'desc')
                           ->paginate($request->per_page ?? 15);

        // Registrar acesso
        $cliente->acessosPortal()->create([
            'ip' => request()->ip(),
            'user_agent' => request()->userAgent(),
            'data_acesso' => now(),
            'acao' => 'visualizar_documentos'
        ]);

        return $this->paginated($documentos);
    }

    /**
     * @OA\Get(
     *     path="/portal/documents/{id}",
     *     summary="Obter documento",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Dados do documento")
     * )
     */
    public function show($id)
    {
        $cliente = auth('cliente')->user();
        
        $documento = $cliente->documentos()
                           ->with(['usuario'])
                           ->findOrFail($id);

        return $this->success($documento);
    }

    /**
     * @OA\Get(
     *     path="/portal/documents/{id}/download",
     *     summary="Download de documento pelo cliente",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Download do arquivo")
     * )
     */
    public function download($id)
    {
        $cliente = auth('cliente')->user();
        
        $documento = $cliente->documentos()->findOrFail($id);

        // Registrar acesso ao download
        $cliente->acessosPortal()->create([
            'ip' => request()->ip(),
            'user_agent' => request()->userAgent(),
            'data_acesso' => now(),
            'acao' => 'download_documento',
            'detalhes' => "Documento: {$documento->nome_original}"
        ]);

        try {
            if ($documento->storage_type === 'local') {
                if (!Storage::exists($documento->caminho)) {
                    return $this->error('Arquivo não encontrado', 404);
                }

                return Storage::download($documento->caminho, $documento->nome_original);
            }

            // TODO: Implementar download do Google Drive e OneDrive
            return $this->error('Download não disponível para este tipo de storage', 501);

        } catch (\Exception $e) {
            return $this->error('Erro ao fazer download: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Upload de documento pelo cliente
     */
    public function upload(Request $request)
    {
        $validator = \Validator::make($request->all(), [
            'arquivo' => 'required|file|max:5120', // 5MB max para clientes
            'descricao' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $cliente = auth('cliente')->user();

        try {
            $arquivo = $request->file('arquivo');
            $nomeOriginal = $arquivo->getClientOriginalName();
            $extensao = $arquivo->getClientOriginalExtension();
            $mimeType = $arquivo->getMimeType();
            $tamanho = $arquivo->getSize();
            
            // Verificar tipos permitidos
            $tiposPermitidos = ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'];
            if (!in_array(strtolower($extensao), $tiposPermitidos)) {
                return $this->error('Tipo de arquivo não permitido', 400);
            }
            
            // Gerar nome único
            $nomeArquivo = \Str::uuid() . '.' . $extensao;
            
            // Definir pasta do cliente
            $pastaCliente = $cliente->nome_pasta;
            $caminhoCompleto = "clients/{$pastaCliente}/uploads/{$nomeArquivo}";

            // Upload local (clientes só podem fazer upload local)
            $caminho = $arquivo->storeAs("clients/{$pastaCliente}/uploads", $nomeArquivo, 'local');

            // Gerar hash do arquivo
            $hashArquivo = hash_file('sha256', $arquivo->getPathname());

            // Salvar no banco
            $documento = DocumentoGed::create([
                'cliente_id' => $cliente->id,
                'pasta' => $pastaCliente . '/uploads',
                'nome_arquivo' => $nomeArquivo,
                'nome_original' => $nomeOriginal,
                'caminho' => $caminho,
                'tipo_arquivo' => strtolower($extensao),
                'mime_type' => $mimeType,
                'tamanho' => $tamanho,
                'data_upload' => now(),
                'usuario_id' => null, // Upload pelo cliente
                'versao' => 1,
                'storage_type' => 'local',
                'tags' => ['upload_cliente'],
                'descricao' => $request->descricao,
                'publico' => false,
                'hash_arquivo' => $hashArquivo
            ]);

            // Registrar acesso
            $cliente->acessosPortal()->create([
                'ip' => request()->ip(),
                'user_agent' => request()->userAgent(),
                'data_acesso' => now(),
                'acao' => 'upload_documento',
                'detalhes' => "Arquivo: {$nomeOriginal}"
            ]);

            return $this->success($documento, 'Documento enviado com sucesso', 201);

        } catch (\Exception $e) {
            return $this->error('Erro ao fazer upload: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Estatísticas de documentos do cliente
     */
    public function statistics()
    {
        $cliente = auth('cliente')->user();
        
        $stats = [
            'total_documentos' => $cliente->documentos()->count(),
            'por_tipo' => $cliente->documentos()
                               ->selectRaw('tipo_arquivo, COUNT(*) as total')
                               ->groupBy('tipo_arquivo')
                               ->get(),
            'tamanho_total' => $cliente->documentos()->sum('tamanho'),
            'uploads_mes_atual' => $cliente->documentos()
                                         ->whereMonth('data_upload', now()->month)
                                         ->count()
        ];

        return $this->success($stats);
    }
}

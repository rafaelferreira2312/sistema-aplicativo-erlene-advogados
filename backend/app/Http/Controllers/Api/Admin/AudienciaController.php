<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Audiencia;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Carbon\Carbon;
use Exception;

class AudienciaController extends Controller
{
    /**
     * Listar audiências - seguindo padrão do ClientController
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $query = Audiencia::query();
            
            // Tentar carregar relacionamentos se existirem
            try {
                $query->with(['processo', 'cliente']);
            } catch (Exception $e) {
                // Se relacionamentos falharem, continuar sem eles
            }
            
            // Filtros básicos
            if ($request->filled('status')) {
                $query->where('status', $request->status);
            }
            
            if ($request->filled('tipo')) {
                $query->where('tipo', $request->tipo);
            }
            
            if ($request->filled('data_inicio') && $request->filled('data_fim')) {
                $query->whereBetween('data', [$request->data_inicio, $request->data_fim]);
            }

            // Ordenação padrão
            $query->orderBy('data', 'desc')->orderBy('hora', 'desc');

            // Paginação seguindo padrão
            $perPage = $request->get('per_page', 10);
            $audiencias = $query->paginate($perPage);

            // Formatar dados seguindo padrão do sistema
            $data = $audiencias->getCollection()->map(function($audiencia) {
                return [
                    'id' => $audiencia->id,
                    'processo_id' => $audiencia->processo_id,
                    'cliente_id' => $audiencia->cliente_id,
                    'processo' => [
                        'id' => $audiencia->processo_id,
                        'numero' => $audiencia->processo->numero ?? "Processo #{$audiencia->processo_id}"
                    ],
                    'cliente' => [
                        'id' => $audiencia->cliente_id,
                        'nome' => $audiencia->cliente->nome ?? $audiencia->cliente->name ?? "Cliente #{$audiencia->cliente_id}"
                    ],
                    'tipo' => $audiencia->tipo,
                    'data' => $audiencia->data,
                    'hora' => $audiencia->hora,
                    'local' => $audiencia->local,
                    'endereco' => $audiencia->endereco,
                    'sala' => $audiencia->sala,
                    'advogado' => $audiencia->advogado,
                    'juiz' => $audiencia->juiz,
                    'status' => $audiencia->status,
                    'observacoes' => $audiencia->observacoes,
                    'lembrete' => $audiencia->lembrete,
                    'horas_lembrete' => $audiencia->horas_lembrete,
                    'created_at' => $audiencia->created_at,
                    'updated_at' => $audiencia->updated_at
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $data,
                'pagination' => [
                    'current_page' => $audiencias->currentPage(),
                    'last_page' => $audiencias->lastPage(),
                    'per_page' => $audiencias->perPage(),
                    'total' => $audiencias->total()
                ]
            ]);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao listar audiências',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * 🚨 MÉTODO CORRIGIDO: dashboardStats (não stats)
     */
    public function dashboardStats(): JsonResponse
    {
        try {
            $hoje = Carbon::today();
            
            $stats = [
                'hoje' => Audiencia::whereDate('data', $hoje)->count(),
                'proximas_2h' => Audiencia::whereDate('data', $hoje)
                    ->whereTime('hora', '>=', Carbon::now()->format('H:i:s'))
                    ->whereTime('hora', '<=', Carbon::now()->addHours(2)->format('H:i:s'))
                    ->count(),
                'em_andamento' => Audiencia::where('status', 'confirmada')
                    ->whereDate('data', $hoje)->count(),
                'total_mes' => Audiencia::whereMonth('data', $hoje->month)
                    ->whereYear('data', $hoje->year)->count(),
                'agendadas' => Audiencia::whereIn('status', ['agendada', 'confirmada'])
                    ->where('data', '>=', $hoje)->count(),
                'realizadas_mes' => Audiencia::where('status', 'realizada')
                    ->whereMonth('data', $hoje->month)
                    ->whereYear('data', $hoje->year)->count()
            ];

            return response()->json([
                'success' => true,
                'data' => $stats
            ]);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao obter estatísticas',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Audiências de hoje
     */
    public function hoje(): JsonResponse
    {
        try {
            $audiencias = Audiencia::whereDate('data', Carbon::today())
                ->orderBy('hora', 'asc')
                ->get()
                ->map(function($audiencia) {
                    return [
                        'id' => $audiencia->id,
                        'processo' => [
                            'numero' => "Processo #{$audiencia->processo_id}"
                        ],
                        'cliente' => [
                            'nome' => "Cliente #{$audiencia->cliente_id}"
                        ],
                        'tipo' => $audiencia->tipo,
                        'hora' => $audiencia->hora,
                        'local' => $audiencia->local,
                        'status' => $audiencia->status,
                        'advogado' => $audiencia->advogado
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $audiencias
            ]);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar audiências de hoje',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Próximas audiências
     */
    public function proximas(Request $request): JsonResponse
    {
        try {
            $horas = $request->get('horas', 2);
            $agora = Carbon::now();
            
            $audiencias = Audiencia::whereDate('data', Carbon::today())
                ->whereTime('hora', '>=', $agora->format('H:i:s'))
                ->whereTime('hora', '<=', $agora->addHours($horas)->format('H:i:s'))
                ->orderBy('hora', 'asc')
                ->get()
                ->map(function($audiencia) {
                    return [
                        'id' => $audiencia->id,
                        'processo' => [
                            'numero' => "Processo #{$audiencia->processo_id}"
                        ],
                        'cliente' => [
                            'nome' => "Cliente #{$audiencia->cliente_id}"
                        ],
                        'tipo' => $audiencia->tipo,
                        'hora' => $audiencia->hora,
                        'local' => $audiencia->local,
                        'status' => $audiencia->status
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $audiencias
            ]);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar próximas audiências',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Exibir audiência específica
     */
    public function show($id): JsonResponse
    {
        try {
            $audiencia = Audiencia::findOrFail($id);

            $data = [
                'id' => $audiencia->id,
                'processo_id' => $audiencia->processo_id,
                'cliente_id' => $audiencia->cliente_id,
                'advogado_id' => $audiencia->advogado_id,
                'unidade_id' => $audiencia->unidade_id,
                'tipo' => $audiencia->tipo,
                'data' => $audiencia->data,
                'hora' => $audiencia->hora,
                'local' => $audiencia->local,
                'endereco' => $audiencia->endereco,
                'sala' => $audiencia->sala,
                'advogado' => $audiencia->advogado,
                'juiz' => $audiencia->juiz,
                'status' => $audiencia->status,
                'observacoes' => $audiencia->observacoes,
                'lembrete' => $audiencia->lembrete,
                'horas_lembrete' => $audiencia->horas_lembrete,
                'created_at' => $audiencia->created_at,
                'updated_at' => $audiencia->updated_at
            ];

            return response()->json([
                'success' => true,
                'data' => $data
            ]);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Audiência não encontrada',
                'error' => $e->getMessage()
            ], 404);
        }
    }

    /**
     * Criar nova audiência
     */
    public function store(Request $request): JsonResponse
    {
        try {
            $validatedData = $request->validate([
                'processo_id' => 'required|integer',
                'cliente_id' => 'required|integer', 
                'advogado_id' => 'nullable|integer',
                'unidade_id' => 'nullable|integer',
                'tipo' => 'required|string',
                'data' => 'required|date',
                'hora' => 'required|string',
                'local' => 'required|string',
                'endereco' => 'nullable|string',
                'sala' => 'nullable|string',
                'advogado' => 'required|string',
                'juiz' => 'nullable|string',
                'status' => 'nullable|string',
                'observacoes' => 'nullable|string',
                'lembrete' => 'nullable|boolean',
                'horas_lembrete' => 'nullable|integer'
            ]);

            // Definir valores padrão
            $validatedData['status'] = $validatedData['status'] ?? 'agendada';
            $validatedData['lembrete'] = $validatedData['lembrete'] ?? true;
            $validatedData['horas_lembrete'] = $validatedData['horas_lembrete'] ?? 2;

            $audiencia = Audiencia::create($validatedData);

            return response()->json([
                'success' => true,
                'message' => 'Audiência criada com sucesso',
                'data' => $audiencia
            ], 201);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao criar audiência',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Atualizar audiência
     */
    public function update(Request $request, $id): JsonResponse
    {
        try {
            $audiencia = Audiencia::findOrFail($id);

            $validatedData = $request->validate([
                'processo_id' => 'sometimes|integer',
                'cliente_id' => 'sometimes|integer',
                'advogado_id' => 'sometimes|integer',
                'unidade_id' => 'sometimes|integer',
                'tipo' => 'sometimes|string',
                'data' => 'sometimes|date',
                'hora' => 'sometimes|string',
                'local' => 'sometimes|string',
                'endereco' => 'nullable|string',
                'sala' => 'nullable|string',
                'advogado' => 'sometimes|string',
                'juiz' => 'nullable|string',
                'status' => 'sometimes|string',
                'observacoes' => 'nullable|string',
                'lembrete' => 'sometimes|boolean',
                'horas_lembrete' => 'sometimes|integer'
            ]);

            $audiencia->update($validatedData);

            return response()->json([
                'success' => true,
                'message' => 'Audiência atualizada com sucesso',
                'data' => $audiencia
            ]);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao atualizar audiência',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Excluir audiência
     */
    public function destroy($id): JsonResponse
    {
        try {
            $audiencia = Audiencia::findOrFail($id);
            $audiencia->delete();

            return response()->json([
                'success' => true,
                'message' => 'Audiência excluída com sucesso'
            ]);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao excluir audiência',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}

<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Audiencia;
use App\Models\Processo;
use App\Models\Cliente;
use App\Models\User;
use App\Models\Unidade;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\Rule;
use Carbon\Carbon;
use Exception;

class AudienciaController extends Controller
{
    /**
     * Listar todas as audiências com filtros
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $query = Audiencia::with(['processo', 'cliente', 'advogadoResponsavel', 'unidade']);

            // Filtros
            if ($request->filled('data_inicio') && $request->filled('data_fim')) {
                $query->porPeriodo($request->data_inicio, $request->data_fim);
            }

            if ($request->filled('status')) {
                $query->porStatus($request->status);
            }

            if ($request->filled('tipo')) {
                $query->porTipo($request->tipo);
            }

            if ($request->filled('advogado_id')) {
                $query->where('advogado_id', $request->advogado_id);
            }

            if ($request->filled('cliente_id')) {
                $query->where('cliente_id', $request->cliente_id);
            }

            // Ordenação padrão: próximas audiências primeiro
            $query->orderBy('data', 'asc')->orderBy('hora', 'asc');

            // Paginação
            $perPage = $request->get('per_page', 15);
            $audiencias = $query->paginate($perPage);

            // Formatar dados para o frontend
            $audienciasFormatadas = $audiencias->getCollection()->map(function ($audiencia) {
                return [
                    'id' => $audiencia->id,
                    'processo' => $audiencia->processo->numero ?? 'N/A',
                    'cliente' => $audiencia->cliente->nome ?? 'N/A',
                    'tipo' => $audiencia->tipo_formatado,
                    'data' => $audiencia->data_formatada,
                    'hora' => $audiencia->hora_formatada,
                    'local' => $audiencia->local,
                    'endereco' => $audiencia->endereco,
                    'sala' => $audiencia->sala,
                    'status' => $audiencia->status,
                    'status_formatado' => $audiencia->status_formatado,
                    'advogado' => $audiencia->advogado,
                    'juiz' => $audiencia->juiz,
                    'observacoes' => $audiencia->observacoes,
                    'lembrete' => $audiencia->lembrete,
                    'horas_lembrete' => $audiencia->horas_lembrete
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $audienciasFormatadas,
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
     * Estatísticas do dashboard de audiências
     */
    public function dashboardStats(): JsonResponse
    {
        try {
            $hoje = Carbon::today();
            $agora = Carbon::now();

            $stats = [
                'hoje' => Audiencia::hoje()->count(),
                'proximas_2h' => Audiencia::proximas(2)->count(),
                'em_andamento' => Audiencia::emAndamento()->count(),
                'total_mes' => Audiencia::whereMonth('data', $hoje->month)
                                      ->whereYear('data', $hoje->year)
                                      ->count(),
                'agendadas' => Audiencia::agendadas()
                                       ->where('data', '>=', $hoje)
                                       ->count(),
                'realizadas_mes' => Audiencia::where('status', 'realizada')
                                             ->whereMonth('data', $hoje->month)
                                             ->whereYear('data', $hoje->year)
                                             ->count()
            ];

            return response()->json([
                'success' => true,
                'data' => $stats
            ]);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar estatísticas',
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
            $audiencias = Audiencia::with(['processo', 'cliente', 'advogadoResponsavel'])
                                  ->hoje()
                                  ->orderBy('hora', 'asc')
                                  ->get();

            $audienciasFormatadas = $audiencias->map(function ($audiencia) {
                return [
                    'id' => $audiencia->id,
                    'processo' => $audiencia->processo->numero ?? 'N/A',
                    'cliente' => $audiencia->cliente->nome ?? 'N/A',
                    'tipo' => $audiencia->tipo_formatado,
                    'hora' => $audiencia->hora_formatada,
                    'local' => $audiencia->local,
                    'status' => $audiencia->status_formatado,
                    'advogado' => $audiencia->advogado
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $audienciasFormatadas
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
            
            $audiencias = Audiencia::with(['processo', 'cliente', 'advogadoResponsavel'])
                                  ->proximas($horas)
                                  ->orderBy('hora', 'asc')
                                  ->get();

            $audienciasFormatadas = $audiencias->map(function ($audiencia) {
                return [
                    'id' => $audiencia->id,
                    'processo' => $audiencia->processo->numero ?? 'N/A',
                    'cliente' => $audiencia->cliente->nome ?? 'N/A',
                    'tipo' => $audiencia->tipo_formatado,
                    'hora' => $audiencia->hora_formatada,
                    'local' => $audiencia->local,
                    'status' => $audiencia->status_formatado
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $audienciasFormatadas
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
            $audiencia = Audiencia::with(['processo', 'cliente', 'advogadoResponsavel', 'unidade'])
                                 ->findOrFail($id);

            $audienciaFormatada = [
                'id' => $audiencia->id,
                'processo_id' => $audiencia->processo_id,
                'processo' => $audiencia->processo->numero ?? 'N/A',
                'cliente_id' => $audiencia->cliente_id,
                'cliente' => $audiencia->cliente->nome ?? 'N/A',
                'advogado_id' => $audiencia->advogado_id,
                'unidade_id' => $audiencia->unidade_id,
                'tipo' => $audiencia->tipo,
                'tipo_formatado' => $audiencia->tipo_formatado,
                'data' => $audiencia->data->format('Y-m-d'),
                'data_formatada' => $audiencia->data_formatada,
                'hora' => $audiencia->hora_formatada,
                'local' => $audiencia->local,
                'endereco' => $audiencia->endereco,
                'sala' => $audiencia->sala,
                'advogado' => $audiencia->advogado,
                'juiz' => $audiencia->juiz,
                'status' => $audiencia->status,
                'status_formatado' => $audiencia->status_formatado,
                'observacoes' => $audiencia->observacoes,
                'lembrete' => $audiencia->lembrete,
                'horas_lembrete' => $audiencia->horas_lembrete,
                'created_at' => $audiencia->created_at,
                'updated_at' => $audiencia->updated_at
            ];

            return response()->json([
                'success' => true,
                'data' => $audienciaFormatada
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
                'processo_id' => 'required|exists:processos,id',
                'cliente_id' => 'required|exists:clientes,id',
                'advogado_id' => 'required|exists:users,id',
                'unidade_id' => 'required|exists:unidades,id',
                'tipo' => [
                    'required',
                    Rule::in(['conciliacao', 'instrucao', 'preliminar', 'julgamento', 'outras'])
                ],
                'data' => 'required|date|after_or_equal:today',
                'hora' => 'required|date_format:H:i',
                'local' => 'required|string|max:255',
                'advogado' => 'required|string|max:255',
                'endereco' => 'nullable|string',
                'sala' => 'nullable|string|max:100',
                'juiz' => 'nullable|string|max:255',
                'status' => [
                    'nullable',
                    Rule::in(['agendada', 'confirmada', 'realizada', 'cancelada', 'adiada'])
                ],
                'observacoes' => 'nullable|string',
                'lembrete' => 'boolean',
                'horas_lembrete' => 'integer|min:1|max:24'
            ]);

            // Verificar conflitos de horário
            $conflito = Audiencia::where('data', $validatedData['data'])
                                ->where('hora', $validatedData['hora'])
                                ->where('local', $validatedData['local'])
                                ->where('status', '!=', 'cancelada')
                                ->exists();

            if ($conflito) {
                return response()->json([
                    'success' => false,
                    'message' => 'Já existe uma audiência agendada para este horário e local'
                ], 422);
            }

            $audiencia = Audiencia::create($validatedData);
            
            // Carregar relacionamentos
            $audiencia->load(['processo', 'cliente', 'advogadoResponsavel', 'unidade']);

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
                'processo_id' => 'sometimes|exists:processos,id',
                'cliente_id' => 'sometimes|exists:clientes,id',
                'advogado_id' => 'sometimes|exists:users,id',
                'unidade_id' => 'sometimes|exists:unidades,id',
                'tipo' => [
                    'sometimes',
                    Rule::in(['conciliacao', 'instrucao', 'preliminar', 'julgamento', 'outras'])
                ],
                'data' => 'sometimes|date',
                'hora' => 'sometimes|date_format:H:i',
                'local' => 'sometimes|string|max:255',
                'advogado' => 'sometimes|string|max:255',
                'endereco' => 'nullable|string',
                'sala' => 'nullable|string|max:100',
                'juiz' => 'nullable|string|max:255',
                'status' => [
                    'sometimes',
                    Rule::in(['agendada', 'confirmada', 'realizada', 'cancelada', 'adiada'])
                ],
                'observacoes' => 'nullable|string',
                'lembrete' => 'boolean',
                'horas_lembrete' => 'integer|min:1|max:24'
            ]);

            // Verificar conflitos de horário (se mudou data/hora/local)
            if (isset($validatedData['data']) || isset($validatedData['hora']) || isset($validatedData['local'])) {
                $data = $validatedData['data'] ?? $audiencia->data->format('Y-m-d');
                $hora = $validatedData['hora'] ?? $audiencia->hora_formatada;
                $local = $validatedData['local'] ?? $audiencia->local;

                $conflito = Audiencia::where('data', $data)
                                    ->where('hora', $hora)
                                    ->where('local', $local)
                                    ->where('status', '!=', 'cancelada')
                                    ->where('id', '!=', $id)
                                    ->exists();

                if ($conflito) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Já existe uma audiência agendada para este horário e local'
                    ], 422);
                }
            }

            $audiencia->update($validatedData);
            
            // Carregar relacionamentos
            $audiencia->load(['processo', 'cliente', 'advogadoResponsavel', 'unidade']);

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
            
            // Verificar se pode ser excluída
            if ($audiencia->status === 'realizada') {
                return response()->json([
                    'success' => false,
                    'message' => 'Não é possível excluir uma audiência já realizada'
                ], 422);
            }

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

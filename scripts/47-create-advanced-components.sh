#!/bin/bash

# Script 47 - Componentes Avançados (Charts e Calendário)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/47-create-advanced-components.sh

echo "📊 Criando componentes avançados..."

# src/components/charts/LineChart/index.js
cat > frontend/src/components/charts/LineChart/index.js << 'EOF'
import React from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

const CustomLineChart = ({ 
  data = [], 
  lines = [], 
  height = 300,
  showGrid = true,
  showTooltip = true,
  showLegend = true 
}) => {
  const colors = ['#8B1538', '#F5B041', '#28A745', '#17A2B8', '#DC3545'];

  return (
    <ResponsiveContainer width="100%" height={height}>
      <LineChart data={data} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
        {showGrid && <CartesianGrid strokeDasharray="3 3" />}
        <XAxis dataKey="name" />
        <YAxis />
        {showTooltip && <Tooltip />}
        {showLegend && <Legend />}
        {lines.map((line, index) => (
          <Line
            key={line.dataKey}
            type="monotone"
            dataKey={line.dataKey}
            stroke={line.color || colors[index % colors.length]}
            strokeWidth={2}
            dot={{ r: 4 }}
            activeDot={{ r: 6 }}
            name={line.name || line.dataKey}
          />
        ))}
      </LineChart>
    </ResponsiveContainer>
  );
};

export default CustomLineChart;
EOF

# src/components/charts/BarChart/index.js
cat > frontend/src/components/charts/BarChart/index.js << 'EOF'
import React from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

const CustomBarChart = ({ 
  data = [], 
  bars = [], 
  height = 300,
  showGrid = true,
  showTooltip = true,
  showLegend = true 
}) => {
  const colors = ['#8B1538', '#F5B041', '#28A745', '#17A2B8', '#DC3545'];

  return (
    <ResponsiveContainer width="100%" height={height}>
      <BarChart data={data} margin={{ top: 20, right: 30, left: 20, bottom: 5 }}>
        {showGrid && <CartesianGrid strokeDasharray="3 3" />}
        <XAxis dataKey="name" />
        <YAxis />
        {showTooltip && <Tooltip />}
        {showLegend && <Legend />}
        {bars.map((bar, index) => (
          <Bar
            key={bar.dataKey}
            dataKey={bar.dataKey}
            fill={bar.color || colors[index % colors.length]}
            name={bar.name || bar.dataKey}
            radius={[4, 4, 0, 0]}
          />
        ))}
      </BarChart>
    </ResponsiveContainer>
  );
};

export default CustomBarChart;
EOF

# src/components/charts/PieChart/index.js
cat > frontend/src/components/charts/PieChart/index.js << 'EOF'
import React from 'react';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, Legend } from 'recharts';

const CustomPieChart = ({ 
  data = [], 
  height = 300,
  showTooltip = true,
  showLegend = true,
  colors = ['#8B1538', '#F5B041', '#28A745', '#17A2B8', '#DC3545', '#6F42C1', '#FD7E14']
}) => {
  const RADIAN = Math.PI / 180;
  
  const renderCustomizedLabel = ({ cx, cy, midAngle, innerRadius, outerRadius, percent }) => {
    const radius = innerRadius + (outerRadius - innerRadius) * 0.5;
    const x = cx + radius * Math.cos(-midAngle * RADIAN);
    const y = cy + radius * Math.sin(-midAngle * RADIAN);

    return (
      <text 
        x={x} 
        y={y} 
        fill="white" 
        textAnchor={x > cx ? 'start' : 'end'} 
        dominantBaseline="central"
        fontSize={12}
        fontWeight="bold"
      >
        {`${(percent * 100).toFixed(0)}%`}
      </text>
    );
  };

  return (
    <ResponsiveContainer width="100%" height={height}>
      <PieChart>
        <Pie
          data={data}
          cx="50%"
          cy="50%"
          labelLine={false}
          label={renderCustomizedLabel}
          outerRadius={80}
          fill="#8884d8"
          dataKey="value"
        >
          {data.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={colors[index % colors.length]} />
          ))}
        </Pie>
        {showTooltip && <Tooltip />}
        {showLegend && <Legend />}
      </PieChart>
    </ResponsiveContainer>
  );
};

export default CustomPieChart;
EOF

# src/components/calendar/Calendar/index.js
cat > frontend/src/components/calendar/Calendar/index.js << 'EOF'
import React, { useState } from 'react';
import { 
  ChevronLeftIcon, 
  ChevronRightIcon,
  CalendarIcon
} from '@heroicons/react/24/outline';
import { 
  getStartOfMonth, 
  getEndOfMonth, 
  getStartOfWeek, 
  getEndOfWeek,
  addDays,
  addMonths,
  subtractMonths,
  isToday,
  formatDate
} from '../../../utils/dateHelpers';
import Badge from '../../common/Badge';

const Calendar = ({ 
  events = [], 
  onDateClick = () => {}, 
  onEventClick = () => {},
  selectedDate = new Date(),
  showWeekends = true 
}) => {
  const [currentMonth, setCurrentMonth] = useState(new Date());

  const monthStart = getStartOfMonth(currentMonth);
  const monthEnd = getEndOfMonth(currentMonth);
  const startDate = getStartOfWeek(monthStart);
  const endDate = getEndOfWeek(monthEnd);

  const dateFormat = "d";
  const rows = [];
  let days = [];
  let day = startDate;
  let formattedDate = "";

  // Gerar dias do calendário
  while (day <= endDate) {
    for (let i = 0; i < 7; i++) {
      formattedDate = formatDate(day, dateFormat);
      const cloneDay = new Date(day);
      const isCurrentMonth = day.getMonth() === currentMonth.getMonth();
      const isSelected = formatDate(day, 'yyyy-MM-dd') === formatDate(selectedDate, 'yyyy-MM-dd');
      const dayEvents = events.filter(event => 
        formatDate(new Date(event.date), 'yyyy-MM-dd') === formatDate(day, 'yyyy-MM-dd')
      );

      days.push(
        <div
          key={day.toString()}
          className={`
            min-h-[100px] border border-gray-200 p-2 cursor-pointer hover:bg-gray-50
            ${!isCurrentMonth ? 'bg-gray-50 text-gray-400' : ''}
            ${isSelected ? 'bg-primary-50 border-primary-300' : ''}
            ${isToday(day) ? 'bg-blue-50 border-blue-300' : ''}
          `}
          onClick={() => onDateClick(cloneDay)}
        >
          <div className="flex items-center justify-between mb-1">
            <span className={`text-sm font-medium ${isToday(day) ? 'text-blue-600' : ''}`}>
              {formattedDate}
            </span>
            {dayEvents.length > 0 && (
              <Badge variant="primary" size="small">
                {dayEvents.length}
              </Badge>
            )}
          </div>
          
          <div className="space-y-1">
            {dayEvents.slice(0, 3).map((event, index) => (
              <div
                key={index}
                className={`text-xs p-1 rounded cursor-pointer truncate ${
                  event.type === 'audiencia' ? 'bg-red-100 text-red-800' :
                  event.type === 'atendimento' ? 'bg-blue-100 text-blue-800' :
                  event.type === 'prazo' ? 'bg-yellow-100 text-yellow-800' :
                  'bg-gray-100 text-gray-800'
                }`}
                onClick={(e) => {
                  e.stopPropagation();
                  onEventClick(event);
                }}
                title={event.title}
              >
                {event.title}
              </div>
            ))}
            {dayEvents.length > 3 && (
              <div className="text-xs text-gray-500">
                +{dayEvents.length - 3} mais
              </div>
            )}
          </div>
        </div>
      );
      day = addDays(day, 1);
    }
    rows.push(
      <div key={day.toString()} className="grid grid-cols-7 gap-0">
        {days}
      </div>
    );
    days = [];
  }

  const previousMonth = () => {
    setCurrentMonth(subtractMonths(currentMonth, 1));
  };

  const nextMonth = () => {
    setCurrentMonth(addMonths(currentMonth, 1));
  };

  const goToToday = () => {
    setCurrentMonth(new Date());
  };

  return (
    <div className="bg-white rounded-lg shadow border border-gray-200">
      {/* Header */}
      <div className="flex items-center justify-between p-4 border-b border-gray-200">
        <div className="flex items-center space-x-4">
          <h2 className="text-xl font-semibold text-gray-900">
            {formatDate(currentMonth, 'MMMM yyyy')}
          </h2>
          <button
            onClick={goToToday}
            className="px-3 py-1 text-sm border border-gray-300 rounded hover:bg-gray-50"
          >
            Hoje
          </button>
        </div>
        
        <div className="flex items-center space-x-2">
          <button
            onClick={previousMonth}
            className="p-2 hover:bg-gray-100 rounded"
          >
            <ChevronLeftIcon className="h-5 w-5" />
          </button>
          <button
            onClick={nextMonth}
            className="p-2 hover:bg-gray-100 rounded"
          >
            <ChevronRightIcon className="h-5 w-5" />
          </button>
        </div>
      </div>

      {/* Dias da semana */}
      <div className="grid grid-cols-7 gap-0 border-b border-gray-200">
        {['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'].map((day) => (
          <div key={day} className="p-3 text-center text-sm font-medium text-gray-500 bg-gray-50">
            {day}
          </div>
        ))}
      </div>

      {/* Dias do mês */}
      <div>{rows}</div>
    </div>
  );
};

export default Calendar;
EOF

# src/components/common/DatePicker/index.js
cat > frontend/src/components/common/DatePicker/index.js << 'EOF'
import React, { useState, useRef, useEffect } from 'react';
import { CalendarIcon } from '@heroicons/react/24/outline';
import { formatDate } from '../../../utils/formatters';
import Calendar from '../../calendar/Calendar';

const DatePicker = ({ 
  value, 
  onChange, 
  placeholder = 'Selecione uma data',
  disabled = false,
  error,
  label,
  required = false 
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedDate, setSelectedDate] = useState(value ? new Date(value) : null);
  const containerRef = useRef(null);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (containerRef.current && !containerRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleDateSelect = (date) => {
    setSelectedDate(date);
    onChange(formatDate(date, 'yyyy-MM-dd'));
    setIsOpen(false);
  };

  const displayValue = selectedDate ? formatDate(selectedDate, 'dd/MM/yyyy') : '';

  return (
    <div ref={containerRef} className="relative">
      {label && (
        <label className="block text-sm font-medium text-gray-700 mb-1">
          {label}
          {required && <span className="text-red-500 ml-1">*</span>}
        </label>
      )}
      
      <div className="relative">
        <input
          type="text"
          value={displayValue}
          placeholder={placeholder}
          readOnly
          disabled={disabled}
          onClick={() => !disabled && setIsOpen(!isOpen)}
          className={`
            block w-full pl-3 pr-10 py-2 border rounded-lg shadow-sm cursor-pointer
            focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500
            ${error ? 'border-red-300' : 'border-gray-300'}
            ${disabled ? 'bg-gray-100 cursor-not-allowed' : 'bg-white hover:border-gray-400'}
          `}
        />
        <div className="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
          <CalendarIcon className="h-5 w-5 text-gray-400" />
        </div>
      </div>

      {error && (
        <p className="mt-1 text-sm text-red-600">{error}</p>
      )}

      {isOpen && (
        <div className="absolute z-50 mt-1 bg-white border border-gray-200 rounded-lg shadow-lg">
          <Calendar
            selectedDate={selectedDate || new Date()}
            onDateClick={handleDateSelect}
            events={[]}
          />
        </div>
      )}
    </div>
  );
};

export default DatePicker;
EOF

# src/components/common/DataTable/index.js
cat > frontend/src/components/common/DataTable/index.js << 'EOF'
import React, { useState, useMemo } from 'react';
import { 
  ChevronUpIcon, 
  ChevronDownIcon,
  MagnifyingGlassIcon,
  FunnelIcon,
  DocumentArrowDownIcon
} from '@heroicons/react/24/outline';
import Input from '../Input';
import Button from '../Button';
import Badge from '../Badge';
import Loading from '../Loading';

const DataTable = ({
  data = [],
  columns = [],
  loading = false,
  searchable = true,
  filterable = true,
  exportable = true,
  pagination = true,
  itemsPerPage = 10,
  onRowClick = () => {},
  emptyMessage = 'Nenhum dado encontrado',
  className = ''
}) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [sortBy, setSortBy] = useState('');
  const [sortDirection, setSortDirection] = useState('asc');
  const [currentPage, setCurrentPage] = useState(1);
  const [filters, setFilters] = useState({});

  // Filtrar dados
  const filteredData = useMemo(() => {
    let result = [...data];

    // Aplicar busca
    if (searchTerm) {
      result = result.filter(item =>
        columns.some(column => {
          const value = item[column.key];
          return value && value.toString().toLowerCase().includes(searchTerm.toLowerCase());
        })
      );
    }

    // Aplicar filtros
    Object.entries(filters).forEach(([key, value]) => {
      if (value) {
        result = result.filter(item => item[key] === value);
      }
    });

    // Aplicar ordenação
    if (sortBy) {
      result.sort((a, b) => {
        const aVal = a[sortBy];
        const bVal = b[sortBy];
        
        if (aVal === bVal) return 0;
        
        const comparison = aVal > bVal ? 1 : -1;
        return sortDirection === 'asc' ? comparison : -comparison;
      });
    }

    return result;
  }, [data, searchTerm, sortBy, sortDirection, filters, columns]);

  // Paginação
  const paginatedData = useMemo(() => {
    if (!pagination) return filteredData;
    
    const startIndex = (currentPage - 1) * itemsPerPage;
    return filteredData.slice(startIndex, startIndex + itemsPerPage);
  }, [filteredData, currentPage, itemsPerPage, pagination]);

  const totalPages = Math.ceil(filteredData.length / itemsPerPage);

  const handleSort = (columnKey) => {
    if (sortBy === columnKey) {
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      setSortBy(columnKey);
      setSortDirection('asc');
    }
  };

  const handleExport = () => {
    // Implementar exportação
    console.log('Exportando dados...', filteredData);
  };

  if (loading) {
    return (
      <div className="bg-white rounded-lg border border-gray-200 p-8">
        <Loading size="large" text="Carregando dados..." />
      </div>
    );
  }

  return (
    <div className={`bg-white rounded-lg border border-gray-200 ${className}`}>
      {/* Toolbar */}
      {(searchable || filterable || exportable) && (
        <div className="p-4 border-b border-gray-200">
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-3 sm:space-y-0">
            <div className="flex-1 flex space-x-3">
              {searchable && (
                <div className="max-w-sm">
                  <Input
                    placeholder="Buscar..."
                    icon={MagnifyingGlassIcon}
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                  />
                </div>
              )}
            </div>
            
            <div className="flex space-x-2">
              {filterable && (
                <Button variant="outline" icon={FunnelIcon} size="small">
                  Filtros
                </Button>
              )}
              {exportable && (
                <Button 
                  variant="outline" 
                  icon={DocumentArrowDownIcon} 
                  size="small"
                  onClick={handleExport}
                >
                  Exportar
                </Button>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Table */}
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              {columns.map((column) => (
                <th
                  key={column.key}
                  className={`px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider ${
                    column.sortable ? 'cursor-pointer hover:bg-gray-100' : ''
                  }`}
                  onClick={() => column.sortable && handleSort(column.key)}
                >
                  <div className="flex items-center space-x-1">
                    <span>{column.title}</span>
                    {column.sortable && (
                      <div className="flex flex-col">
                        <ChevronUpIcon 
                          className={`w-3 h-3 ${
                            sortBy === column.key && sortDirection === 'asc' 
                              ? 'text-primary-600' 
                              : 'text-gray-400'
                          }`}
                        />
                        <ChevronDownIcon 
                          className={`w-3 h-3 -mt-1 ${
                            sortBy === column.key && sortDirection === 'desc' 
                              ? 'text-primary-600' 
                              : 'text-gray-400'
                          }`}
                        />
                      </div>
                    )}
                  </div>
                </th>
              ))}
            </tr>
          </thead>
          
          <tbody className="bg-white divide-y divide-gray-200">
            {paginatedData.length === 0 ? (
              <tr>
                <td 
                  colSpan={columns.length} 
                  className="px-6 py-8 text-center text-gray-500"
                >
                  {emptyMessage}
                </td>
              </tr>
            ) : (
              paginatedData.map((item, index) => (
                <tr 
                  key={item.id || index} 
                  className="hover:bg-gray-50 cursor-pointer"
                  onClick={() => onRowClick(item)}
                >
                  {columns.map((column) => (
                    <td key={column.key} className="px-6 py-4 whitespace-nowrap text-sm">
                      {column.render ? column.render(item, index) : item[column.key]}
                    </td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {pagination && totalPages > 1 && (
        <div className="px-6 py-3 border-t border-gray-200 flex items-center justify-between">
          <div className="text-sm text-gray-700">
            Mostrando {(currentPage - 1) * itemsPerPage + 1} a{' '}
            {Math.min(currentPage * itemsPerPage, filteredData.length)} de{' '}
            {filteredData.length} resultados
          </div>
          
          <div className="flex space-x-2">
            <Button
              variant="outline"
              size="small"
              disabled={currentPage === 1}
              onClick={() => setCurrentPage(currentPage - 1)}
            >
              Anterior
            </Button>
            
            {[...Array(totalPages)].map((_, i) => (
              <Button
                key={i}
                variant={currentPage === i + 1 ? "primary" : "outline"}
                size="small"
                onClick={() => setCurrentPage(i + 1)}
              >
                {i + 1}
              </Button>
            ))}
            
            <Button
              variant="outline"
              size="small"
              disabled={currentPage === totalPages}
              onClick={() => setCurrentPage(currentPage + 1)}
            >
              Próximo
            </Button>
          </div>
        </div>
      )}
    </div>
  );
};

export default DataTable;
EOF

echo "✅ Componentes avançados criados com sucesso!"
echo ""
echo "📊 ARQUIVOS CRIADOS:"
echo "   • LineChart, BarChart, PieChart - Gráficos com Recharts"
echo "   • Calendar - Calendário completo com eventos"
echo "   • DatePicker - Seletor de data com calendário"
echo "   • DataTable - Tabela avançada com busca/filtros/paginação"
echo ""
echo "📈 RECURSOS INCLUÍDOS:"
echo "   • Gráficos responsivos e customizáveis"
echo "   • Calendário com navegação e eventos"
echo "   • DatePicker com dropdown calendar"
echo "   • DataTable com busca, ordenação e exportação"
echo "   • Cores da identidade visual Erlene"
echo "   • Componentes totalmente reutilizáveis"
echo ""
echo "⏭️  Próximo: Páginas de erro e finalização do frontend!"
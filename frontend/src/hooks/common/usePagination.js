import { useState, useMemo } from 'react';

export const usePagination = ({
  data = [],
  itemsPerPage = 10,
  initialPage = 1,
}) => {
  const [currentPage, setCurrentPage] = useState(initialPage);

  // Calcular dados paginados
  const paginatedData = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    return data.slice(startIndex, endIndex);
  }, [data, currentPage, itemsPerPage]);

  // Calcular informações de paginação
  const paginationInfo = useMemo(() => {
    const totalItems = data.length;
    const totalPages = Math.ceil(totalItems / itemsPerPage);
    const startItem = (currentPage - 1) * itemsPerPage + 1;
    const endItem = Math.min(currentPage * itemsPerPage, totalItems);

    return {
      totalItems,
      totalPages,
      currentPage,
      itemsPerPage,
      startItem: totalItems > 0 ? startItem : 0,
      endItem,
      hasNextPage: currentPage < totalPages,
      hasPreviousPage: currentPage > 1,
    };
  }, [data.length, currentPage, itemsPerPage]);

  // Funções de navegação
  const goToPage = (page) => {
    const newPage = Math.max(1, Math.min(page, paginationInfo.totalPages));
    setCurrentPage(newPage);
  };

  const nextPage = () => {
    if (paginationInfo.hasNextPage) {
      setCurrentPage(currentPage + 1);
    }
  };

  const previousPage = () => {
    if (paginationInfo.hasPreviousPage) {
      setCurrentPage(currentPage - 1);
    }
  };

  const goToFirstPage = () => {
    setCurrentPage(1);
  };

  const goToLastPage = () => {
    setCurrentPage(paginationInfo.totalPages);
  };

  return {
    paginatedData,
    paginationInfo,
    goToPage,
    nextPage,
    previousPage,
    goToFirstPage,
    goToLastPage,
    setCurrentPage,
  };
};

import React, { Fragment } from 'react';
import { Dialog, Transition } from '@headlessui/react';
import { XMarkIcon } from '@heroicons/react/24/outline';
import Button from '../Button';

const Modal = ({
  isOpen,
  onClose,
  title,
  children,
  size = 'default',
  showCloseButton = true,
  closeOnOverlayClick = true,
  actions,
  className = '',
}) => {
  const sizeClasses = {
    small: 'max-w-md',
    default: 'max-w-lg',
    large: 'max-w-2xl',
    xl: 'max-w-4xl',
    full: 'max-w-full mx-4',
  };

  return (
    <Transition appear show={isOpen} as={Fragment}>
      <Dialog 
        as="div" 
        className="relative z-50" 
        onClose={closeOnOverlayClick ? onClose : () => {}}
      >
        <Transition.Child
          as={Fragment}
          enter="ease-out duration-300"
          enterFrom="opacity-0"
          enterTo="opacity-100"
          leave="ease-in duration-200"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <div className="fixed inset-0 bg-black bg-opacity-25 backdrop-blur-sm" />
        </Transition.Child>

        <div className="fixed inset-0 overflow-y-auto">
          <div className="flex min-h-full items-center justify-center p-4 text-center">
            <Transition.Child
              as={Fragment}
              enter="ease-out duration-300"
              enterFrom="opacity-0 scale-95"
              enterTo="opacity-100 scale-100"
              leave="ease-in duration-200"
              leaveFrom="opacity-100 scale-100"
              leaveTo="opacity-0 scale-95"
            >
              <Dialog.Panel 
                className={`
                  w-full ${sizeClasses[size]} transform overflow-hidden rounded-lg 
                  bg-white text-left align-middle shadow-xl transition-all
                  ${className}
                `}
              >
                {/* Header */}
                {(title || showCloseButton) && (
                  <div className="flex items-center justify-between p-6 border-b border-gray-200">
                    {title && (
                      <Dialog.Title
                        as="h3"
                        className="text-lg font-semibold text-gray-900"
                      >
                        {title}
                      </Dialog.Title>
                    )}
                    
                    {showCloseButton && (
                      <button
                        type="button"
                        className="text-gray-400 hover:text-gray-600 transition-colors"
                        onClick={onClose}
                      >
                        <XMarkIcon className="h-6 w-6" />
                      </button>
                    )}
                  </div>
                )}

                {/* Body */}
                <div className="p-6">
                  {children}
                </div>

                {/* Footer */}
                {actions && (
                  <div className="flex items-center justify-end space-x-3 px-6 py-4 border-t border-gray-200 bg-gray-50">
                    {actions}
                  </div>
                )}
              </Dialog.Panel>
            </Transition.Child>
          </div>
        </div>
      </Dialog>
    </Transition>
  );
};

// Modal de confirmação pré-configurado
Modal.Confirm = ({
  isOpen,
  onClose,
  onConfirm,
  title = 'Confirmar ação',
  message = 'Tem certeza que deseja continuar?',
  confirmText = 'Confirmar',
  cancelText = 'Cancelar',
  type = 'danger',
  loading = false,
}) => (
  <Modal
    isOpen={isOpen}
    onClose={onClose}
    title={title}
    size="small"
    actions={
      <>
        <Button
          variant="ghost"
          onClick={onClose}
          disabled={loading}
        >
          {cancelText}
        </Button>
        <Button
          variant={type}
          onClick={onConfirm}
          loading={loading}
        >
          {confirmText}
        </Button>
      </>
    }
  >
    <p className="text-gray-600">
      {message}
    </p>
  </Modal>
);

export default Modal;

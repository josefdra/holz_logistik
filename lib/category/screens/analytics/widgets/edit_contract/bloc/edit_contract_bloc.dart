import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik_backend/repository/contract_repository.dart';

part 'edit_contract_event.dart';
part 'edit_contract_state.dart';

class EditContractBloc extends Bloc<EditContractEvent, EditContractState> {
  EditContractBloc({
    required ContractRepository contractsRepository,
    required Contract? initialContract,
  })  : _contractsRepository = contractsRepository,
        super(
          EditContractState(
            initialContract: initialContract,
            done: initialContract?.done ?? false,
            title: initialContract?.title ?? '',
            additionalInfo: initialContract?.additionalInfo ?? '',
            availableQuantity: initialContract?.availableQuantity ?? 0.0,
            bookedQuantity: initialContract?.bookedQuantity ?? 0.0,
            shippedQuantity: initialContract?.shippedQuantity ?? 0.0,
          ),
        ) {
    on<EditContractTitleChanged>(_onTitleChanged);
    on<EditContractAdditionalInfoChanged>(_onAdditionalInfoChanged);
    on<EditContractAvailableQuantityChanged>(_onAvailableQuantityChanged);
    on<EditContractBookedQuantityChanged>(_onBookedQuantityChanged);
    on<EditContractShippedQuantityChanged>(_onShippedQuantityChanged);
    on<EditContractSubmitted>(_onSubmitted);
  }

  final ContractRepository _contractsRepository;

  void _onTitleChanged(
    EditContractTitleChanged event,
    Emitter<EditContractState> emit,
  ) {
    emit(state.copyWith(title: event.title));
  }

  void _onAdditionalInfoChanged(
    EditContractAdditionalInfoChanged event,
    Emitter<EditContractState> emit,
  ) {
    emit(state.copyWith(additionalInfo: event.additionalInfo));
  }

  void _onAvailableQuantityChanged(
    EditContractAvailableQuantityChanged event,
    Emitter<EditContractState> emit,
  ) {
    emit(state.copyWith(availableQuantity: event.availableQuantity));
  }

  void _onBookedQuantityChanged(
    EditContractBookedQuantityChanged event,
    Emitter<EditContractState> emit,
  ) {
    emit(
      state.copyWith(bookedQuantity: event.bookedQuantity),
    );
  }

  void _onShippedQuantityChanged(
    EditContractShippedQuantityChanged event,
    Emitter<EditContractState> emit,
  ) {
    emit(state.copyWith(shippedQuantity: event.shippedQuantity));
  }

  Future<void> _onSubmitted(
    EditContractSubmitted event,
    Emitter<EditContractState> emit,
  ) async {
    emit(state.copyWith(status: EditContractStatus.loading));
    final contract = (state.initialContract ?? Contract.empty()).copyWith(
      done: state.done,
      lastEdit: DateTime.now(),
      title: state.title,
      additionalInfo: state.additionalInfo,
      availableQuantity: state.availableQuantity,
      bookedQuantity: state.bookedQuantity,
      shippedQuantity: state.shippedQuantity,
    );

    try {
      await _contractsRepository.saveContract(contract);
      emit(state.copyWith(status: EditContractStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditContractStatus.failure));
    }
  }
}

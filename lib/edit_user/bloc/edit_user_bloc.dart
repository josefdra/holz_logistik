import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'edit_user_event.dart';
part 'edit_user_state.dart';

class EditUserBloc extends Bloc<EditUserEvent, EditUserState> {
  EditUserBloc({
    required UserRepository userRepository,
    required User? initialUser,
  })  : _userRepository = userRepository,
        super(
          EditUserState(
            initialUser: initialUser,
            name: initialUser?.name ?? '',
          ),
        ) {
    on<EditUserNameChanged>(_onNameChanged);
    on<EditUserSubmitted>(_onSubmitted);
  }

  final UserRepository _userRepository;

  void _onNameChanged(
    EditUserNameChanged event,
    Emitter<EditUserState> emit,
  ) {
    emit(state.copyWith(name: event.name));
  }

  Future<void> _onSubmitted(
    EditUserSubmitted event,
    Emitter<EditUserState> emit,
  ) async {
    emit(state.copyWith(status: EditUserStatus.loading));
    final user = (state.initialUser ??
            User(
              name: '',
              id: DateTime.now().microsecondsSinceEpoch,
              role: Role.basic,
              lastEdit: DateTime.now(),
            ))
        .copyWith(name: state.name);

    try {
      await _userRepository.saveUser(user);
      emit(state.copyWith(status: EditUserStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditUserStatus.failure));
    }
  }
}

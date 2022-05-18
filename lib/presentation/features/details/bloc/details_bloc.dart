import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marvel/domain/entities/character.dart';
import 'package:marvel/domain/entities/series.dart';
import 'package:marvel/domain/use_cases/get_character_details_use_case.dart';
import 'package:marvel/domain/use_cases/get_series_use_case.dart';
import 'package:marvel/presentation/convertors/convertor.dart';
import 'package:marvel/presentation/features/details/bloc/details_state.dart';
import 'package:marvel/presentation/view_models/view_data_details.dart';
import 'package:marvel/presentation/view_models/view_data_series.dart';

import 'details_event.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  final GetCharacterDetailsUseCase getCharacterDetails;
  final GetAllSeriesUseCase getAllSeries;

  DetailsBloc({required this.getAllSeries, required this.getCharacterDetails})
      : super(
          const DetailsState(loading: true),
        ) {
    on<DetailsEvent>(
      (event, emit) async {
        emit(
          state.copyWith(loading: true),
        );
        try {
          final Character character = await getCharacterDetails.call(event.characterId);
          final ViewDataCharacterDetails characterDetails = DetailsToViewData.toViewData(character);
          final List<Series> allSeries = await getAllSeries(event.characterId);
          final List<ViewDataSeries> series = SeriesToViewData.toViewData(allSeries);
          emit(
            state.copyWith(characterDetails: characterDetails, series: series, loading: false),
          );
        } catch (e) {
          emit(
            state.copyWith(
              loading: false,
              error: "error",
            ),
          );
        }
      },
    );
  }
}

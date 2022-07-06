import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:marvel/data/data_sources/local_data_source.dart';
import 'package:marvel/data/data_sources/marvel_api_client.dart';
import 'package:marvel/data/data_sources/remote_data_source.dart';
import 'package:marvel/data/repository/default_marvel_repository.dart';
import 'package:marvel/domain/repository/marvel_repository.dart';
import 'package:marvel/domain/use_cases/get_character_details_use_case.dart';
import 'package:marvel/domain/use_cases/get_characters_use_case.dart';
import 'package:marvel/domain/use_cases/get_series_use_case.dart';

GetIt getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerSingleton<BaseOptions>(BaseOptions(connectTimeout: 8000, receiveTimeout: 8000));

  getIt.registerSingleton<Dio>(Dio(getIt<BaseOptions>()));
  getIt.registerSingleton<MarvelApiClient>(
      MarvelApiClient(getIt<Dio>(), baseUrl: 'https://gateway.marvel.com:443/v1/public/'));

  getIt.registerFactory<RemoteDataSource>(() => DioDataSource());
  getIt.registerFactory<LocalDataSource>(() => HiveDataSource());

  getIt.registerSingleton<MarvelRepository>(DefaultMarvelRepository());
  getIt.registerFactory<GetCharactersUseCase>(() => GetCharactersUseCase(marvelRepository: DefaultMarvelRepository()));
  getIt.registerFactory<GetCharacterDetailsUseCase>(
          () => GetCharacterDetailsUseCase(marvelRepository: DefaultMarvelRepository()));
  getIt.registerFactory<GetAllSeriesUseCase>(() => GetAllSeriesUseCase(marvelRepository: DefaultMarvelRepository()));
}
import 'package:data/src/converters/converter.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain_module.dart';
import 'package:data/data_module.dart';

class DefaultMarvelRepository implements MarvelRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;

  DefaultMarvelRepository({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<List<Character>> getCharacters(int offset) async {
    List<Character> characters;
    if (offset == 0) {
      try {
        characters = await _getRemote(offset);
        _saveCharactersToDB(characters);
      } on DioError {
        characters = _getLocal();
      }
      return characters;
    }
    try {
      characters = await _getRemote(offset);
    } on DioError {
      throw NoInternetException();
    }
    return characters;
  }

  @override
  Future<Character> getCharacterDetails(int characterId) async {
    try {
      final httpResponse = await remoteDataSource.getCharacterDetails(characterId);
      if (httpResponse.response.statusCode != 200) {
        throw DataRetrievingException();
      }
      return httpResponse.data.data.results
          .map(
            (characterResponse) => characterResponse.detailsToDomainModel(characterResponse),
          )
          .single;
    } on DioError {
      throw NoInternetException();
    }
  }

  @override
  Future<List<Series>> getAllSeries(int characterId) async {
    try {
      final httpResponse = await remoteDataSource.getAllSeries(characterId);
      if (httpResponse.response.statusCode != 200) {
        throw DataRetrievingException();
      }
      return httpResponse.data.data.results
          .map(
            (seriesResponse) => seriesResponse.seriesToDomainModel(seriesResponse),
          )
          .toList();
    } on DioError {
      throw NoInternetException();
    }
  }

  @override
  Future<List<Character>> searchCharacters(String nameStartsWith) async {
    final httpResponse = await remoteDataSource.searchCharacters(nameStartsWith);
    print(httpResponse.toString());
    if (httpResponse.response.statusCode != 200) {
      throw DataRetrievingException();
    }
    return httpResponse.data.data.results
        .map(
          (remoteCharacter) => remoteCharacter.characterToDomainModel(remoteCharacter),
        )
        .toList();
  }

  Future<List<Character>> _getRemote(int offset) async {
    final httpResponse = await remoteDataSource.getCharacters(offset);
    if (httpResponse.response.statusCode != 200) {
      throw DataRetrievingException();
    }
    return httpResponse.data.data.results
        .map(
          (remoteCharacter) => remoteCharacter.characterToDomainModel(remoteCharacter),
        )
        .toList();
  }

  List<Character> _getLocal() {
    if (localDataSource.getAll().isNotEmpty) {
      List<LocalCharacter> localCharacters = localDataSource.getAll();
      return localCharacters.map((hero) => hero.localCharacterToDomainModel(hero)).toList();
    }
    throw DataRetrievingException();
  }

  void _saveCharactersToDB(List<Character> characters) {
    List<LocalCharacter> localCharacters = characters.map((hero) => hero.domainModelToLocalCharacter(hero)).toList();
    localDataSource.save(localCharacters);
  }
}

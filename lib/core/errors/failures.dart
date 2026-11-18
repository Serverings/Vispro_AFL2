import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable implements Exception {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class StorageFailure extends Failure {
  const StorageFailure()
      : super('Terjadi masalah saat mengakses penyimpanan. Silakan coba lagi.');
}

final class MalformedDataFailure extends Failure {
  const MalformedDataFailure()
      : super('Sebagian data pengeluaran rusak dan tidak dapat dibaca.');
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure()
      : super('Data pengeluaran tidak ditemukan. Mungkin sudah dihapus.');
}

final class NetworkFailure extends Failure {
  const NetworkFailure()
      : super('Tidak dapat terhubung. Periksa koneksi internet Anda lalu coba lagi.');
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('Proses terlalu lama. Silakan coba lagi.');
}

final class UnknownFailure extends Failure {
  const UnknownFailure()
      : super('Terjadi kesalahan yang tidak terduga. Silakan coba lagi.');
}

final class ValidationFailure extends Failure {
  const ValidationFailure(this.fieldErrors)
      : super('Periksa kembali isian Anda.');

  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [message, fieldErrors];
}
enum ProductStatus { unset, processed, onDelivery, finished }

extension ProductStatusExtension on ProductStatus {
  String getDisplayString() {
    switch (this) {
      case ProductStatus.processed:
        return "diproses";

      case ProductStatus.onDelivery:
        return "dikirim";

      case ProductStatus.finished:
        return "selesai";

      default:
        return "unset";
    }
  }
}

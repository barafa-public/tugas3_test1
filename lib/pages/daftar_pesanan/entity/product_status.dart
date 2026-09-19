enum ProductStatus { unset, processed, onDelivery, finished }

ProductStatus ProductStatusfromString(String from) {
  return switch (from) {
    "completed" => ProductStatus.finished,
    "cart" => ProductStatus.processed,
    _ => ProductStatus.unset,
  };
}

extension ProductStatusExtension on ProductStatus {
  String getDisplayString() {
    switch (this) {
      case ProductStatus.processed:
        return "cart";

      case ProductStatus.onDelivery:
        return "dikirim";

      case ProductStatus.finished:
        return "completed";

      default:
        return "unset";
    }
  }
}

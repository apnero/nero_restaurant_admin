
class SelectionPrice {
  const SelectionPrice({
    this.selectionId,
    this.price,
  });

  final String selectionId;
  final double price;

  factory SelectionPrice.from(String id, double price) {
    return new SelectionPrice(
      selectionId: id,
      price: price,
    );
  }
}
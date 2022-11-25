export default class Product {
  name: string;
  price: number;
  quantity: number;

  static getInstance(
    name: string,
    price: number,
    quantity: number
  ): Product | null {
    if (name == "") return null;
    return new Product(name, price, quantity);
  }

  private constructor(name: string, price: number, quantity: number) {
    this.name = name;
    this.price = price;
    this.quantity = quantity;
  }
}

export default class Product {
  id: string;
  name: string;
  price: number;
  quantity: number;

  static getInstance(
    id: string,
    name: string,
    price: number,
    quantity: number
  ): Product | null {
    if (name == "") return null;
    return new Product(id, name, price, quantity);
  }

  private constructor(id: string, name: string, price: number, quantity: number) {
    this.id = id;
    this.name = name;
    this.price = price;
    this.quantity = quantity;
  }
}

import Product from "./Product";

export default class BillDto {
  usuario: string;
  products: Product[];
  seller: string;
  purchaser: string;

  constructor(
    usuario: string,
    products: Product[],
    seller: string,
    purchaser: string
  ) {
    this.usuario = usuario;
    this.products = products;
    this.seller = seller;
    this.purchaser = purchaser;
  }
}

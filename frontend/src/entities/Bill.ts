import Product from "./Product";

export default class BillDto {
  user: string;
  products: Product[];
  seller: string;
  purchaser: string;
	id: string

  constructor(
    user: string,
    products: Product[],
    seller: string,
    purchaser: string,
		id: string
  ) {
    this.user = user;
    this.products = products;
    this.seller = seller;
    this.purchaser = purchaser;
		this.id = id;
  }
}

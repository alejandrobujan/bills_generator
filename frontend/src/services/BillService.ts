import Bill from "../entities/Bill";
import BillDto from "../entities/BillDto";

export default abstract class BillService {
  private static endpoint = "/api";

  static generateBill(bill: BillDto): Promise<Bill["id"]> {
    return fetch(`${this.endpoint}/expenses`, {
      method: "POST",
      mode: "cors",
      body: JSON.stringify(bill),
      headers: {
        "Content-Type": "application/json",
      },
    }).then((res) => res.json());
  }

  static getBill(id: Bill["id"]): Promise<Blob | undefined> {
    return fetch(`${this.endpoint}/expenses/${id}`, {
      method: "GET",
      mode: "cors",
    }).then((res) => res.blob());
  }
}
